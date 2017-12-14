#!/bin/bash

# author:        jondowson
# about:         for each server build and then send a configured version of pod

#-------------------------------------------

function task_buildSend(){

thisFunction="task_buildSend.sh"
errNo=0

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

# ----------

  # add trailing '/' to path if not present

  target_folder="$(lib_generic_strings_addTrailingSlash ${target_folder})"

# -----

  lib_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"

# -----

# establish the OS on remote machine

  remote_os=$(ssh -q -o Forwardx11=no ${user}@${pubIp} 'bash -s' < ${pod_home_path}/pods/pod_/scripts/scripts_generic_identifyOs.sh)
  lib_generic_display_msgColourSimple   "INFO-->" "detected os: ${green}${remote_os}${reset}"

# -----

  lib_generic_display_msgColourSimple "INFO-->" "making:      bespoke pod build"

  # pack a 'tmp_suitcase_file_path' of variables that will be sent to each server
  printf "%s\n" "TARGET_FOLDER=${target_folder}" > "${tmp_suitcase_file_path}"
  # source folder to reset paths based this server's target_folder
  # source "${tmp_build_file_path}"

  printf "%s\n" "JAVA_DISTRIBUTION=${JAVA_DISTRIBUTION}" >> "${tmp_suitcase_file_path}"
  printf "%s\n" "JAVA_VERSION=${JAVA_VERSION}" >> "${tmp_suitcase_file_path}"
  printf "%s\n" "JAVA_TARBALL=${JAVA_TARBALL}" >> "${tmp_suitcase_file_path}"
  printf "%s\n" "BUILD_FOLDER=${BUILD_FOLDER}" >> "${tmp_suitcase_file_path}"
  printf "%s\n" "build_folder_path=${target_folder}POD_SOFTWARE/POD/pod/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/" >> "${tmp_suitcase_file_path}"

  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "INFO-->" "editing:     'scripts_launchPodRemotely.sh'"; fi
  prepare_generic_misc_hashBang

# -----

  lib_generic_display_msgColourSimple "INFO-->" "sending:     bespoke pod build"
  printf "%s\n" "${red}"

  # check if server is local server - no point sending software if local +  no delete locally of existing pod folder
  localServer="false"
  localServer=$(lib_generic_checks_localIpMatch "${pubIp}")
  if [[ "${localServer}" == "false" ]]; then
    ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "rm -rf ${target_folder}POD_SOFTWARE/POD/pod" exit
  fi
  scp -q -o LogLevel=QUIET -i ${sshKey} -r "${tmp_working_folder}" "${user}@${pubIp}:${target_folder}POD_SOFTWARE/POD/"
  status=${?}
  pod_build_send_error_array["${tag}"]="${status};${pubIp}"
  > ${tmp_suitcase_file_path}
done

# delete the temporary work folder
rm -rf "${tmp_folder}"
}

#-------------------------------------------

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
  exit 1;
else
  lib_generic_display_msgColourSimple "SUCCESS" "Created and distributed pod builds on all servers"
fi
}
