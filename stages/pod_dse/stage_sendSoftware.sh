#!/bin/bash

# author:        jondowson
# about:         send DSE_SOFTWARE tarballs to each server to specified target folder 

#-------------------------------------------

function task_pod_software_send(){

# resolve ${DSE_SOFTWARE} folder to local machine settings
source ${build_file_path}

for id in `seq 1 ${numberOfServers}`;
do

  tag=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.tag'           | tr -d '"')
  user=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.user'          | tr -d '"')
  sshKey=$(cat ${servers_json_path}        | ${jq_folder}jq '.server_'${id}'.sshKey'        | tr -d '"')
  target_folder=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.target_folder' | tr -d '"')
  pubIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.pubIp'         | tr -d '"')
  prvIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.prvIp'         | tr -d '"')
  listen_address=$(cat ${servers_json_path}| ${jq_folder}jq '.server_'${id}'.listen_address'| tr -d '"')
  seeds=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.seeds'         | tr -d '"')
  token=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.token'         | tr -d '"')
  dc=$(cat ${servers_json_path}            | ${jq_folder}jq '.server_'${id}'.dc'            | tr -d '"')
  rack=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.rack'          | tr -d '"')

  # add trailing '/' to path if not present
  target_folder=$(pod_generic_misc_addTrailingSlash "${target_folder}")

  # ----------

  pod_generic_display_msgColourSimple "info" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"

  # ----------

  pod_generic_display_msgColourSimple "info-indented" "sending:     DSE_SOFTWARE folder"                                                             && sleep "${STEP_PAUSE}"
  scp -q -o LogLevel=QUIET -i ${sshKey} -r ${DSE_SOFTWARE} ${user}@${pubIp}:${target_folder} &                                                       # run in parallel
  # grab pid and capture owner in array
  pid=${!}
  pod_generic_display_msgColourSimple "info-indented" "pid id:      ${yellow}${pid}${reset}"
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

pod_generic_display_msgColourSimple "info-bold" "awaiting scp pids:${reset}"
pod_generic_display_msgColourSimple "info" "${yellow}$DSE_pids${reset}"
printf "\n%s"

# ----------

# Wait for all processes to finish

DSE_SOFTWARE_pid_failures=""
printf "%s" ${red}  # any scp error messages
for p in $DSE_pids; do
  if wait $p; then
    printf "%s\n" "${green}Process $p success${reset}"
  else
    printf "%s\n" "${red}Process $p fail${reset}"
    DSE_SOFTWARE_pid_failures+=" ${p}"
  fi
done
}

#-------------------------------------------

function task_pod_software_send_report(){

# display report

pod_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Send DSE_SOFTWARE To Each Server"                                               && sleep "${STEP_PAUSE}"

if [[ ! -z $DSE_SOFTWARE_pid_failures ]]; then
  pod_generic_display_msgColourSimple "info-indented" "${cross} Problems distributing DSE_SOFTWARE to servers"                                       && sleep "${STEP_PAUSE}"
  printf "%s\n"
  for k in "${!DSE_SOFTWARE_server_pid_array[@]}"
  do
    if [[ "${DSE_SOFTWARE_pid_failures}" == *"$k"* ]]; then
      pod_generic_misc_expansionDelimiter "${pod_software_send_pid_array[$k]}" ";" "1"
      server="$_D1_"
      ip=$_D2_
      pod_generic_display_msgColourSimple "error-tight" "pid ${yellow}${k}${red} failed for ${yellow}${server}@${ip}${red}"
    fi
  done
  printf "%s\n"
else 
  pod_generic_display_msgColourSimple "success" "Distributed 'DSE_SOFTWARE' to all servers"                                                          && sleep "${STEP_PAUSE}"
fi
}
