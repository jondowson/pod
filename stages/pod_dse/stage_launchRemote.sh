#!/bin/bash

# author:        jondowson
# about:         run 'pod_launch_remote.sh' on each server in the cluster

#-------------------------------------------

function task_launchRemote(){

for id in `seq 1 ${numberOfServers}`;
do

  tag=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.tag'            | tr -d '"')
  user=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.user'           | tr -d '"')
  sshKey=$(cat ${servers_json_path}        | ${jq_folder}jq '.server_'${id}'.sshKey'         | tr -d '"')
  target_folder=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.target_folder'  | tr -d '"')
  pubIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.pubIp'          | tr -d '"')
  prvIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.prvIp'          | tr -d '"')
  listen_address=$(cat ${servers_json_path}| ${jq_folder}jq '.server_'${id}'.listen_address' | tr -d '"')
  rpc_address=$(cat ${servers_json_path}   | ${jq_folder}jq '.server_'${id}'.rpc_address'    | tr -d '"')
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
  target_folder=$(pod_generic_strings_addTrailingSlash "${target_folder}")

# -----

  pod_generic_display_msgColourSimple "info" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"

  pod_generic_display_msgColourSimple "info-indented" "launch:      pod remotely"
  ssh -ttq -o "BatchMode yes" -o "ForwardX11=no" ${user}@${pubIp} "chmod -R 700 ${target_folder}pod && ${target_folder}pod/lib/pod_dse/pod_dse_script_launch_remote.sh" &                # run in parallel
  # grab pid and capture owner in array
  pid=$!
  pod_generic_display_msgColourSimple "info-indented" "pid id:      ${yellow}${pid}${reset}"
  pod_build_launch_pid_array["${pid}"]="${tag};${pubIp}"
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

pod_generic_display_msgColourSimple "info-bold" "awaiting ssh pids:${reset}"
pod_generic_display_msgColourSimple "info" "${yellow}$runBuild_pids${reset}"
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

function task_launchRemote_report(){

pod_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Launch Pod On Each Server"

if [[ ! -z $runBuild_pid_failures ]]; then
  pod_generic_display_msgColourSimple "info-indented" "${cross} Problems executing 'pod' on servers"
  printf "%s\n"
  for k in "${!pod_build_launch_pid_array[@]}"
  do
    if [[ "${runBuild_pid_failures}" == *"$k"* ]]; then
      pod_generic_strings_expansionDelimiter "${pod_build_launch_pid_array[$k]}" ";" "1"
      server="$_D1_"
      ip=$_D2_
      pod_generic_display_msgColourSimple "error-tight" "pid ${yellow}${k}${red} failed for ${yellow}${server}@${ip}${red}"
    fi
  done
  printf "%s\n"
else
  pod_generic_display_msgColourSimple "success" "Executed pod builds on all servers"                                                                 
fi
}
