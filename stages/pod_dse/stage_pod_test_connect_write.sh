#!/bin/bash

# script_name:   stage_pod_test_connect_write.sh
# author:        jondowson
# about:         test connectivity and write-path availability for all servers

#-------------------------------------------

function task_pod_test_connect(){

## for each server test ssh connectivity + authorisation

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

function task_pod_test_connect_report(){

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
  pod_generic_display_msgColourSimple "info-bold" "--> ${red}Connection errors report:"                                                    && sleep "${STEP_PAUSE}"
  printf "%s\n"
  for k in "${pod_test_connect_report_array[@]}"
  do
    pod_generic_display_msgColourSimple "info" "${cross} ${k}"
  done
  printf "%s\n"
  pod_generic_display_msgColourSimple "error" "Aborting script as not all servers are reachable"
  exit 1;
else
  pod_generic_display_msgColourSimple "success" "Connectivity test passed for all servers"                                                 && sleep "${STEP_PAUSE}"
fi
}

#-------------------------------------------

function task_pod_test_write(){

## for each server test ability to write to all required dse paths (data, logs etc)

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

  if [ $VB == true ]; then pod_generic_display_msgColourSimple "info-indented" "editing:     'LOCAL_TARGET_FOLDER' in 'cluster_settings.sh'"; fi
  pod_generic_misc_sedStringManipulation "editAfterSubstring" "${tmp_build_file_path}"   "LOCAL_TARGET_FOLDER=" "\"${target_folder}\""
  source ${tmp_build_file_path}

# ----------

  pod_generic_display_msgColourSimple "info" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"
  pod_generic_display_msgColourSimple "info-indented" "configuring:    bespoke server paths"                                               && sleep ${STEP_PAUSE}
  pod_generic_display_msgColourSimple "info-indented" "writing-to:     bespoke server paths"
  printf "%s\n" "${red}"

  declare -a mkdir_array
  mkdir_array[0]="${target_folder}"
  mkdir_array[1]="${cassandra_log_folder}"
  mkdir_array[2]="${gremlin_log_folder}"
  mkdir_array[3]="${tomcat_log_folder}"
  mkdir_array[4]="${spark_master_log_folder}"
  mkdir_array[5]="${spark_worker_log_folder}"
  mkdir_array[6]="${commitlog_directory}"
  mkdir_array[7]="${cdc_raw_directory}"
  mkdir_array[8]="${saved_caches_directory}"
  mkdir_array[9]="${hints_directory}"
  mkdir_array[10]="${Djava_tmp_folder}"
  mkdir_array[11]="${dsefs_untar_folder}"
  mkdir_array[12]="${spark_local_data}"
  mkdir_array[13]="${spark_worker_data}"
  mkdir_array[14]="${java_untar_folder}"

# ----------

  for i in "${mkdir_array[@]}"
  do
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "[ ! -d ${i} ] && mkdir -p ${i} && rm -rf ${i} || mkdir ${i}dummyFolder && rm -rf ${i}dummyFolder" exit
        status=${?}
        pod_test_send_error_array_1["${i}"]="${status};${tag}"
        ((retry++))
      done
    fi
  done

# ----------

  for i in "${data_file_directories_array[@]}"
  do
    pod_generic_misc_expansionDelimiter "$i" ";" "2";
    writeFolder="${_D1_}"
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "[ ! -d ${writeFolder} ] && mkdir -p ${writeFolder} && rm -rf ${writeFolder} || mkdir ${writeFolder}dummyFolder && rm -rf ${writeFolder}dummyFolder" exit
        status=${?}
        pod_test_send_error_array_2["${i}"]="${status};${tag}"
        ((retry++))
      done
    fi
  done

# ----------

  for i in "${dsefs_data_file_directories_array[@]}"
  do
  pod_generic_misc_expansionDelimiter "$i" ";" "2";
  writeFolder="${_D1_}"
  status="999"
  if [[ "${status}" != "0" ]]; then
    retry=0
    until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
    do
      ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "[ ! -d ${writeFolder} ] && mkdir -p ${writeFolder} && rm -rf ${writeFolder} || mkdir ${writeFolder}dummyFolder && rm -rf ${writeFolder}dummyFolder" exit
      status=${?}
      pod_test_send_error_array_3["${i}"]="${status};${tag}"
      ((retry++))
    done
  fi
  done

ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "[ -d ${INSTALL_FOLDER} ] && rm -rf ${INSTALL_FOLDER}" exit
done
}

#-------------------------------------------

function task_pod_test_write_report(){

## generate a report of all failed write-path attempts
declare -a pod_test_send_report_array_1
count=0
for k in "${!pod_test_send_error_array_1[@]}"
do
  pod_generic_misc_expansionDelimiter ${pod_test_send_error_array_1[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_test_send_fail="true"
    pod_test_send_report_array_1["${count}"]="could not make folder: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# ----------

declare -a pod_test_send_report_array_2
count=0
for k in "${!pod_test_send_error_array_2[@]}"
do
  pod_generic_misc_expansionDelimiter ${pod_test_send_error_array_2[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_test_send_fail="true"
    pod_test_send_report_array_2["${count}"]="could not make folder: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# ----------

declare -a pod_test_send_report_array_3
count=0
for k in "${!pod_test_send_error_array_3[@]}"
do
  pod_generic_misc_expansionDelimiter ${pod_test_send_error_array_3[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_test_send_fail="true"
    pod_test_send_report_array_3["${count}"]="could not make folder: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# ----------

if [[ "${pod_test_send_fail}" == "true" ]]; then
  printf "%s\n"
  pod_generic_display_msgColourSimple "info-bold" "--> ${red}Write-paths error report:"                                           && sleep "${STEP_PAUSE}"
  printf "%s\n"

  for k in "${pod_test_send_report_array_1[@]}"
  do
    pod_generic_display_msgColourSimple "info" "${cross} ${k}"
  done
  printf "%s\n"

  for k in "${pod_test_send_report_array_2[@]}"
  do
    pod_generic_display_msgColourSimple "info" "${cross} ${k}"
  done

  for k in "${pod_test_send_report_array_3[@]}"
  do
    pod_generic_display_msgColourSimple "info" "${cross} ${k}"
  done
  pod_generic_display_msgColourSimple "error" "Aborting script as not all paths are writeable"
  exit 1;
else
  pod_generic_display_msgColourSimple "success" "Write-paths test passed for all servers"                                         && sleep "${STEP_PAUSE}"
fi
}
