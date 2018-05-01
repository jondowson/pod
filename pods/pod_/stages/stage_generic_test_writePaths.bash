# about:    test write-paths for all servers in servers json definition

# -------------------------------------------

function task_generic_testWritePaths(){

## for each server test ability to write to all required dse paths (data, logs etc)

# if json contains nested paths to test, these will have been passed in
buildPathsWriteTest="${1}"
jsonPathsWriteTest="${2}"

for id in $(seq 1 ${numberOfServers});
do
  # [1] assign json variable to bash variables
  tag=$(jq             -r '.server_'${id}'.tag'             "${servers_json_path}")
  user=$(jq            -r '.server_'${id}'.user'            "${servers_json_path}")
  sshKey=$(jq          -r '.server_'${id}'.sshKey'          "${servers_json_path}")
  target_folder=$(jq   -r '.server_'${id}'.target_folder'   "${servers_json_path}")
  pubIp=$(jq           -r '.server_'${id}'.pubIp'           "${servers_json_path}")
  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

  # [2] source the build_settings file after assigning the target_folder for the current server in the loop
  TARGET_FOLDER="${target_folder}"
  source "${tmp_build_settings_file_path}"

  # [3] determine remote server os
  lib_generic_doStuff_remotely_identifyOs

  # [4] display message
  prepare_generic_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}$pubIp${white} on os ${yellow}${remote_os}${reset}" #&& printf "\n%s"
  prepare_generic_display_msgColourSimple "INFO-->" "testing write-paths:"
  #printf "%s\n" "${red}"

  # [5] test all buildFolderPaths
  # delimit the buildFolderPaths string into an array
  # prepend the target_folder for this server and append the build_settings specific paths to test
  buildFolderPaths="target_folder;${buildPathsWriteTest}"
  lib_generic_strings_ifsStringDelimeter ";" "${buildFolderPaths}"

  # for each element in the array
  for folder in "${array[@]}"
  do
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "mkdir -p ${!folder}dummyFolder && rm -rf ${!folder}dummyFolder" exit
        status=${?}
        test_write_error_array_1["${!folder}"]="${status};${tag}"
        ((retry++))
      done
    fi
  done

  # [6] test json elements that have nested paths - these will be passed here as a delimited string
  # e.g. "cass_data;dsefs_data"
  if [[ ${jsonPathsWriteTest} != "" ]]; then
    # delimit the json element(s) into an array
    lib_generic_strings_ifsStringDelimeter ";" "${jsonPathsWriteTest}"
    # for each element in the array e.g. cass_data
    for element in "${array[@]}"
    do
      # write test this element's nested path(s)
      lib_generic_json_writePathTest ";" "${element}"
    done
  fi
done
}

# -------------------------------------------

function task_generic_testWritePaths_report(){

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

if [[ "${test_write_fail}" == "true" ]]; then
  printf "%s\n"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}write-paths error report:"
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

  prepare_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  prepare_generic_misc_clearTheDecks && exit 1;
else
  prepare_generic_display_msgColourSimple "SUCCESS" "ALL SERVERS:  write-path test passed"
fi
}
