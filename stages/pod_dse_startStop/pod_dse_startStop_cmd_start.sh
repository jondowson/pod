#!/bin/bash

# script_name:   pod_dse_startStop_cmd_start.sh
# author:        jondowson
# about:         start dse on each server based on its server json defined mode

#-------------------------------------------

function task_pod_start_dse(){

## for each server start dse based on its json defined mode

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

  pod_generic_display_msgColourSimple "info-indented" "making:      bespoke pod build"                                                               && sleep ${STEP_PAUSE}

# ----------

  searchFlag=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.search' | tr -d '"')
  analyticsFlag=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.analytics' | tr -d '"')
  graphFlag=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.graph' | tr -d '"') 
  
  start_cmd="dse cassandra"
  if [[ "${searchFlag}" == "true" ]];     then start_cmd="${start_cmd} -s"; fi
  if [[ "${analyticsFlag}" == "true" ]];  then start_cmd="${start_cmd} -k"; fi
  if [[ "${graphFlag}" == "true" ]];      then start_cmd="${start_cmd} -g"; fi
  
# ----------

  status="999"
  if [[ "${status}" != "0" ]]; then
    retry=1
    until [[ "${retry}" == "6" ]] || [[ "${status}" == "0" ]]
    do
      ssh -q -i ${sshKey} ${user}@${pubIp} 'bash -s' "${start_cmd}" exit
      status=${?}
      if [[ "${status}" == "0" ]]; then
        pod_generic_display_msgColourSimple "info-indented" "ssh return code: ${green}${status}"
      else
        pod_generic_display_msgColourSimple "info-indented" "ssh return code: ${red}${status} ${white}(retry ${retry}/5)"
      fi
      pod_start_dse_error_array["${tag}"]="${status};${pubIp}"
      ((retry++))
    done
    printf "%s\n"
  fi
done
}

#-------------------------------------------

function task_pod_start_dse_report(){

## generate a report of all failed ssh connectivity attempts

declare -a pod_start_dse_report_array
count=0
for k in "${!pod_start_dse_error_array[@]}"
do
  pod_generic_misc_expansionDelimiter ${pod_start_dse_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_start_dse_fail="true"
    pod_start_dse_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with error code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${pod_start_dse_fail}" == "true" ]]; then
  printf "%s\n"
  pod_generic_display_msgColourSimple "info-bold" "--> ${red}Dse start errors report:"                                                               && sleep "${STEP_PAUSE}"
  printf "%s\n"
  for k in "${pod_start_dse_report_array[@]}"
  do
    pod_generic_display_msgColourSimple "info" "${cross} ${k}"
  done
  printf "%s\n"
  pod_generic_display_msgColourSimple "error" "Could not start DSE on this server"
else
  pod_generic_display_msgColourSimple "success" "DSE started for all servers"                                                                        && sleep "${STEP_PAUSE}"
fi
}
