#!/bin/bash

# author:        jondowson
# about:         test connectivity and write-paths for all servers in servers json definition

#-------------------------------------------

function task_testConnectivity(){

## for each server test ssh connectivity + authorisation

for id in `seq 1 ${numberOfServers}`;
do

  tag=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.tag'            | tr -d '"')
  user=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.user'           | tr -d '"')
  sshKey=$(cat ${servers_json_path}        | ${jq_folder}jq '.server_'${id}'.sshKey'         | tr -d '"')
  target_folder=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.target_folder'  | tr -d '"')
  pubIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.pubIp'          | tr -d '"')
  prvIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.prvIp'          | tr -d '"')
  listen_address=$(cat ${servers_json_path}| ${jq_folder}jq '.server_'${id}'.listen_address' | tr -d '"')
  rpc_address=$(cat ${servers_json_path}   | ${jq_folder}jq '.server_'${id}'.listen_address' | tr -d '"')
  seeds=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.seeds'          | tr -d '"')
  token=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.token'          | tr -d '"')
  dc=$(cat ${servers_json_path}            | ${jq_folder}jq '.server_'${id}'.dc'             | tr -d '"')
  rack=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.rack'           | tr -d '"')
  search=$(cat ${servers_json_path}        | ${jq_folder}jq '.server_'${id}'.mode.search'    | tr -d '"')
  analytics=$(cat ${servers_json_path}     | ${jq_folder}jq '.server_'${id}'.mode.analytics' | tr -d '"')
  graph=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.mode.graph'     | tr -d '"')
  dsefs=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.mode.dsefs'     | tr -d '"')
  
# ---------- 
  
  # add trailing '/' to path if not present
  target_folder=$(pod_generic_misc_addTrailingSlash "${target_folder}")

# ----------

  pod_generic_display_msgColourSimple "info" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"

# ----------

  status="999"
  if [[ "${status}" != "0" ]]; then
    retry=1
    until [[ "${retry}" == "6" ]] || [[ "${status}" == "0" ]]
    do
      ssh -q -i ${sshKey} ${user}@${pubIp} exit
      status=${?}
      if [[ "${status}" == "0" ]]; then
        pod_generic_display_msgColourSimple "info-indented" "ssh return code: ${green}${status}"
      else
        pod_generic_display_msgColourSimple "info-indented" "ssh return code: ${red}${status} ${white}(retry ${retry}/5)"
      fi
      pod_test_connect_error_array["${tag}"]="${status};${pubIp}"
      ((retry++))
    done
    printf "%s\n"
  fi
done
}

#-------------------------------------------

function task_testConnectivity_report(){

## generate a report of all failed ssh connectivity attempts

declare -a pod_test_connect_report_array
count=0
for k in "${!pod_test_connect_error_array[@]}"
do
  pod_generic_misc_expansionDelimiter ${pod_test_connect_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_test_connect_fail="true"
    pod_test_connect_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with error code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${pod_test_connect_fail}" == "true" ]]; then
  printf "%s\n"
  pod_generic_display_msgColourSimple "info-bold" "--> ${red}Connection errors report:"
  printf "%s\n"
  for k in "${pod_test_connect_report_array[@]}"
  do
    pod_generic_display_msgColourSimple "info" "${cross} ${k}"
  done
  printf "%s\n"
  pod_generic_display_msgColourSimple "error" "Aborting script as not all servers are reachable"
  exit 1;
else
  pod_generic_display_msgColourSimple "success" "Connectivity test passed for all servers"
fi
}
