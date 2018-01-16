# about:    test write-paths for all servers in servers json definition

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

# -----

  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

# -----

  TARGET_FOLDER="${target_folder}"
  source ${tmp_build_settings_file_path}

# -----

  lib_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"
  lib_generic_display_msgColourSimple "INFO-->" "configuring:    bespoke server paths"
  lib_generic_display_msgColourSimple "INFO-->" "writing-to:     bespoke server paths"
  printf "%s\n" "${red}"

  declare -a mkdir_array
  mkdir_array[0]="${INSTALL_FOLDER_POD}"

# -----

  for i in "${mkdir_array[@]}"
  do
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "mkdir -p ${i}dummyFolder && rm -rf ${i}dummyFolder" exit
        status=${?}
        pod_test_write_error_array["${i}"]="${status};${tag}"
        ((retry++))
      done
    fi
  done

done
}

# -------------------------------------------

function task_testWritePaths_report(){

## generate a report of all failed write-path attempts

lib_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Test write paths on each server"

declare -a pod_test_send_report_array
count=0
for k in "${!pod_test_write_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${pod_test_write_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_test_write_fail="true"
    pod_test_send_report_array["${count}"]="could not make folder: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# -----

if [[ "${pod_test_write_fail}" == "true" ]]; then
  printf "%s\n"
  lib_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}Write-paths error report:"
  printf "%s\n"

  for k in "${pod_test_send_report_array[@]}"
  do
    lib_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
  printf "%s\n"
  lib_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  exit 1;
else
  lib_generic_display_msgColourSimple "SUCCESS" "Write-paths test passed for all servers"
fi
}
