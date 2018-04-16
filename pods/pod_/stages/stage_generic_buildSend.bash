# about:    make server specific pod build and send it over

# ------------------------------------------

function task_generic_buildSend(){

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

# [5] build a 'suitcase' of server specific variables for remotely run functions
lib_generic_build_suitcase
lib_build_suitcase

# [6] perform locally run functions for this pod (this array may be empty!)
for func in "${!build_local_functions_array[@]}"
do
  ${build_local_functions_array[$func]}
done

# [7] send the bespoke pod build to the server
lib_generic_build_sendPod
}

# ------------------------------------------

function task_generic_buildSend_report(){

## generate a report of all failed sends of pod build

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
