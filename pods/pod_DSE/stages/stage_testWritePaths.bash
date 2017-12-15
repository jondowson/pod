# author:        jondowson
# about:         test write-paths for all servers in servers json definition

# -------------------------------------------

function task_testWritePaths(){

## for each server test ability to write to all required dse paths (data, logs etc)

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

# ----------

  # use the 'suitcase' as a means of refreshing the build_settings.bash variables
  # note this stage does not send the suitcase to the remote server
  printf "%s\n" "TARGET_FOLDER=${target_folder}" > "${tmp_suitcase_file_path}"
  source "${tmp_build_settings_file_path}"

# ----------

  lib_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"
  lib_generic_display_msgColourSimple "INFO-->" "configuring:    bespoke server paths"
  lib_generic_display_msgColourSimple "INFO-->" "writing-to:     bespoke server paths"
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
  mkdir_array[10]="${dsefs_untar_folder}"
  mkdir_array[11]="${spark_local_data}"
  mkdir_array[12]="${spark_worker_data}"

# ----------

  for i in "${mkdir_array[@]}"
  do
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "mkdir -p ${i}dummyFolder && rm -rf ${i}dummyFolder" exit
        status=${?}
        pod_test_send_error_array_1["${i}"]="${status};${tag}"
        ((retry++))
      done
    fi
  done

# ----------

  # calculate number of cassandra data folders specified in json
  # -3? - one for each bracket line and another 'cos the array starts at zero
  numberOfDataFolders=$(($(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.cass_data' | wc -l)-3))

  declare -a data_file_directories_array
  for j in $(seq 0 ${numberOfDataFolders});
  do
    data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.cass_data['${j}']' | tr -d '"')
    data_file_directories_array[${j}]=${data_path}
  done

  for i in "${data_file_directories_array[@]}"
  do
    lib_generic_strings_expansionDelimiter "$i" ";" "2";
    writeFolder="${_D1_}"
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "mkdir -p ${writeFolder}dummyFolder && rm -rf ${writeFolder}dummyFolder" exit
        status=${?}
        pod_test_send_error_array_2["${writeFolder}"]="${status};${tag}"
        ((retry++))
      done
    fi
  done

# ----------

  if [[ "${analytics}" == "true" ]] || [[ "${dsefs}" == "true" ]]; then

    # calculate number of cassandra data folders specified in json
    # -3? - one for each bracket line and another 'cos the array starts at zero
    numberOfDataFolders=$(($(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.dsefs_data' | wc -l)-3))

    declare -a dsefs_data_file_directories_array
    for j in $(seq 0 ${numberOfDataFolders});
    do
      data_path=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.dsefs_data['${j}']' | tr -d '"')
      dsefs_data_file_directories_array[${j}]=${data_path}
    done

    for i in "${dsefs_data_file_directories_array[@]}"
    do
    lib_generic_strings_expansionDelimiter "$i" ";" "2";
    writeFolder="${_D1_}"
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "mkdir -p ${writeFolder}dummyFolder && rm -rf ${writeFolder}dummyFolder" exit
        status=${?}
        pod_test_send_error_array_3["${writeFolder}"]="${status};${tag}"
        ((retry++))
      done
    fi
    done
  fi
done
}

# -------------------------------------------

function task_testWritePaths_report(){

## generate a report of all failed write-path attempts
declare -a pod_test_send_report_array_1
count=0
for k in "${!pod_test_send_error_array_1[@]}"
do
  lib_generic_strings_expansionDelimiter ${pod_test_send_error_array_1[$k]} ";" "1"
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
  lib_generic_strings_expansionDelimiter ${pod_test_send_error_array_2[$k]} ";" "1"
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
  lib_generic_strings_expansionDelimiter ${pod_test_send_error_array_3[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_test_send_fail="true"
    pod_test_send_report_array_3["${count}"]="could not make folder: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# ----------

if [[ "${pod_test_send_fail}" == "true" ]]; then
  printf "%s\n"
  lib_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}Write-paths error report:"
  printf "%s\n"

  for k in "${pod_test_send_report_array_1[@]}"
  do
    lib_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
  printf "%s\n"

  for k in "${pod_test_send_report_array_2[@]}"
  do
    lib_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done

  for k in "${pod_test_send_report_array_3[@]}"
  do
    lib_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
  lib_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  prepare_generic_misc_clearTheDecks && exit 1;
else
  lib_generic_display_msgColourSimple "SUCCESS" "Write-paths test passed for all servers"
fi
}
