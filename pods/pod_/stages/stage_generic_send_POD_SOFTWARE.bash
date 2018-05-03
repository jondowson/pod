# about:    send POD_SOFTWARE/$PACKAGE folder to each server on its specified target folder

# ------------------------------------------

function task_generic_sendPodSoftware(){

for id in $(seq 1 ${numberOfServers});
do

  # [1] assign json variable to bash variables
  tag=$(jq            -r '.server_'${id}'.tag'            "${servers_json_path}")
  user=$(jq           -r '.server_'${id}'.user'           "${servers_json_path}")
  sshKey=$(jq         -r '.server_'${id}'.sshKey'         "${servers_json_path}")
  target_folder=$(jq  -r '.server_'${id}'.target_folder'  "${servers_json_path}")
  pubIp=$(jq          -r '.server_'${id}'.pubIp'          "${servers_json_path}")
  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

  # [2] source the build_settings file after assigning the target_folder for the current server in the loop
  TARGET_FOLDER="${LOCAL_TARGET_FOLDER}"
  source ${tmp_build_settings_file_path}

  # [3] determine remote server os
  lib_generic_doStuff_remotely_identifyOs

  # [4] display message
  prepare_generic_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}$pubIp${white} on os ${yellow}${remote_os}${reset}" #&& printf "\n%s"
  prepare_generic_display_msgColourSimple "INFO-->" "sending:        POD_SOFTWARE/${PACKAGE}"

  # [5] check target_folder can be used on target machine !!
  catchError "stage_generic_POD_SOFTWARE#1" "cannot make target folder" "true" "true" "ssh -o ForwardX11=no ${user}@${pubIp} mkdir -p ${target_folder}POD_SOFTWARE"

  # [6] check if server is local server - no point sending software if local +  no delete locally of existing pod folder
  localServer="false"
  localServer=$(lib_generic_checks_localIpMatch "${pubIp}")
  if [[ "${localServer}" == "true" ]] && [[ "${LOCAL_TARGET_FOLDER}" == "${target_folder}" ]]; then
    prepare_generic_display_msgColourSimple "INFO-->" "skipping:       no need to send locally"
  else
    # copy the POD_SOFTWARE folder to remote server
    scp -q -o LogLevel=QUIET -i ${sshKey} -r "${PACKAGES}" "${user}@${pubIp}:${target_folder}POD_SOFTWARE" &    # run in parallel
    # out pid response status in array
    pid=${!}
    prepare_generic_display_msgColourSimple "INFO-->" "pid id:        ${yellow}${pid}${reset}"
    send_pod_software_pid_array["${pid}"]="${tag};${pubIp}"
    DSE_pids+=" $pid"
  fi

  # collect pids for display
  if [[ "${DSE_pids_print}" ]]; then
    DSE_pids_print="${DSE_pids_print},$pid"
  else
    DSE_pids_print="$!"
  fi
done

# -----

# [7] display message
prepare_generic_display_msgColourSimple "INFO-BOLD-SPACED" "awaiting scp pids:${reset}"
prepare_generic_display_msgColourSimple "INFO"      "${yellow}$DSE_pids${reset}"

# [8] display pid responses as they become available
POD_SOFTWARE_pid_failures=""
printf "%s" ${red}  # any scp error messages
for p in $DSE_pids; do
  if wait $p; then
    printf "%s\n" "${green}Process $p success${reset}"
  else
    printf "%s\n" "${red}Process $p fail${reset}"
    POD_SOFTWARE_pid_failures+=" ${p}"
  fi
done
printf "%s" ${reset}
}

# ------------------------------------------

function task_generic_sendPodSoftware_report(){

## display report of pids used when sending POD_SOFTWARE

if [[ ! -z $POD_SOFTWARE_pid_failures ]]; then
  prepare_generic_display_msgColourSimple "INFO-->" "${cross} Problems distributing POD_SOFTWARE/${PACKAGE} to servers"
  printf "%s\n"
  for k in "${!POD_SOFTWARE_server_pid_array[@]}"
  do
    if [[ "${POD_SOFTWARE_pid_failures}" == *"$k"* ]]; then
      lib_generic_strings_expansionDelimiter "${send_pod_software_pid_array[$k]}" ";" "1"
      server="$_D1_"
      ip=$_D2_
      prepare_generic_display_msgColourSimple "ERROR-TIGHT" "pid ${yellow}${k}${red} failed for ${yellow}${server}@${ip}${red}"
    fi
  done
  printf "%s\n"
else
  prepare_generic_display_msgColourSimple "SUCCESS" "Each server:  distributed POD_SOFTWARE/${PACKAGE}"
fi
}
