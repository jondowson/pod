# author:        jondowson
# about:         for each server build and then send a configured version of pod

# ------------------------------------------

function task_buildSend(){

## for each server configure a pod build and then send it

for id in $(seq 1 ${numberOfServers});
do

  tag=$(cat ${servers_json_path}             | ${jq_folder}jq '.server_'${id}'.tag'              | tr -d '"')
  user=$(cat ${servers_json_path}            | ${jq_folder}jq '.server_'${id}'.user'             | tr -d '"')
  sshKey=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.sshKey'           | tr -d '"')
  target_folder=$(cat ${servers_json_path}   | ${jq_folder}jq '.server_'${id}'.target_folder'    | tr -d '"')
  pubIp=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.pubIp'            | tr -d '"')
  prvIp=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.prvIp'            | tr -d '"')
  listen_address=$(cat ${servers_json_path}  | ${jq_folder}jq '.server_'${id}'.listen_address'   | tr -d '"')
  rpc_address=$(cat ${servers_json_path}     | ${jq_folder}jq '.server_'${id}'.rpc_address'      | tr -d '"')
  stomp_interface=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.stomp_interface'  | tr -d '"')
  seeds=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.seeds'            | tr -d '"')
  token=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.token'            | tr -d '"')
  dc=$(cat ${servers_json_path}              | ${jq_folder}jq '.server_'${id}'.dc'               | tr -d '"')
  rack=$(cat ${servers_json_path}            | ${jq_folder}jq '.server_'${id}'.rack'             | tr -d '"')
  search=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.mode.search'      | tr -d '"')
  analytics=$(cat ${servers_json_path}       | ${jq_folder}jq '.server_'${id}'.mode.analytics'   | tr -d '"')
  graph=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.mode.graph'       | tr -d '"')
  dsefs=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.mode.dsefs'       | tr -d '"')

# -----

  # add trailing '/' to path if not present
  target_folder="$(lib_generic_strings_addTrailingSlash ${target_folder})"

# -----

  lib_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"
  remote_os=$(ssh -q -o Forwardx11=no ${user}@${pubIp} 'bash -s' < ${pod_home_path}/pods/pod_/scripts/scripts_generic_identifyOs.sh)
  lib_generic_display_msgColourSimple "INFO-->" "detected os: ${green}${remote_os}${reset}"
  lib_generic_display_msgColourSimple "INFO-->" "making:      bespoke pod build"

# -----

  # assign build settings per the TARGET_FOLDER specified for this server  
  printf "%s\n" "TARGET_FOLDER=${target_folder}"            > "${suitcase_file_path}"
  source "${tmp_build_settings_file_path}"                    

# -----

  ## pack the suitcase !! - the tmp_suitcase becomes the suitcase on each server

  # [1] TARGET_FOLDER determines many of the settings in build_settings.bash and can be different for each server  
  printf "%s\n" "TARGET_FOLDER=${target_folder}"                  > "${tmp_suitcase_file_path}"    # clear any existing values with first entry (i.e. '>')
  # [2] append variables derived from server json definition file
  printf "%s\n" "STOMP_INTERFACE=${stomp_interface}"             >> "${tmp_suitcase_file_path}"
  # [3] append variables derived from flags
  printf "%s\n" "WHICH_POD=${WHICH_POD}"                         >> "${tmp_suitcase_file_path}"
  printf "%s\n" "BUILD_FOLDER=${BUILD_FOLDER}"                   >> "${tmp_suitcase_file_path}"
  build_folder_path_string="${target_folder}POD_SOFTWARE/POD/pod/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
  printf "%s\n" "build_folder_path=${build_folder_path_string}"  >> "${tmp_suitcase_file_path}"

# -----

  # edit the local copy of the dse config files
  lib_doStuff_locally_cassandraEnv
  lib_doStuff_locally_jvmOptions
  lib_doStuff_locally_cassandraYaml
  lib_doStuff_locally_dseSparkEnv
  lib_doStuff_locally_cassandraRackDcProperties

# -----

  # calculate number of cassandra data folders specified in json
  # -3? - one for each bracket line and another 'cos the array starts at zero
  numberOfDataFolders=$(($(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.cass_data' | wc -l)-3))

# CAT/EOF cannot be indented !!
cat << EOF >> "${tmp_suitcase_file_path}"
declare -a data_file_directories_array
EOF

for j in `seq 0 ${numberOfDataFolders}`;
do
data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.cass_data['${j}']' | tr -d '"')
cat << EOF >> "${tmp_suitcase_file_path}"
data_file_directories_array[${j}]="${data_path}"
EOF
done

# -----

  declare -a data_file_directories_array
  for j in $(seq 0 ${numberOfDataFolders});
  do
    data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.cass_data['${j}']' | tr -d '"')
    data_file_directories_array[${j}]=${data_path}
  done
  lib_doStuff_locally_cassandraYamlData

# -----

  if [[ "${analytics}" == "true" ]] || [[ "${dsefs}" == "true" ]]; then

    # calculate number of cassandra data folders specified in json
    # -3? - one for each bracket line and another 'cos the array starts at zero
    numberOfDataFolders=$(($(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.dsefs_data' | wc -l)-3))

# CAT/EOF cannot be indented !!
cat << EOF >> "${tmp_suitcase_file_path}"
declare -a dsefs_data_file_directories_array
EOF

for j in $(seq 0 ${numberOfDataFolders});
do
data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.dsefs_data['${j}']' | tr -d '"')
cat << EOF >> "${tmp_suitcase_file_path}"
dsefs_data_file_directories_array[${j}]="${data_path}"
EOF
done
  fi

# -----

  declare -a dsefs_data_file_directories_array
  for j in $(seq 0 ${numberOfDataFolders});
  do
    data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.dsefs_data['${j}']' | tr -d '"')
    dsefs_data_file_directories_array[${j}]=${data_path}
  done
  
  if [[ "${analytics}" == "true" ]] || [[ "${dsefs}" == "true" ]]; then
    lib_doStuff_locally_dseYamlDsefs
  fi

# -----

  # set node specific settings for 'seeds:' and 'listen_address:'
  lib_doStuff_locally_cassandraYamlNodeSpecific

# -----

  lib_generic_display_msgColourSimple "INFO-->" "sending:     bespoke pod build"
  printf "%s\n" "${red}"

  # check if server is local server - so not to delete itself !!
  localServer="false"
  localServer=$(lib_generic_checks_localIpMatch "${pubIp}")
  if [[ "${localServer}" != "true" ]]; then
    ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "rm -rf ${target_folder}POD_SOFTWARE/POD/pod" exit
  else
    cp "${tmp_suitcase_file_path}" ${pod_home_path}/.suitcase.tmp
  fi
  # send the updated pod
  scp -q -o LogLevel=QUIET -i ${sshKey} -r "${tmp_working_folder}" "${user}@${pubIp}:${target_folder}POD_SOFTWARE/POD/"
  status=${?}
  pod_build_send_error_array["${tag}"]="${status};${pubIp}"
done

# assign the local target_folder value to the suitcase
mv ${pod_home_path}/.suitcase.tmp "${suitcase_file_path}"
# delete the temporary work folder
rm -rf "${tmp_folder}"
}

# ------------------------------------------

function task_buildSend_report(){

## generate a report of all failed sends of pod build

lib_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Create pod for each server"

declare -a pod_build_send_report_array
count=0
for k in "${!pod_build_send_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${pod_build_send_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_build_send_fail="true"
    pod_build_send_report_array["${count}"]="could not transfer: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# -----

if [[ "${pod_build_send_fail}" == "true" ]]; then
  printf "%s\n"
  lib_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}Write build error report:"
  printf "%s\n"

  for k in "${pod_build_send_report_array[@]}"
  do
    lib_generic_display_msgColourSimple "INFO-BOLD" "${cross} ${k}"
  done
  printf "%s\n"
  lib_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  prepare_generic_misc_clearTheDecks && exit 1;
else
  lib_generic_display_msgColourSimple "SUCCESS" "Create and send bespoke pod build to all servers"
fi
}
