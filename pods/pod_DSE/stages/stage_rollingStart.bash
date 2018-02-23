
# about:    start dse on each server based on its server json defined mode

# -------------------------------------------

function task_rollingStart(){

task_file="task_rollingStart.bash"

## for each server start dse based on its json defined mode

for id in $(seq 1 ${numberOfServers});
do

  tag=$(jq            -r '.server_'${id}'.tag'            "${servers_json_path}")
  user=$(jq           -r '.server_'${id}'.user'           "${servers_json_path}")
  sshKey=$(jq         -r '.server_'${id}'.sshKey'         "${servers_json_path}")
  target_folder=$(jq  -r '.server_'${id}'.target_folder'  "${servers_json_path}")
  pubIp=$(jq          -r '.server_'${id}'.pubIp'          "${servers_json_path}")
  listen_address=$(jq -r '.server_'${id}'.listen_address' "${servers_json_path}")
  rpc_address=$(jq    -r '.server_'${id}'.rpc_address'    "${servers_json_path}")
  seeds=$(jq          -r '.server_'${id}'.seeds'          "${servers_json_path}")
  token=$(jq          -r '.server_'${id}'.token'          "${servers_json_path}")
  dc=$(jq             -r '.server_'${id}'.dc'             "${servers_json_path}")
  rack=$(jq           -r '.server_'${id}'.rack'           "${servers_json_path}")
  search=$(jq         -r '.server_'${id}'.mode.search'    "${servers_json_path}")
  analytics=$(jq      -r '.server_'${id}'.mode.analytics' "${servers_json_path}")
  graph=$(jq          -r '.server_'${id}'.mode.graph'     "${servers_json_path}")
  dsefs=$(jq          -r '.server_'${id}'.mode.dsefs'     "${servers_json_path}")

# ----------

  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

# ----------

  lib_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"

# ----------

  # assign build settings per the TARGET_FOLDER specified for this server
  printf "%s\n" "TARGET_FOLDER=${target_folder}"            > "${suitcase_file_path}"
  source "${tmp_build_settings_file_path}"

# ----------

  start_agent="${agent_untar_bin_folder}/datastax-agent"

# ----------

  flags=""
  if [[ "${searchFlag}" == "true" ]];     then flags="${flags} -s"; fi
  if [[ "${analyticsFlag}" == "true" ]];  then flags="${flags} -k"; fi
  if [[ "${graphFlag}" == "true" ]];      then flags="${flags} -g"; fi
  start_cmd="dse cassandra${flags}"

# ----------

  if [[ "${flags}" == "" ]]; then
    lib_generic_display_msgColourSimple "INFO-->" "starting dse + agent:      cassandra only"
  else
    lib_generic_display_msgColourSimple "INFO-->" "starting dse + agent:      with flags ${flags}"
  fi

# ----------

  status="999"
  if [[ "${status}" != "0" ]]; then
    retry=1
    until [[ "${retry}" == "6" ]] || [[ "${status}" == "0" ]]
    do
      ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && java -version"
      status=${?}
      if [[ "${status}" != "0" ]]; then
        lib_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status}"
        if [[ "${STRICT_START}" ==  "true" ]]; then
          lib_generic_display_msgColourSimple "ERROR-->" "Exiting pod: ${yellow}${task_file}${red} with ${yellow}--strict true${red} - java unavailable"
          exit 1;
        fi
        start_dse_error_array["${tag}"]="${status};${pubIp}"
        break;
      else
        ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && ${start_cmd} && ${start_agent}"
        status=${?}
        if [[ "${status}" == "0" ]]; then
          lib_generic_display_msgColourSimple "INFO-->" "ssh return code: ${green}${status}"
        else
          lib_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status} ${white}(retry ${retry}/5)"
        fi
        start_dse_error_array["${tag}"]="${status};${pubIp}"
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

lib_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Restart DSE + agent on each server"

declare -a start_dse_report_array
count=0
for k in "${!start_dse_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${start_dse_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    start_dse_fail="true"
    start_dse_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${start_dse_fail}" == "true" ]]; then
  printf "%s\n"
  for k in "${start_dse_report_array[@]}"
  do
    lib_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  lib_generic_display_msgColourSimple "SUCCESS" "DSE + agent started for all servers"
fi
}
