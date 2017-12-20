# author:        jondowson
# about:         start dse on each server based on its server json defined mode

# -------------------------------------------

function task_removePod(){

## for each server stop dse based on its json defined mode

for id in $(seq 1 ${numberOfServers});
do

  tag=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.tag'            | tr -d '"')
  user=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.user'           | tr -d '"')
  sshKey=$(cat ${servers_json_path}        | ${jq_folder}jq '.server_'${id}'.sshKey'         | tr -d '"')
  target_folder=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.target_folder'  | tr -d '"')
  pubIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.pubIp'          | tr -d '"')
  prvIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.prvIp'          | tr -d '"')

# ----------

  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

# ----------

  lib_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"

# ----------

  lib_generic_display_msgColourSimple "INFO-->" "removing pod:      ${REMOVE_POD}"

# ----------

  status="999"
  if [[ "${status}" != "0" ]]; then
    retry=1
    until [[ "${retry}" == "6" ]] || [[ "${status}" == "0" ]]
    do
      ssh -q -i ${sshKey} ${user}@${pubIp} "rm -rf ${INSTALL_FOLDER}${REMOVE_POD} &>/dev/null"
      status=${?}
      if [[ "${status}" == "0" ]]; then
        lib_generic_display_msgColourSimple "INFO-->" "ssh return code: ${green}${status}"
      else
        lib_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status} ${white}(retry ${retry}/5)"
      fi
      pod_remove_pod_error_array["${tag}"]="${status};${pubIp}"
      ((retry++))
    done
    printf "%s\n"
  fi
done
}

# -------------------------------------------

function task_removePod_report(){

## generate a report of all failed ssh connectivity attempts

declare -a pod_stop_dse_report_array
count=0
for k in "${!pod_remove_pod_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${pod_remove_pod_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_remove_pod_fail="true"
    pod_remove_pod_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with error code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${pod_stop_dse_fail}" == "true" ]]; then
  printf "%s\n"
  lib_generic_display_msgColourSimple "INFO-BOLD-->" "${red}Remove ${REMOVE_POD} errors report:"
  printf "%s\n"
  for k in "${pod_remove_pod_report_array[@]}"
  do
    lib_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  lib_generic_display_msgColourSimple "SUCCESS" "${REMOVE_POD} was successfully removed from ${INSTALL_FOLDER}"
fi
}
