#!/bin/bash

# script_name:   stage_pod_build_send.sh
# author:        jondowson
# about:         for each server build and then send a configured version of pod  

#-------------------------------------------

function task_pod_build_send(){

## for each server configure a pod build and then send it 

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

# -----

  generic_msg_colour_simple "info-indented" "making:      bespoke pod build"                                              && sleep ${STEP_PAUSE}

  if [ $VB == true ]; then printf "%s\n"; fi
  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "renaming:    'cassandra-topology.properties' to stop it interfering"; fi
  pod_local_rename_cassandra-topology.properties

  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "editing:     'LOCAL_TARGET_FOLDER' in 'cluster_settings.sh'"; fi
  generic_sed_string_manipulation "editAfterSubstring" "${tmp_build_file_path}"   "LOCAL_TARGET_FOLDER=" "\"${target_folder}\""
  source ${tmp_build_file_path}

  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "editing:     'build_folder_path' in 'pod_launch_remote.sh'"; fi
  generic_sed_string_manipulation "editAfterSubstring" "${tmp_build_folder}misc/pod_dse/pod_launch_remote.sh" "build_folder_path=" "\"${target_folder}pod/builds/pod_dse/${BUILD_FOLDER}/\""

  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "editing:     'cassandra-env.sh'"; fi
  pod_local_configure_cassandra-env.sh
  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "editing:     'jvm.options'"; fi
  pod_local_configure_jvm.options
  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "editing:     'main' settings for 'cassandra.yaml'"; fi
  pod_local_configure_cassandra.yaml
  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "editing:     'dse.yaml'"; fi
  pod_local_configure_dsefs_dse.yaml
  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "editing:     'dse-spark-env.sh'"; fi
  pod_local_configure_dse-spark-env.sh

# -----


  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "adding:       'cassandra_data_folders' in 'cluster_settings.sh'"; fi

  # calculate number of cassandra data folders specified in json
  # -3? - one for each bracket line and another 'cos the array starts at zero
  numberOfDataFolders=$(($(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.cass_data' | wc -l)-3))

# CAT/EOF cannot be indented !!
cat << EOF >> "${tmp_build_file_path}"
# _________________
# ADDED DYNAMICALLY
#
declare -a data_file_directories_array
EOF

for j in `seq 0 ${numberOfDataFolders}`;
do
data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.cass_data['${j}']' | tr -d '"')
cat << EOF >> "${tmp_build_file_path}"
data_file_directories_array[${j}]="${data_path}"
EOF
done

# -----

  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "editing:     'cassandra_data_folders' in 'cassandra.yaml'"; fi
  declare -a data_file_directories_array
  for j in `seq 0 ${numberOfDataFolders}`;
  do
    data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.cass_data['${j}']' | tr -d '"')
    data_file_directories_array[${j}]=${data_path}
  done
  pod_local_configure_cassandraYamlData

# -----

  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "adding:       'dsefs_data_folders' in 'cluster_settings.sh'"; fi

  # calculate number of cassandra data folders specified in json
  # -3? - one for each bracket line and another 'cos the array starts at zero
  numberOfDataFolders=$(($(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.dsefs_data' | wc -l)-3))

# CAT/EOF cannot be indented !!
cat << EOF >> "${tmp_build_file_path}"
# _________________
# ADDED DYNAMICALLY
#
declare -a dsefs_data_file_directories_array
EOF

for j in `seq 0 ${numberOfDataFolders}`;
do
data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.dsefs_data['${j}']' | tr -d '"')
cat << EOF >> "${tmp_build_file_path}"
dsefs_data_file_directories_array[${j}]="${data_path}"
EOF
done

# -----

  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "editing:     'dsefs_data_folders' in 'dse.yaml'"; fi

  declare -a dsefs_data_file_directories_array
  for j in `seq 0 ${numberOfDataFolders}`;
  do
    data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.dsefs_data['${j}']' | tr -d '"')
    dsefs_data_file_directories_array[${j}]=${data_path}
  done
  pod_local_configure_dsefs_dse.yaml

# -----

  # set node specific settings for 'seeds:' and 'listen_address:'
  if [ $VB == true ]; then generic_msg_colour_simple "info-indented" "setting:     'seeds:' and 'listen_address:' in cassandra.yaml"; fi
  if [[ "${listen_address}" == "pubIp" ]]; then
    listen_address=${pubIp}
  else
    listen_address=${prvIp}
  fi
  pod_local_node_specific_configure_cassandra.yaml
  if [ $VB == true ]; then printf "%s\n"; fi

# -----

  generic_msg_colour_simple "info-indented" "sending:     bespoke pod build"
  printf "%s\n" "${red}"
  # folder must first exist on target machine !!!!!!
  ssh -o ForwardX11=no ${user}@${pubIp} "mkdir -p ${target_folder}"
  scp -q -o LogLevel=QUIET -i ${sshKey} -r "${tmp_working_folder}" "${user}@${pubIp}:${target_folder}"
  status=${?}
  pod_build_send_error_array["${tag}"]="${status};${pubIp}"
done
}

#-------------------------------------------

function task_pod_build_send_report(){

## generate a report of all failed sends of pod build

generic_msg_colour_simple "REPORT" "STAGE SUMMARY: ${reset}Create Pod For Each Server"                                  && sleep "${STEP_PAUSE}"

declare -a pod_build_send_report_array
count=0
for k in "${!pod_build_send_error_array[@]}"
do
  generic_parameter_expansion_delimeter ${pod_build_send_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_build_send_fail="true"
    pod_build_send_report_array["${count}"]="could not transfer: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# -----

if [[ "${pod_build_send_fail}" == "true" ]]; then
  printf "%s\n"
  generic_msg_colour_simple "info-bold" "--> ${red}Write build error report:"                                           && sleep "${STEP_PAUSE}"
  printf "%s\n"
  
  for k in "${pod_build_send_report_array[@]}"
  do
    g  generic_msg_colour_simple "info-bold" "${cross} ${k}"                                                            && sleep "${STEP_PAUSE}"
  done
  printf "%s\n"
  generic_msg_colour_simple "error" "Aborting script as not all paths are writeable"
  exit 1;
else
  generic_msg_colour_simple "success" "Created and distributed pod builds on all servers"                               && sleep "${STEP_PAUSE}"
fi
}
