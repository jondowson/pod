function task_rollingStart(){

## for each server start dse + agent based on its json defined mode

# used in error message
task_file="task_rollingStart.bash"

# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${serversJsonPath})

for id in $(seq 1 ${numberOfServers});
do

  # [1] determine remote server os
  GENERIC_lib_doStuffRemotely_identifyOs

  # [2] for this server, loop through its json block and assign values to bash variables
  GENERIC_lib_json_assignValue
  for key in "${!arrayJson[@]}"
  do
    declare $key=${arrayJson[$key]} &>/dev/null
  done
  # add trailing '/' to target_folder path if not present
  target_folder="$(lib_generic_strings_addTrailingSlash ${target_folder})"

  # [3] display message
  GENERIC_prepare_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}${pub_ip} ${reset} on os ${yellow}${remote_os}${reset}"
  GENERIC_prepare_display_msgColourSimple "INFO-->" "dse version:           ${dse_version}"
  GENERIC_prepare_display_msgColourSimple "INFO-->" "agent version:         ${agent_version}"

  # [4] source the build_settings file based on this server's target_folder
  GENERIC_lib_build_sourceTarget

  # [5] handle the flags used to start dse in the correct mode
  flags=""
  if [[ "${mode_search}"    == "true" ]];  then flags="${flags} -s"; fi
  if [[ "${mode_analytics}" == "true" ]];  then flags="${flags} -k"; fi
  if [[ "${mode_graph}"     == "true" ]];  then flags="${flags} -g"; fi

  # [6] start dse + agent running on server
  if [[ "${CLUSTER_STATE}" == "restart" ]]; then

    if [[ "${flags}" == "" ]]; then
      GENERIC_prepare_display_msgColourSimple "INFO-->" "starting dse in mode:  storage only"
    else
      GENERIC_prepare_display_msgColourSimple "INFO-->" "starting dse in mode:  storage + flags ${flags}"
    fi

    lib_doStuffRemotely_checkJava
    lib_doStuffRemotely_startDse
    lib_doStuffRemotely_startAgent

  elif [[ "${CLUSTER_STATE}" == *"agent"* ]]; then
    lib_doStuffRemotely_checkJava
    lib_doStuffRemotely_startAgent
  fi

done
}

# -------------------------------------------

function task_rollingStart_report(){

## generate a report of start pids finish status

declare -a start_dse_report_array
count=0
for k in "${!arrayStartDse[@]}"
do
  GENERIC_lib_strings_expansionDelimiter ${arrayStartDse[$k]} ";" "1"
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
    GENERIC_prepare_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  if [[ "${CLUSTER_STATE}" == "restart" ]]; then
    GENERIC_prepare_display_msgColourSimple "SUCCESS" "Each server:  dse started"
  fi
fi

# -----

declare -a start_agent_report_array
count=0
for k in "${!arrayStartAgent[@]}"
do
  GENERIC_lib_strings_expansionDelimiter ${arrayStartAgent[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    start_agent_fail="true"
    start_agent_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${start_agent_fail}" == "true" ]]; then
  printf "%s\n"
  for k in "${start_agent_report_array[@]}"
  do
    GENERIC_prepare_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  if [[ "${CLUSTER_STATE}" == *"agent"* ]] || [[ "${CLUSTER_STATE}" == "restart" ]]; then
    GENERIC_prepare_display_msgColourSimple "SUCCESS" "Each server:  agent started"
  fi
fi
}
