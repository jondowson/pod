#!/bin/bash

# author:        jondowson
# about:         for each server build and then send a configured version of pod

#-------------------------------------------

function task_buildSend(){

## for each server configure a pod build and then send it

for id in $(seq 1 ${numberOfServers});
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
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

# -----

  lib_generic_display_msgColourSimple "info" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"

# -----

# establish os on remote machine
remote_os=$(ssh -q -o Forwardx11=no ${user}@${pubIp} 'bash -s' < ${pod_home_path}/pods/pod_/scripts/scripts_generic_identifyOs.sh)
lib_generic_display_msgColourSimple   "info-indented" "detected os: ${green}${remote_os}${reset}"
# -----

  lib_generic_display_msgColourSimple "info-indented" "making:      bespoke pod build"

  if [[ "${VB}" == "true" ]]; then printf "%s\n"; fi
  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "renaming:    'cassandra-topology.properties' to stop it interfering"; fi
  lib_doStuff_locally_cassandraTopologyProperties

  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'TARGET_FOLDER' in 'build_settings.sh'"; fi
  lib_generic_strings_sedStringManipulation "editAfterSubstring" "${tmp_build_file_path}"   "TARGET_FOLDER=" "\"${target_folder}\""
  source ${tmp_build_file_path}

  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'build_folder_path' in 'pod_launch_remote.sh'"; fi
  lib_generic_strings_sedStringManipulation "editAfterSubstring" "${tmp_build_folder}pods/pod_/scripts/scripts_generic_launchPodRemotely.sh" "build_folder_path=" "\"${target_folder}pod/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/\""

  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'cassandra-env.sh'"; fi
  lib_doStuff_locally_cassandraEnv
  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'jvm.options'"; fi
  lib_doStuff_locally_jvmOptions
  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'main' settings for 'cassandra.yaml'"; fi
  lib_doStuff_locally_cassandraYaml
  
  if [[ "${analytics}" == "true" ]] || [[ "${dsefs}" == "true" ]]; then
    if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'dse.yaml'"; fi
    lib_doStuff_locally_dseYamlDsefs
  fi
  
  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'dse-spark-env.sh'"; fi
  lib_doStuff_locally_dseSparkEnv
  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'rackdc.properties'"; fi
  lib_doStuff_locally_cassandraRackDcProperties
  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'lib_script_launchRemotely'"; fi
  prepare_generic_misc_hashBang

# -----


  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "adding:       'cassandra_data_folders' in 'build_settings.sh'"; fi

  # calculate number of cassandra data folders specified in json
  # -3? - one for each bracket line and another 'cos the array starts at zero
  numberOfDataFolders=$(($(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.cass_data' | wc -l)-3))

# remove all added data arrays from previous loop
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" "${tmp_build_file_path}" "dse_data_arrays" ""

# CAT/EOF cannot be indented !!
cat << EOF >> "${tmp_build_file_path}"
#BOF CLEAN-dse_data_arrays
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

  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'cassandra_data_folders' in 'cassandra.yaml'"; fi
  declare -a data_file_directories_array
  for j in `seq 0 ${numberOfDataFolders}`;
  do
    data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.cass_data['${j}']' | tr -d '"')
    data_file_directories_array[${j}]=${data_path}
  done
  lib_doStuff_locally_cassandraYamlData

# -----

  if [[ "${analytics}" == "true" ]] || [[ "${dsefs}" == "true" ]]; then

    if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "adding:       'dsefs_data_folders' in 'build_settings.sh'"; fi

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
printf "%s" "#EOF CLEAN-dse_data_arrays" >> "${tmp_build_file_path}"
  fi
  
# -----

  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "editing:     'dsefs_data_folders' in 'dse.yaml'"; fi

  declare -a dsefs_data_file_directories_array
  for j in `seq 0 ${numberOfDataFolders}`;
  do
    data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.dsefs_data['${j}']' | tr -d '"')
    dsefs_data_file_directories_array[${j}]=${data_path}
  done
  lib_doStuff_locally_dseYamlDsefs

# -----

  # set node specific settings for 'seeds:' and 'listen_address:'
  if [[ "${VB}" == "true" ]]; then lib_generic_display_msgColourSimple "info-indented" "setting:     'seeds:' and 'listen_address:' in cassandra.yaml"; fi
  if [[ "${listen_address}" == "pubIp" ]]; then
    listen_address=${pubIp}
  else
    listen_address=${prvIp}
  fi
  lib_doStuff_locally_cassandraYamlNodeSpecific
  if [[ "${VB}" == "true" ]]; then printf "%s\n"; fi

# -----

  lib_generic_display_msgColourSimple "info-indented" "sending:     bespoke pod build"
  printf "%s\n" "${red}"
  # folder must first exist on target machine !!!!!!
  ssh -o ForwardX11=no ${user}@${pubIp} "mkdir -p ${target_folder} && rm -rf ${target_folder}pod"
  scp -q -o LogLevel=QUIET -i ${sshKey} -r "${tmp_working_folder}" "${user}@${pubIp}:${target_folder}"
  status=${?}
  pod_build_send_error_array["${tag}"]="${status};${pubIp}"
done
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
  lib_generic_display_msgColourSimple "info-bold" "--> ${red}Write build error report:"
  printf "%s\n"

  for k in "${pod_build_send_report_array[@]}"
  do
    lib_generic_display_msgColourSimple "info-bold" "${cross} ${k}"
  done
  printf "%s\n"
  lib_generic_display_msgColourSimple "error" "Aborting script as not all paths are writeable"
  exit 1;
else
  lib_generic_display_msgColourSimple "success" "Created and distributed pod builds on all servers"
fi
}
