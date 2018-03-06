# about:    test write-paths for all servers in servers json definition

# -------------------------------------------

function task_testWritePaths(){

## for each server test ability to write to all required dse paths (data, logs etc)

for id in $(seq 1 ${numberOfServers});
do

  tag=$(jq             -r '.server_'${id}'.tag'             "${servers_json_path}")
  user=$(jq            -r '.server_'${id}'.user'            "${servers_json_path}")
  sshKey=$(jq          -r '.server_'${id}'.sshKey'          "${servers_json_path}")
  target_folder=$(jq   -r '.server_'${id}'.target_folder'   "${servers_json_path}")
  pubIp=$(jq           -r '.server_'${id}'.pubIp'           "${servers_json_path}")
  listen_address=$(jq  -r '.server_'${id}'.listen_address'  "${servers_json_path}")
  rpc_address=$(jq     -r '.server_'${id}'.rpc_address'     "${servers_json_path}")
  stomp_interface=$(jq -r '.server_'${id}'.stomp_interface' "${servers_json_path}")
  seeds=$(jq           -r '.server_'${id}'.seeds'           "${servers_json_path}")
  token=$(jq           -r '.server_'${id}'.token'           "${servers_json_path}")
  dc=$(jq              -r '.server_'${id}'.dc'              "${servers_json_path}")
  rack=$(jq            -r '.server_'${id}'.rack'            "${servers_json_path}")
  search=$(jq          -r '.server_'${id}'.mode.search'     "${servers_json_path}")
  analytics=$(jq       -r '.server_'${id}'.mode.analytics'  "${servers_json_path}")
  graph=$(jq           -r '.server_'${id}'.mode.graph'      "${servers_json_path}")
  dsefs=$(jq           -r '.server_'${id}'.mode.dsefs'      "${servers_json_path}")

# ----------

  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

# ----------

  TARGET_FOLDER="${target_folder}"
  source "${tmp_build_settings_file_path}"

# ----------

  prepare_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"
  prepare_generic_display_msgColourSimple "INFO-->" "configuring:    bespoke server paths"
  prepare_generic_display_msgColourSimple "INFO-->" "writing-to:     bespoke server paths"
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
  mkdir_array[13]="${TEMP_FOLDER}"
  mkdir_array[14]="${PARENT_DATA_FOLDER}"
  mkdir_array[15]="${PARENT_LOG_FOLDER}"

# ----------

  for folder in "${mkdir_array[@]}"
  do
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "mkdir -p ${folder}dummyFolder && rm -rf ${folder}dummyFolder" exit
        status=${?}
        test_write_error_array_1["${folder}"]="${status};${tag}"
        ((retry++))
      done
    fi
  done

# ----------

  # if path contains ${BUILD_FOLDER} variable then substitute in the user supplied value
  # for cassandra data folders - specified in json file
  folders=$(jq -r --arg bf "${BUILD_FOLDER}" '.server_'${id}'.cass_data[] | sub("\\${BUILD_FOLDER}";$bf)' "${servers_json_path}")
  #while read -r folder
  for folder in ${folders}
  do
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "mkdir -p ${folder}dummyFolder && rm -rf ${folder}dummyFolder" exit
        status=${?}
        test_write_error_array_2[${folder}]="${status};${tag}"
        ((retry++))
      done
    fi
  done

# ----------

  if [[ "${analytics}" == "true" ]] || [[ "${dsefs}" == "true" ]]; then

    # if path contains ${BUILD_FOLDER} variable then substitute in the user supplied value
    # for dsefs data folders - specified in json file
    folders=$(jq -r --arg bf "${BUILD_FOLDER}" '.server_'${id}'.dsefs_data[] | sub("\\${BUILD_FOLDER}";$bf)' "${servers_json_path}")
    #while read -r folder
    for folder in ${folders}
    do
      lib_generic_strings_expansionDelimiter "$folder" ";" "2";
      folder="${_D1_}"
      status="999"
      if [[ "${status}" != "0" ]]; then
        retry=0
        until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
        do
          ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "mkdir -p ${folder}dummyFolder && rm -rf ${folder}dummyFolder" exit
          status=${?}
          test_write_error_array_3[${folder}]="${status};${tag}"
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
declare -a test_send_report_array_1
count=0
for k in "${!test_send_error_array_1[@]}"
do
  lib_generic_strings_expansionDelimiter ${test_send_error_array_1[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    test_write_fail="true"
    test_write_report_array_1["${count}"]="could not make folder: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# ----------

declare -a test_send_report_array_2
count=0
for k in "${!test_send_error_array_2[@]}"
do
  lib_generic_strings_expansionDelimiter ${test_send_error_array_2[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    test_write_fail="true"
    test_write_report_array_2["${count}"]="could not make folder: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# ----------

declare -a test_send_report_array_3
count=0
for k in "${!test_send_error_array_3[@]}"
do
  lib_generic_strings_expansionDelimiter ${test_send_error_array_3[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    test_write_fail="true"
    test_write_report_array_3["${count}"]="could not make folder: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# ----------

if [[ "${test_write_fail}" == "true" ]]; then
  printf "%s\n"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}Write-paths error report:"
  printf "%s\n"

  for k in "${test_write_report_array_1[@]}"
  do
    prepare_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
  printf "%s\n"

  for k in "${test_write_report_array_2[@]}"
  do
    prepare_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done

  for k in "${test_write_report_array_3[@]}"
  do
    prepare_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
  prepare_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  prepare_generic_misc_clearTheDecks && exit 1;
else
  prepare_generic_display_msgColourSimple "SUCCESS" "Write-paths test passed for all servers"
fi
}
