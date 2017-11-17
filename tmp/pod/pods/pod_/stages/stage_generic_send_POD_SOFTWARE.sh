#!/bin/bash

# author:        jondowson
# about:         send POD_SOFTWARE tarballs to each server to specified target folder

#-------------------------------------------

function task_generic_sendPodSoftware(){

# resolve ${POD_SOFTWARE} folder to local machine settings
source ${build_file_path}

for id in $(seq 1 ${numberOfServers});
do

  tag=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.tag'            | tr -d '"')
  user=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.user'           | tr -d '"')
  sshKey=$(cat ${servers_json_path}        | ${jq_folder}jq '.server_'${id}'.sshKey'         | tr -d '"')
  target_folder=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.target_folder'  | tr -d '"')
  pubIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.pubIp'          | tr -d '"')
  prvIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.prvIp'          | tr -d '"')
  
# ---------- 

  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

  # ----------

  lib_generic_display_msgColourSimple "info" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"

  # ----------

  lib_generic_display_msgColourSimple "info-indented" "sending:     POD_SOFTWARE folder"
  scp -q -o LogLevel=QUIET -i ${sshKey} -r ${POD_SOFTWARE} ${user}@${pubIp}:${target_folder} &                                                       # run in parallel
  # grab pid and capture owner in array
  pid=${!}
  lib_generic_display_msgColourSimple "info-indented" "pid id:      ${yellow}${pid}${reset}"
  pod_software_send_pid_array["${pid}"]="${tag};${pubIp}"
  DSE_pids+=" $pid"

  # print out pids
  if [[ "${DSE_pids_print}" ]]; then
    DSE_pids_print="${DSE_pids_print},$pid"
  else
    DSE_pids_print="$!"
  fi
  printf "\n%s"

done

# ----------

lib_generic_display_msgColourSimple "info-bold" "awaiting scp pids:${reset}"
lib_generic_display_msgColourSimple "info" "${yellow}$DSE_pids${reset}"
printf "\n%s"

# ----------

# Wait for all processes to finish

POD_SOFTWARE_pid_failures=""
printf "%s" ${red}  # any scp error messages
for p in $DSE_pids; do
  if wait $p; then
    printf "%s\n" "${green}Process $p success${reset}"
  else
    printf "%s\n" "${red}Process $p fail${reset}"
    POD_SOFTWARE_pid_failures+=" ${p}"
  fi
done
}

#-------------------------------------------

function task_generic_sendPodSoftware_report(){

# display report

lib_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Send POD_SOFTWARE To Each Server"

if [[ ! -z $POD_SOFTWARE_pid_failures ]]; then
  lib_generic_display_msgColourSimple "info-indented" "${cross} Problems distributing POD_SOFTWARE to servers"
  printf "%s\n"
  for k in "${!POD_SOFTWARE_server_pid_array[@]}"
  do
    if [[ "${POD_SOFTWARE_pid_failures}" == *"$k"* ]]; then
      lib_generic_strings_expansionDelimiter "${pod_software_send_pid_array[$k]}" ";" "1"
      server="$_D1_"
      ip=$_D2_
      lib_generic_display_msgColourSimple "error-tight" "pid ${yellow}${k}${red} failed for ${yellow}${server}@${ip}${red}"
    fi
  done
  printf "%s\n"
else
  lib_generic_display_msgColourSimple "success" "Distributed 'POD_SOFTWARE' to all servers"                                                          
fi
}
