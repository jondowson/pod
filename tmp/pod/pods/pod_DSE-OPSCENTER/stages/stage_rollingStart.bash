
# about:    start dse on each server based on its server json defined mode

# -------------------------------------------

function task_rollingStart(){

task_file="task_rollingStart.bash"

## for each server start dse based on its json defined mode

for id in $(seq 1 ${numberOfServers});
do

  tag=$(jq             -r '.server_'${id}'.tag'             "${servers_json_path}")
  user=$(jq            -r '.server_'${id}'.user'            "${servers_json_path}")
  sshKey=$(jq          -r '.server_'${id}'.sshKey'          "${servers_json_path}")
  target_folder=$(jq   -r '.server_'${id}'.target_folder'   "${servers_json_path}")
  pubIp=$(jq           -r '.server_'${id}'.pubIp'           "${servers_json_path}")

# ----------

  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

# ----------

  prepare_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"

# ----------

  # assign build settings per the TARGET_FOLDER specified for this server
  printf "%s\n" "TARGET_FOLDER=${target_folder}"            > "${suitcase_file_path}"
  source "${tmp_build_settings_file_path}"

# ----------

  start_opscenter="${opscenter_untar_bin_folder}/opscenter"

# ----------

  prepare_generic_display_msgColourSimple "INFO-->" "starting opscenter:      ${pubIp}"

# ----------

  status="999"
  if [[ "${status}" != "0" ]]; then
    retry=1
    until [[ "${retry}" == "6" ]] || [[ "${status}" == "0" ]]
    do
      ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && java -version"
      status=${?}
      if [[ "${status}" != "0" ]]; then
        prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status}"
        if [[ "${STRICT_START}" ==  "true" ]]; then
          prepare_generic_display_msgColourSimple "ERROR-->" "Exiting pod: ${yellow}${task_file}${red} with ${yellow}--strict true${red} - java unavailable"
          exit 1;
        fi
        start_opscenter_error_array["${tag}"]="${status};${pubIp}"
        break;
      else
        ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && ${start_opscenter}"
        status=${?}
        if [[ "${status}" == "0" ]]; then
          prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${green}${status}"
        else
          prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status} ${white}(retry ${retry}/5)"
        fi
        start_opscenter_error_array["${tag}"]="${status};${pubIp}"
        ((retry++))
      fi
    done
    printf "%s\n"
  fi
done
}

# -------------------------------------------

function task_rollingStart_report(){

## generate a report of all failed ssh connectivity attempts

declare -a start_opscenter_report_array
count=0
for k in "${!start_opscenter_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${start_opscenter_error_array[$k]} ";" "1"
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
    prepare_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  prepare_generic_display_msgColourSimple "SUCCESS" "ALL SERVERS:  opscenter started"
fi
}
