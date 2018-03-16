# about:         start dse on each server based on its server json defined mode

# -------------------------------------------

function task_rollingStop(){

## for each server stop dse based on its json defined mode

for id in $(seq 1 ${numberOfServers});
do

  tag=$(jq             -r '.server_'${id}'.tag'             "${servers_json_path}")
  user=$(jq            -r '.server_'${id}'.user'            "${servers_json_path}")
  sshKey=$(jq          -r '.server_'${id}'.sshKey'          "${servers_json_path}")
  target_folder=$(jq   -r '.server_'${id}'.target_folder'   "${servers_json_path}")
  pubIp=$(jq           -r '.server_'${id}'.pubIp'           "${servers_json_path}")
  listen_address=$(jq  -r '.server_'${id}'.listen_address'  "${servers_json_path}")
  rpc_address=$(jq     -r '.server_'${id}'.rpc_address'     "${servers_json_path}")
  stomp_interface=$(jq -r '.server_'${id}'.stomp_interface' "${servers_json_path}")
  seeds=$(jq           -r '.server_'${id}'.seeds'           "${servers_json_path}")
  token=$(jq           -r '.server_'${id}'.token'           "${servers_json_path}")
  dc=$(jq              -r '.server_'${id}'.dc'              "${servers_json_path}")
  rack=$(jq            -r '.server_'${id}'.rack'            "${servers_json_path}")
  search=$(jq          -r '.server_'${id}'.mode.search'     "${servers_json_path}")
  analytics=$(jq       -r '.server_'${id}'.mode.analytics'  "${servers_json_path}")
  graph=$(jq           -r '.server_'${id}'.mode.graph'      "${servers_json_path}")
  dsefs=$(jq           -r '.server_'${id}'.mode.dsefs'      "${servers_json_path}")

# ----------

  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

# ----------

  prepare_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"

# ----------

  prepare_generic_display_msgColourSimple "INFO-->" "stopping dse:      gracefully"
  prepare_generic_display_msgColourSimple "INFO-->" "killing agent:     ungracefully"

# ----------

  stop_cmd="dse cassandra-stop"

  status="999"
  if [[ "${status}" != "0" ]]; then
    retry=1
    until [[ "${retry}" == "4" ]] || [[ "${status}" == "0" ]]
    do
      ssh -q -i ${sshKey} ${user}@${pubIp} "ps aux | grep datastax-agent | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
      ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && ${stop_cmd}"
      status=${?}
      if [[ "${status}" == "0" ]]; then
        prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${green}${status}"
      else
        prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status} ${white}(retry ${retry}/3)"
        prepare_generic_display_msgColourSimple "INFO-->" "killing dse:     ungracefully"
        ssh -q -i ${sshKey} ${user}@${pubIp} "ps aux | grep cassandra | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
      fi
      stop_dse_error_array["${tag}"]="${status};${pubIp}"
      ((retry++))
    done
    printf "%s\n"
  fi
done
}

# -------------------------------------------

function task_rollingStop_report(){

## generate a report of all failed ssh connectivity attempts

declare -a stop_dse_report_array
count=0
for k in "${!stop_dse_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${stop_dse_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    stop_dse_fail="true"
    stop_dse_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with error code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${stop_dse_fail}" == "true" ]]; then
  printf "%s\n"
  for k in "${stop_dse_report_array[@]}"
  do
    prepare_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  prepare_generic_display_msgColourSimple "SUCCESS" "ALL SERVERS:  dse + agent stopped"
fi
}
