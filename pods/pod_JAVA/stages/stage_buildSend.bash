# about:    for each server build and then send a configured version of pod

# ------------------------------------------

function task_buildSend(){

## for each server configure a bespoke pod build and send/merge it

# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${servers_json_path})

# loop through each server defined in the json file
for id in $(seq 1 ${numberOfServers});
do

  # [1] determine remote server os
  lib_generic_doStuff_remotely_identifyOs

  # [2] for this server, loop through its json block and assign values to bash variables
  lib_generic_json_assignValue
  for key in "${!json_array[@]}"
  do
    declare $key=${json_array[$key]} &>/dev/null
  done
  # add trailing '/' to target_folder path if not present
  target_folder="$(lib_generic_strings_addTrailingSlash ${target_folder})"

  # [3] display message
  prepare_generic_display_msgColourSimple "INFO"    "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}" && printf "\n%s"
  prepare_generic_display_msgColourSimple "INFO-->" "detected os: ${green}${remote_os}${reset}"
  prepare_generic_display_msgColourSimple "INFO-->" "making:      bespoke pod build"

  # [4] source the build_settings file based on this server's target_folder
  lib_generic_build_sourceTarget

  # [5] build a 'suitcase' of server specific variables - used by remotely run functions
  lib_generic_build_suitcase

  # [6] check if os is mac
  if [[ "${remote_os}" == "Mac" ]]; then
    prepare_generic_display_msgColourSimple "INFO-->" "sending:     dummy pod build"
  else
    prepare_generic_display_msgColourSimple "INFO-->" "sending:     bespoke pod build"
  fi

  # [7] display message
  prepare_generic_display_msgColourSimple "INFO-->" "sending:     bespoke pod build"
  printf "%s\n" "${red}"

  # [8] send the bespoke pod build to the server
  lib_generic_build_sendPod

done

# assign the local target_folder value to the suitcase and delete tmp folder
lib_generic_build_finishUp
}

# ------------------------------------------

function task_buildSend_report(){

## generate a status report of all send pids

declare -a build_send_report_array
count=0
for k in "${!build_send_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${build_send_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    build_send_fail="true"
    build_send_report_array["${count}"]="could not transfer: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# -----

if [[ "${build_send_fail}" == "true" ]]; then
  printf "%s\n"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}Write build error report:"
  printf "%s\n"

  for k in "${build_send_report_array[@]}"
  do
    prepare_generic_display_msgColourSimple "INFO-BOLD" "${cross} ${k}"
  done
  printf "%s\n"
  prepare_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  prepare_generic_misc_clearTheDecks && exit 1;
else
  prepare_generic_display_msgColourSimple "SUCCESS" "ALL SERVERS:  distributed bespoke pod build"
fi
}
