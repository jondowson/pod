# author:        jondowson
# about:         start dse on each server based on its server json defined mode
script_name="stage_rollingStart.bash"

# -------------------------------------------

function task_rollingStart(){

## for each server start dse based on its json defined mode

for id in $(seq 1 ${numberOfServers});
do

  tag=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.tag'            | tr -d '"')
  user=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.user'           | tr -d '"')
  sshKey=$(cat ${servers_json_path}        | ${jq_folder}jq '.server_'${id}'.sshKey'         | tr -d '"')
  target_folder=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.target_folder'  | tr -d '"')
  pubIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.pubIp'          | tr -d '"')
  prvIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.prvIp'          | tr -d '"')
  listen_address=$(cat ${servers_json_path}| ${jq_folder}jq '.server_'${id}'.listen_address' | tr -d '"')
  rpc_address=$(cat ${servers_json_path}   | ${jq_folder}jq '.server_'${id}'.rpc_address'    | tr -d '"')
  seeds=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.seeds'          | tr -d '"')
  token=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.token'          | tr -d '"')
  dc=$(cat ${servers_json_path}            | ${jq_folder}jq '.server_'${id}'.dc'             | tr -d '"')
  rack=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.rack'           | tr -d '"')
  search=$(cat ${servers_json_path}        | ${jq_folder}jq '.server_'${id}'.mode.search'    | tr -d '"')
  analytics=$(cat ${servers_json_path}     | ${jq_folder}jq '.server_'${id}'.mode.analytics' | tr -d '"')
  graph=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.mode.graph'     | tr -d '"')
  dsefs=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.mode.dsefs'     | tr -d '"')

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
      #ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bashrc; source ~/.bash_profile && java -version" #&>/dev/null"
      ssh -v -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && java -version"
      status=${?}
      if [[ "${status}" != "0" ]]; then
        lib_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status}"
        if [[ "${STRICT_START}" ==  "true" ]]; then
          lib_generic_display_msgColourSimple "ERROR-->" "Exiting pod: ${yellow}${script_name}${red} with ${yellow}--strict true${red} - java unavailable"
          exit 1;
        fi
        pod_start_dse_error_array["${tag}"]="${status};${pubIp}"
        break;
      else
        ssh -v -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && ${start_cmd} && ${start_agent}"
        status=${?}
        if [[ "${status}" == "0" ]]; then
          lib_generic_display_msgColourSimple "INFO-->" "ssh return code: ${green}${status}"
        else
          lib_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status} ${white}(retry ${retry}/5)"
        fi
        pod_start_dse_error_array["${tag}"]="${status};${pubIp}"
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

declare -a pod_start_dse_report_array
count=0
for k in "${!pod_start_dse_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${pod_start_dse_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_start_dse_fail="true"
    pod_start_dse_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${pod_start_dse_fail}" == "true" ]]; then
  printf "%s\n"
  for k in "${pod_start_dse_report_array[@]}"
  do
    lib_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  lib_generic_display_msgColourSimple "SUCCESS" "DSE + agent started for all servers"
fi
}
