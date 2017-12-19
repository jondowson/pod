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
  # establish the OS on remote machine
  remote_os=$(ssh -q -o Forwardx11=no ${user}@${pubIp} 'bash -s' < ${pod_home_path}/pods/pod_/scripts/scripts_generic_identifyOs.sh)
  lib_generic_display_msgColourSimple "INFO-->" "detected os: ${green}${remote_os}${reset}"
  lib_generic_display_msgColourSimple "INFO-->" "making:      bespoke pod build"

# -----

  # pack the suitcase !! - this personalised carry-all will be travelling to each server !!
  # [1] first pack all the server specific variables from the json file (not all are neccessarily required but it does not matter)
  # [2] set the TARGET_FOLDER and source this server's build_settings file to reset its values for this server
  # [3] then append the build settings - these may now be updated as they are dependent on the target_folder specified in the json file.

  printf "%s\n" "tag=${tag}"                         >> "${tmp_suitcase_file_path}"
  printf "%s\n" "user=${user}"                       >> "${tmp_suitcase_file_path}"
  printf "%s\n" "sshKey=${sshKey}"                   >> "${tmp_suitcase_file_path}"
  printf "%s\n" "target_folder=${target_folder}"     >> "${tmp_suitcase_file_path}"
  printf "%s\n" "pubIp=${pubIp}"                     >> "${tmp_suitcase_file_path}"
  printf "%s\n" "prvIp=${prvIp}"                     >> "${tmp_suitcase_file_path}"
  printf "%s\n" "listen_address=${listen_address}"   >> "${tmp_suitcase_file_path}"
  printf "%s\n" "rpc_address=${rpc_address}"         >> "${tmp_suitcase_file_path}"
  printf "%s\n" "stomp_interface=${stomp_interface}" >> "${tmp_suitcase_file_path}"
  printf "%s\n" "seeds=${seeds}"                     >> "${tmp_suitcase_file_path}"
  printf "%s\n" "token=${token}"                     >> "${tmp_suitcase_file_path}"
  printf "%s\n" "dc=${dc}"                           >> "${tmp_suitcase_file_path}"
  printf "%s\n" "rack=${rack}"                       >> "${tmp_suitcase_file_path}"
  printf "%s\n" "search=${search}"                   >> "${tmp_suitcase_file_path}"
  printf "%s\n" "analytics=${analytics}"             >> "${tmp_suitcase_file_path}"
  printf "%s\n" "graph=${graph}"                     >> "${tmp_suitcase_file_path}"
  printf "%s\n" "dsefs=${dsefs}"                     >> "${tmp_suitcase_file_path}"
 set -x
  # this capitalised target_folder will determine paths for this server's build settings file
  # this will be picked up when the scripts_launchPodRemotely.sh script is run on the remote server
  printf "%s\n" "TARGET_FOLDER=${target_folder}"     >> "${tmp_suitcase_file_path}"
  TARGET_FOLDER=${target_folder}
  # refesh build_settings.bash - it will now make use of the updated TARGET_FOLDER
  source "${tmp_build_settings_file_path}"
  # now refreshed - add these also to the suitacase
  printf "%s\n" "BUILD_FOLDER=${BUILD_FOLDER}" >> "${tmp_suitcase_file_path}"
  printf "%s\n" "build_folder_path=${target_folder}POD_SOFTWARE/POD/pod/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/" >> "${tmp_suitcase_file_path}"
exit
# -----

  lib_doStuff_locally_dseYamlTDE

# -----

  lib_generic_display_msgColourSimple "INFO-->" "sending:     bespoke pod build"
  printf "%s\n" "${red}"

  # check if server is local server - so not to delete itself !!
  localServer="false"
  localServer=$(lib_generic_checks_localIpMatch "${pubIp}")
  if [[ "${localServer}" == "false" ]]; then
    ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "rm -rf ${target_folder}POD_SOFTWARE/POD/pod" exit
  fi
  # send the updated pod
  scp -q -o LogLevel=QUIET -i ${sshKey} -r "${tmp_working_folder}" "${user}@${pubIp}:${target_folder}POD_SOFTWARE/POD/"
  status=${?}
  pod_build_send_error_array["${tag}"]="${status};${pubIp}"

  # clear the suitcase for the next server
  #> ${tmp_suitcase_file_path}
done

# delete the temporary work folder
rm -rf "${tmp_folder}"
}

# ------------------------------------------

function task_buildSend_report(){

## generate a report of all failed sends of pod build

lib_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Create Pod For Each Server"

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
    lib_generic_display_msgColourSimple "info-bold" "${cross} ${k}"
  done
  printf "%s\n"
  lib_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  prepare_generic_misc_clearTheDecks && exit 1;
else
  lib_generic_display_msgColourSimple "SUCCESS" "Created and distributed pod builds on all servers"
fi
}
