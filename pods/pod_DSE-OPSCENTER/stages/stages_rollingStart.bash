function task_rollingStart(){

## for each server start dse + agent based on its json defined mode

# used in error message
taskFile="task_rollingStart.bash"

# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${serversJsonPath})

for id in $(seq 1 ${numberOfServers});
do

  # [1] determine remote server os
  GENERIC_lib_doStuffRemotely_identifyOs

  # [2] for this server, loop through its json block and assign values to bash variables
  GENERIC_lib_json_assignValue
  for key in "${!arrayJson[@]}"
  do
    declare $key=${arrayJson[$key]} &>/dev/null
  done
  # add trailing '/' to target_folder path if not present
  target_folder="$(GENERIC_lib_strings_addTrailingSlash ${target_folder})"

  # [3] display a message
  GENERIC_prepare_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}${pub_ip} ${reset} on os ${yellow}${remote_os}${reset}"
  GENERIC_prepare_display_msgColourSimple "INFO-->" "opscenter version:     ${software_version}"

  # [4] source the build_settings file based on this server's target_folder
  GENERIC_lib_build_sourceTarget

  # [5] start opscenter
  GENERIC_prepare_display_msgColourSimple   "INFO-->" "checking java:"
  GENERIC_lib_doStuffRemotely_checkSoftwareAvailability "1" "true" "java -version" "java unavailable" "java return code:" "full"
  lib_doStuffRemotely_startOpscenter

done
}

# --------------------------------------

function task_rollingStart_report(){

## generate a report of all failed ssh connectivity attempts

declare -a start_opscenter_report_array
count=0
for k in "${!arrayStartOpscenter[@]}"
do
  GENERIC_lib_strings_expansionDelimiter ${arrayStartOpscenter[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    start_opscenter_fail="true"
    start_opscenter_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${start_dse_fail}" == "true" ]]; then
  printf "%s\n"
  for k in "${start_opscenter_report_array[@]}"
  do
    GENERIC_prepare_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  GENERIC_prepare_display_msgColourSimple "SUCCESS" "Each server:  opscenter started"
fi
}
