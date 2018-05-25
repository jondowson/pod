function GENERIC_task_testWritePaths(){

## for each server test ability to write to all required dse paths (data, logs etc)

# if json contains nested paths to test, these will have been passed in
BUILDPATHS_WRITETEST="${1}"
JSONPATHS_WRITETEST="${2}"

for id in $(seq 1 ${numberOfServers});
do

  # [1] for this server, loop through its json block and assign values to bash variables
  GENERIC_lib_json_assignValue;
  for key in "${!arrayJson[@]}"
  do
    declare $key=${arrayJson[$key]} &>/dev/null;
  done;
  # add trailing '/' to target_folder path if not present
  target_folder="$(GENERIC_lib_strings_addTrailingSlash ${target_folder})";

  # [2] source the build_settings file after assigning the target_folder for the current server in the loop
  TARGET_FOLDER="${target_folder}"
  source "${TMP_FILE_BUILDSETTINGS}"

  # [3] determine remote server os
  GENERIC_lib_doStuffRemotely_identifyOs

  # [4] display message
  GENERIC_prepare_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}$pub_ip${white} on os ${yellow}${remote_os}${reset}"

  # [5] test all buildFolderPaths
  # delimit the buildFolderPaths string into an array
  # prepend the target_folder for this server and append the build_settings specific paths to test
  buildFolderPaths="target_folder;${BUILDPATHS_WRITETEST}"
  GENERIC_lib_strings_ifsStringDelimeter ";" "${buildFolderPaths}"

  # for each element in the array
  for folder in "${array[@]}"
  do
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        GENERIC_prepare_display_msgColourSimple "INFO-->" "${!folder}"
        ssh -q -o ForwardX11=no -i ${ssh_key} ${user}@${pub_ip} "mkdir -p ${!folder}dummyFolder && rm -rf ${!folder}dummyFolder" exit
        status=${?}
        arrayTestWrite1["${!folder}"]="${status};${tag}"
        ((retry++))
      done
    fi
  done

  # [6] test json elements that have nested paths - these will be passed here as a delimited string
  # e.g. "cass_data;dsefs_data"
  if [[ ${JSONPATHS_WRITETEST} != "" ]]; then
    # delimit the json element(s) into an array
    GENERIC_lib_strings_ifsStringDelimeter ";" "${JSONPATHS_WRITETEST}"
    # for each element in the array e.g. cass_data
    for element in "${array[@]}"
    do
      # write test this element's nested path(s)
      GENERIC_lib_json_writePathTest ";" "${element}"
    done
  fi
done
}

# -------------------------------------------

function GENERIC_task_testWritePaths_report(){

## generate a report of all failed write-path attempts
declare -a test_send_report_array_1
count=0
for k in "${!test_send_error_array_1[@]}"
do
  GENERIC_lib_strings_expansionDelimiter ${test_send_error_array_1[$k]} ";" "1"
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
  GENERIC_lib_strings_expansionDelimiter ${test_send_error_array_2[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    test_write_fail="true"
    test_write_report_array_2["${count}"]="could not make folder: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# ----------

if [[ "${test_write_fail}" == "true" ]]; then
  printf "%s\n"
  GENERIC_prepare_display_msgColourSimple "INFO-BOLD" "--> ${red}write-paths error report:"
  printf "%s\n"

  for k in "${test_write_report_array_1[@]}"
  do
    GENERIC_prepare_display_msgColourSimple "INFO" "${cross} ${k}"
  done
  printf "%s\n"

  for k in "${test_write_report_array_2[@]}"
  do
    GENERIC_prepare_display_msgColourSimple "INFO" "${cross} ${k}"
  done

  GENERIC_prepare_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  GENERIC_prepare_misc_clearTheDecks && exit 1;
else
  GENERIC_prepare_display_msgColourSimple "SUCCESS" "Each server:  write-path test passed"
fi
}
