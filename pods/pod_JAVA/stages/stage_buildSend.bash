# about:    for each server build and then send a configured version of pod

# ------------------------------------------

function task_buildSend(){

## for each server configure a pod build and then send it

for id in $(seq 1 ${numberOfServers});
do

  tag=$(jq            -r '.server_'${id}'.tag'            "${servers_json_path}")
  user=$(jq           -r '.server_'${id}'.user'           "${servers_json_path}")
  sshKey=$(jq         -r '.server_'${id}'.sshKey'         "${servers_json_path}")
  target_folder=$(jq  -r '.server_'${id}'.target_folder'  "${servers_json_path}")
  pubIp=$(jq          -r '.server_'${id}'.pubIp'          "${servers_json_path}")

# -----

  # add trailing '/' to path if not present
  target_folder="$(lib_generic_strings_addTrailingSlash ${target_folder})"

# -----

  lib_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "%s\n"
  remote_os=$(ssh -q -o Forwardx11=no ${user}@${pubIp} 'bash -s' < ${pod_home_path}/pods/pod_/scripts/scripts_generic_identifyOs.sh)
  lib_generic_display_msgColourSimple "INFO-->" "detected os: ${green}${remote_os}${reset}"

  if [[ "${remote_os}" == "Mac" ]]; then
    lib_generic_display_msgColourSimple "INFO-->" "note:        pod_JAVA does not set Java on Macs"
  else
    lib_generic_display_msgColourSimple "INFO-->" "making:      bespoke pod build"
  fi

# -----

  # assign build settings per the TARGET_FOLDER specified for this server
  printf "%s\n" "TARGET_FOLDER=${target_folder}"                 > "${suitcase_file_path}"       # local .suitcase !!
  source "${tmp_build_settings_file_path}"

  # -----

  ## pack the suitcase: [1] + [2] are always required !!!

  # [1] append target_folder - clear any existing values with first entry (i.e. '>')
  printf "%s\n" "TARGET_FOLDER=${target_folder}"                 > "${tmp_suitcase_file_path}"   # remote .suitcase !!
  # [2] append variables gathered from flags
  printf "%s\n" "WHICH_POD=${WHICH_POD}"                        >> "${tmp_suitcase_file_path}"
  printf "%s\n" "BUILD_FOLDER=${BUILD_FOLDER}"                  >> "${tmp_suitcase_file_path}"
  build_folder_path_string="${target_folder}POD_SOFTWARE/POD/pod/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
  printf "%s\n" "build_folder_path=${build_folder_path_string}" >> "${tmp_suitcase_file_path}"
  # [3] append variables from server json definition file

  # -----

  if [[ "${remote_os}" == "Mac" ]]; then
    lib_generic_display_msgColourSimple "INFO-->" "sending:     dummy pod build"
  else
    lib_generic_display_msgColourSimple "INFO-->" "sending:     bespoke pod build"
  fi

  printf "%s\n" "${red}"
  # check if server is local server - so not to delete itself !!
  localServer="false"
  localServer=$(lib_generic_checks_localIpMatch "${pubIp}")
  if [[ "${localServer}" != "true" ]]; then
    ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "rm -rf ${target_folder}POD_SOFTWARE/POD/pod" exit
  else
    cp "${tmp_suitcase_file_path}" ${pod_home_path}/.suitcase.tmp
  fi
  # (re)create folder and send over updated pod software
  ssh -q -i ${sshKey} ${user}@${pubIp} "mkdir -p ${target_folder}POD_SOFTWARE/POD/pod/"
  scp -q -o LogLevel=QUIET -i ${sshKey} -r "${tmp_working_folder}" "${user}@${pubIp}:${target_folder}POD_SOFTWARE/POD/"
  status=${?}
  build_send_error_array["${tag}"]="${status};${pubIp}"
done

# assign the local target_folder value to the suitcase
mv ${pod_home_path}/.suitcase.tmp "${suitcase_file_path}"
# delete the temporary work folder
rm -rf "${tmp_folder}"
}

# ------------------------------------------

function task_buildSend_report(){

## generate a report of all failed sends of pod build

lib_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Create pod for each server"

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
  lib_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}Write build error report:"
  printf "%s\n"

  for k in "${build_send_report_array[@]}"
  do
    lib_generic_display_msgColourSimple "INFO-BOLD" "${cross} ${k}"
  done
  printf "%s\n"
  lib_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  prepare_generic_misc_clearTheDecks && exit 1;
else
  lib_generic_display_msgColourSimple "SUCCESS" "Create and send bespoke pod build to all servers"
fi
}
