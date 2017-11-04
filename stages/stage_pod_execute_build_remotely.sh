#!/bin/bash

# script_name:   stage_pod_execute_build_remotely.sh
# author:        jondowson
# about:         run 'setup_pod_remote.sh' on each server in the cluster

#-------------------------------------------

function task_pod_execute_pod_remotely(){

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
  target_folder=$(generic_add_trailing_slash "${target_folder}")

# -----

  generic_msg_colour_simple "info" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"

  generic_msg_colour_simple "info-indented" "execute:     setup_pod_remote.sh"                                          && sleep "${STEP_PAUSE}"
  ssh -o ForwardX11=no ${user}@${pubIp} "${target_folder}pod/misc/setup_pod_remote.sh" &                                # run in parallel
  # grab pid and capture owner in array
  pid=$!
  generic_msg_colour_simple "info-indented" "pid id:      ${yellow}${pid}${reset}"
  pod_build_execute_pid_array["${pid}"]="${tag};${pubIp}"
  runBuild_pids+=" $pid"

# -----

  # print out pids

  if [[ "${runBuild_pids_print}" ]]; then
    runBuild_pids_print="${runBuild_pids_print},$pid"
  else
    runBuild_pids_print="$!"
  fi
  printf "\n%s"

done

# -----

generic_msg_colour_simple "info-bold" "awaiting ssh pids:${reset}"
generic_msg_colour_simple "info" "${yellow}$runBuild_pids${reset}"
printf "\n%s"

# -----

# Wait for all processes to finish

runBuild_pid_failures=""
printf "%s" ${red}  # any scp error messages
for p in $runBuild_pids; do
  if wait $p; then
    printf "%s\n" "${green}Process $p success${reset}"
  else
    printf "%s\n" "${red}Process $p fail${reset}"
    runBuild_pid_failures+=" ${p}"
  fi
done
}

#-------------------------------------------

function task_pod_execute_build_remotely_report(){

generic_msg_colour_simple "REPORT" "STAGE SUMMARY"                                                                      && sleep "${STEP_PAUSE}"

if [[ ! -z $runBuild_pid_failures ]]; then
  generic_msg_colour_simple "info-indented" "${cross} Problems executing 'pod' on servers"                              && sleep "${STEP_PAUSE}"
  printf "%s\n"
  for k in "${!pod_build_execute_pid_array[@]}"
  do
    if [[ "${runBuild_pid_failures}" == *"$k"* ]]; then
      generic_parameter_expansion_delimeter "${pod_build_execute_pid_array[$k]}" ";" "1"
      server="$_D1_"
      ip=$_D2_
      generic_msg_colour_simple "error-tight" "pid ${yellow}${k}${red} failed for ${yellow}${server}@${ip}${red}"
    fi
  done
  printf "%s\n"
else
  generic_msg_colour_simple "success" "Executed pod builds on all servers"                                              && sleep "${STEP_PAUSE}"
fi
}
