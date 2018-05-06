# about:    send POD_SOFTWARE/$PACKAGE folder to each server on its specified target folder

# ------------------------------------------

function GENERIC_task_sendPodSoftware(){

for id in $(seq 1 ${numberOfServers});
do

  # [1] assign json variable to bash variables
  tag=$(jq            -r '.server_'${id}'.tag'            "${serversJsonPath}")
  user=$(jq           -r '.server_'${id}'.user'           "${serversJsonPath}")
  ssh_key=$(jq         -r '.server_'${id}'.ssh_key'         "${serversJsonPath}")
  target_folder=$(jq  -r '.server_'${id}'.target_folder'  "${serversJsonPath}")
  pub_ip=$(jq          -r '.server_'${id}'.pub_ip'          "${serversJsonPath}")
  # add trailing '/' to path if not present
  target_folder=$(GENERIC_lib_strings_addTrailingSlash "${target_folder}")

  # [2] source the build_settings file after assigning the target_folder for the current server in the loop
  TARGET_FOLDER="${LOCAL_TARGET_FOLDER}"
  source ${TMP_FILE_BUILDSETTINGS}

  # [3] determine remote server os
  GENERIC_lib_doStuffRemotely_identifyOs

  # [4] display message
  GENERIC_prepare_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}$pub_ip${white} on os ${yellow}${remote_os}${reset}" #&& printf "\n%s"
  GENERIC_prepare_display_msgColourSimple "INFO-->" "sending:        POD_SOFTWARE/${PACKAGE}"

  # [5] check target_folder can be used on target machine !!
  catchError "stage_POD_SOFTWARE#1" "cannot make target folder" "true" "true" "ssh -o ForwardX11=no ${user}@${pub_ip} mkdir -p ${target_folder}POD_SOFTWARE"

  # [6] check if server is local server - no point sending software if local +  no delete locally of existing pod folder
  localServer="false"
  localServer=$(GENERIC_lib_checks_localIpMatch "${pub_ip}")
  if [[ "${localServer}" == "true" ]] && [[ "${LOCAL_TARGET_FOLDER}" == "${target_folder}" ]]; then
    GENERIC_prepare_display_msgColourSimple "INFO-->" "skipping:       no need to send locally"
  else
    # copy the POD_SOFTWARE folder to remote server
    scp -q -o LogLevel=QUIET -i ${ssh_key} -r "${PACKAGES}" "${user}@${pub_ip}:${target_folder}POD_SOFTWARE" &    # run in parallel
    # out pid response status in array
    pid=${!}
    GENERIC_prepare_display_msgColourSimple "INFO-->" "pid id:        ${yellow}${pid}${reset}"
    arraySendPodPids["${pid}"]="${tag};${pub_ip}"
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
GENERIC_prepare_display_msgColourSimple "INFO-BOLD-SPACED" "awaiting scp pids:${reset}"
GENERIC_prepare_display_msgColourSimple "INFO"      "${yellow}$DSE_pids${reset}"

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

function GENERIC_task_sendPodSoftware_report(){

## display report of pids used when sending POD_SOFTWARE

if [[ ! -z $POD_SOFTWARE_pid_failures ]]; then
  GENERIC_prepare_display_msgColourSimple "INFO-->" "${cross} Problems distributing POD_SOFTWARE/${PACKAGE} to servers"
  printf "%s\n"
  for k in "${!POD_SOFTWARE_server_pid_array[@]}"
  do
    if [[ "${POD_SOFTWARE_pid_failures}" == *"$k"* ]]; then
      lib_strings_expansionDelimiter "${arraySendPodPids[$k]}" ";" "1"
      server="$_D1_"
      ip=$_D2_
      GENERIC_prepare_display_msgColourSimple "ERROR-TIGHT" "pid ${yellow}${k}${red} failed for ${yellow}${server}@${ip}${red}"
    fi
  done
  printf "%s\n"
else
  GENERIC_prepare_display_msgColourSimple "SUCCESS" "Each server:  distributed POD_SOFTWARE/${PACKAGE}"
fi
}
