function GENERIC_task_buildSend(){

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

# [3] determine remote server os
GENERIC_lib_doStuffRemotely_identifyOs

# [4] display message
GENERIC_prepare_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}$pub_ip${white} on os ${yellow}${remote_os}${reset}" #&& printf "\n%s"
GENERIC_prepare_display_msgColourSimple "INFO-->" "make build:        ${BUILD_FOLDER}"

# [5] source the build_settings file based on this server's target_folder
GENERIC_lib_build_sourceTarget

# [6] build a 'suitcase' of server specific variables for remotely run functions
GENERIC_lib_build_suitcase
GENERIC_lib_build_suitcase

# [7] perform locally run functions for this pod (this array may be empty!)
for func in "${!arrayBuildLocalFunctions[@]}"
do
  ${arrayBuildLocalFunctions[$func]}
done

# [8 ]display message
GENERIC_prepare_display_msgColourSimple "INFO-->" "send build to:     ${target_folder}POD_SOFTWARE/POD/"

# [9] send the bespoke pod build to the server
GENERIC_lib_build_sendPod

# [10] assign the local target_folder value to the suitcase and delete tmp folder
GENERIC_lib_build_finishUp
}

# ------------------------------------------

function GENERIC_task_buildSend_report(){

## generate a report of all failed sends of pod build

declare -a build_send_report_array
count=0
for k in "${!arrayBuildSend[@]}"
do
  GENERIC_lib_strings_expansionDelimiter ${arrayBuildSend[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    build_send_fail="true"
    build_send_report_array["${count}"]="could not transfer: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# -----

if [[ "${build_send_fail}" == "true" ]]; then
  printf "%s\n"
  GENERIC_prepare_display_msgColourSimple "INFO-BOLD" "--> ${red}Write build error report:"
  printf "%s\n"

  for k in "${build_send_report_array[@]}"
  do
    GENERIC_prepare_display_msgColourSimple "INFO-BOLD" "${cross} ${k}"
  done
  printf "%s\n"
  GENERIC_prepare_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  GENERIC_prepare_misc_clearTheDecks && exit 1;
else
  GENERIC_prepare_display_msgColourSimple "SUCCESS" "Each server:  distributed bespoke pod build"
fi
}
