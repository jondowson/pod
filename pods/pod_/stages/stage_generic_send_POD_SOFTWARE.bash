# about:    send POD_SOFTWARE/$PACKAGE folder to each server on its specified target folder

# ------------------------------------------

function task_generic_sendPodSoftware(){

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
  TARGET_FOLDER="${LOCAL_TARGET_FOLDER}"
  source ${tmp_build_settings_file_path}

# -----

  lib_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"

# -----

  lib_generic_display_msgColourSimple "INFO-->" "sending:     POD_SOFTWARE/${PACKAGE} folder"

  # target folder must exist on target machine !!
  catchError "stage_generic_POD_SOFTWARE#1" "cannot make target folder" "true" "true" "ssh -o ForwardX11=no ${user}@${pubIp} mkdir -p ${target_folder}POD_SOFTWARE"

  # check if server is local server - no point sending software if local +  no delete locally of existing pod folder
  localServer="false"
  localServer=$(lib_generic_checks_localIpMatch "${pubIp}")

  if [[ "${localServer}" == "true" ]]; then
    lib_generic_display_msgColourSimple "INFO-->" "Not sending to local machine ! ${reset}"
  else
    # copy the POD_SOFTWARE for this pod from this server to remote server
    scp -q -o LogLevel=QUIET -i ${sshKey} -r "${PACKAGES}" "${user}@${pubIp}:${target_folder}POD_SOFTWARE" &    # run in parallel
    # grab pid and capture owner in array
    pid=${!}
    lib_generic_display_msgColourSimple "INFO-->" "pid id:      ${yellow}${pid}${reset}"
    pod_software_send_pid_array["${pid}"]="${tag};${pubIp}"
    DSE_pids+=" $pid"
  fi

  # collect pids for print
  if [[ "${DSE_pids_print}" ]]; then
    DSE_pids_print="${DSE_pids_print},$pid"
  else
    DSE_pids_print="$!"
  fi
  printf "\n%s"

done

# -----

lib_generic_display_msgColourSimple "INFO-BOLD" "awaiting scp pids:${reset}"
lib_generic_display_msgColourSimple "INFO" "${yellow}$DSE_pids${reset}"
printf "\n%s"

# -----

# Wait for all processes to finish

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
}

# ------------------------------------------

function task_generic_sendPodSoftware_report(){

# display report

lib_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Send POD_SOFTWARE/${PACKAGE} to each server"

if [[ ! -z $POD_SOFTWARE_pid_failures ]]; then
  lib_generic_display_msgColourSimple "INFO-->" "${cross} Problems distributing POD_SOFTWARE/${PACKAGE} to servers"
  printf "%s\n"
  for k in "${!POD_SOFTWARE_server_pid_array[@]}"
  do
    if [[ "${POD_SOFTWARE_pid_failures}" == *"$k"* ]]; then
      lib_generic_strings_expansionDelimiter "${pod_software_send_pid_array[$k]}" ";" "1"
      server="$_D1_"
      ip=$_D2_
      lib_generic_display_msgColourSimple "ERROR-TIGHT" "pid ${yellow}${k}${red} failed for ${yellow}${server}@${ip}${red}"
    fi
  done
  printf "%s\n"
else
  lib_generic_display_msgColourSimple "SUCCESS" "All Servers: 'POD_SOFTWARE/${PACKAGE}' distributed"
fi
}
