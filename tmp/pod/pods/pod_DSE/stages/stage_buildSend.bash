# about:         for each server build and then send a configured version of pod

# ------------------------------------------

function task_buildSend(){

## for each server configure a pod build and then send it

for id in $(seq 1 ${numberOfServers});
do

  tag=$(jq             -r '.server_'${id}'.tag'             "${servers_json_path}")
  user=$(jq            -r '.server_'${id}'.user'            "${servers_json_path}")
  sshKey=$(jq          -r '.server_'${id}'.sshKey'          "${servers_json_path}")
  target_folder=$(jq   -r '.server_'${id}'.target_folder'   "${servers_json_path}")
  pubIp=$(jq           -r '.server_'${id}'.pubIp'           "${servers_json_path}")
  listen_address=$(jq  -r '.server_'${id}'.listen_address'  "${servers_json_path}")
  rpc_address=$(jq     -r '.server_'${id}'.rpc_address'     "${servers_json_path}")
  stomp_interface=$(jq -r '.server_'${id}'.stomp_interface' "${servers_json_path}")
  seeds=$(jq           -r '.server_'${id}'.seeds'           "${servers_json_path}")
  token=$(jq           -r '.server_'${id}'.token'           "${servers_json_path}")
  dc=$(jq              -r '.server_'${id}'.dc'              "${servers_json_path}")
  rack=$(jq            -r '.server_'${id}'.rack'            "${servers_json_path}")
  search=$(jq          -r '.server_'${id}'.mode.search'     "${servers_json_path}")
  analytics=$(jq       -r '.server_'${id}'.mode.analytics'  "${servers_json_path}")
  graph=$(jq           -r '.server_'${id}'.mode.graph'      "${servers_json_path}")
  dsefs=$(jq           -r '.server_'${id}'.mode.dsefs'      "${servers_json_path}")

# -----

  # add trailing '/' to path if not present
  target_folder="$(lib_generic_strings_addTrailingSlash ${target_folder})"

# -----

  prepare_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}" && printf "\n%s"
  remote_os=$(ssh -q -o Forwardx11=no ${user}@${pubIp} 'bash -s'  < ${pod_home_path}/pods/pod_/scripts/scripts_generic_identifyOs.sh)
  prepare_generic_display_msgColourSimple "INFO-->" "detected os: ${green}${remote_os}${reset}"
  prepare_generic_display_msgColourSimple "INFO-->" "making:      bespoke pod build"

# -----

  # assign build settings per the TARGET_FOLDER specified for this server
  printf "%s\n" "TARGET_FOLDER=${target_folder}"                  > "${suitcase_file_path}"
  source "${tmp_build_settings_file_path}"

# -----

  ## pack the suitcase: [1] + [2] are always required !!!

  # [1] TARGET_FOLDER determines many of the paths in build_settings.bash and can be different for each server
  printf "%s\n" "TARGET_FOLDER=${target_folder}"                  > "${tmp_suitcase_file_path}"    # clear any existing values with first entry (i.e. '>')
  # [2] append variables derived from flags
  printf "%s\n" "WHICH_POD=${WHICH_POD}"                         >> "${tmp_suitcase_file_path}"
  printf "%s\n" "BUILD_FOLDER=${BUILD_FOLDER}"                   >> "${tmp_suitcase_file_path}"
  build_folder_path_string="${target_folder}POD_SOFTWARE/POD/pod/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
  printf "%s\n" "build_folder_path=${build_folder_path_string}"  >> "${tmp_suitcase_file_path}"
  # [3] append variables derived from server json definition file
  printf "%s\n" "STOMP_INTERFACE=${stomp_interface}"             >> "${tmp_suitcase_file_path}"

# -----

  # edit the local copy of the dse config files
  lib_doStuff_locally_cassandraEnv
  lib_doStuff_locally_jvmOptions
  lib_doStuff_locally_cassandraYaml
  lib_doStuff_locally_dseSparkEnv
  lib_doStuff_locally_cassandraRackDcProperties
  lib_doStuff_locally_cassandraYamlNodeSpecific

# -----

  # write the cassandra data path(s) specified in the json to cassandra.yaml - handle ${BUILD_FOLDER} variable if present in path
  data_path=$(jq -r --arg bf "${BUILD_FOLDER}" '.server_'${id}'.cass_data[] | sub("\\${BUILD_FOLDER}";$bf)' "${servers_json_path}")
  declare -a data_file_directories_array
  COUNTER=0
  for path in ${data_path};
  do
    data_file_directories_array[${COUNTER}]=${path}
    (( COUNTER++ ))
  done
  lib_doStuff_locally_cassandraYamlData

# -----

  # write the dsefs data path(s) specified in the json to cassandra.yaml - handle ${BUILD_FOLDER} variable if present in path
  data_path=$(jq -r --arg bf "${BUILD_FOLDER}" '.server_'${id}'.dsefs_data[] | sub("\\${BUILD_FOLDER}";$bf)' "${servers_json_path}")
  declare -a dsefs_data_file_directories_array
  COUNTER=0
  for path in ${data_path};
  do
    dsefs_data_file_directories_array[${COUNTER}]=${path}
    (( COUNTER++ ))
  done
  lib_doStuff_locally_dseYamlDsefs

# -----

  prepare_generic_display_msgColourSimple "INFO-->" "sending:     bespoke pod build"
  printf "%s\n" "${red}"

  # check if server is local server - so not to delete itself !!
  localServer="false"
  localServer=$(lib_generic_checks_localIpMatch "${pubIp}")
  if [[ "${localServer}" != "true" ]]; then
    ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "rm -rf ${target_folder}POD_SOFTWARE/POD/pod" exit
  else
    cp "${tmp_suitcase_file_path}" ${pod_home_path}/.suitcase.tmp
  fi
  # (re)create folder and send over updated pod software
  ssh -q -i ${sshKey} ${user}@${pubIp} "mkdir -p ${target_folder}POD_SOFTWARE/POD/pod/"
  scp -q -o LogLevel=QUIET -i ${sshKey} -r "${tmp_working_folder}" "${user}@${pubIp}:${target_folder}POD_SOFTWARE/POD/"
  status=${?}
  build_send_error_array["${tag}"]="${status};${pubIp}"
done

# assign the local target_folder value to the suitcase
mv ${pod_home_path}/.suitcase.tmp "${suitcase_file_path}"
# delete the temporary work folder
rm -rf "${tmp_folder}"
}

# ------------------------------------------

function task_buildSend_report(){

## generate a report of all failed sends of pod build

declare -a build_send_report_array
count=0
for k in "${!build_send_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${build_send_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    build_send_fail="true"
    build_send_report_array["${count}"]="could not transfer: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# -----

if [[ "${build_send_fail}" == "true" ]]; then
  printf "%s\n"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}Write build error report:"
  printf "%s\n"

  for k in "${build_send_report_array[@]}"
  do
    prepare_generic_display_msgColourSimple "INFO-BOLD" "${cross} ${k}"
  done
  printf "%s\n"
  prepare_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  prepare_generic_misc_clearTheDecks && exit 1;
else
  prepare_generic_display_msgColourSimple "SUCCESS" "ALL SERVERS:  distributed bespoke pod build"
fi
}
