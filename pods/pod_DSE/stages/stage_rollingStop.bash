function task_rollingStop(){

## for each server stop dse based on its json defined mode

# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${servers_json_path})

for id in $(seq 1 ${numberOfServers});
do

  # [1] for this server, loop through its json block and assign values to bash variables
  lib_generic_json_assignValue
  for key in "${!json_array[@]}"
  do
    declare $key=${json_array[$key]} &>/dev/null
  done
  # add trailing '/' to target_folder path if not present
  target_folder="$(lib_generic_strings_addTrailingSlash ${target_folder})"

  # [2] source the build_settings file based on this server's target_folder
  lib_generic_build_sourceTarget

  # [3] determine remote server os
  lib_generic_doStuff_remotely_identifyOs

  # [4] display messages
  prepare_generic_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}$pubIp${white} on os ${yellow}${remote_os}${reset}" #&& printf "\n%s"

  runningDseVersion=$(ssh -q -i ~/.ssh/id_rsa jd@127.0.0.1 "ps -ef | grep -v grep | grep -Po '(?<=dse-core-)[^/lib/]+' | head -n1" )
  runningDseVersion=$(echo ${runningDseVersion%\.jar:})
  if [[ ${runningDseVersion} == "" ]]; then
    runningDseVersion="n/a"
  fi
  runningAgentVersion=$(ps -ef | grep -v grep | grep -o 'datastax-agent-[^ ]*' | sed 's/^\(datastax-agent\-\)*//' | sed -e 's/\(-standalone.jar\)*$//g' )
  if [[ -z ${runningAgentVersion} ]]; then
    runningAgentVersion="n/a"
  fi
  prepare_generic_display_msgColourSimple "INFO-->" "dse version (now):     ${runningDseVersion}"
  prepare_generic_display_msgColourSimple "INFO-->" "agent version (now):   ${runningAgentVersion}"

  # [5] stop dse + agent running on server
  if [[ "${CLUSTER_STATE}" == "restart" ]] || [[ "${CLUSTER_STATE}" == "stop" ]]; then
    lib_doStuff_remotely_stopAgent
    lib_doStuff_remotely_stopDse
  elif [[ "${CLUSTER_STATE}" == *"agent"* ]]; then
    lib_doStuff_remotely_stopAgent
  fi
done
}

# -------------------------------------------

function task_rollingStop_report(){

## generate a report of stop pids finish status

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
  if [[ "${CLUSTER_STATE}" == "restart" ]] || [[ "${CLUSTER_STATE}" == "stop" ]]; then
    prepare_generic_display_msgColourSimple "SUCCESS" "Each server:  dse stopped"
    prepare_generic_display_msgColourSimple "SUCCESS" "Each server:  agent stopped"
  elif [[ "${CLUSTER_STATE}" == *"agent"* ]]; then
    prepare_generic_display_msgColourSimple "SUCCESS" "Each server:  agent stopped"
  fi
fi
}
