
# about:    start dse on each server based on its server json defined mode

# -------------------------------------------

function task_rollingStart(){

## for each server start dse + agent based on its json defined mode

# used in error message
task_file="task_rollingStart.bash"

# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${servers_json_path})

for id in $(seq 1 ${numberOfServers});
do

  # [1] determine remote server os
  lib_generic_doStuff_remotely_identifyOs

  # [2] for this server, loop through its json block and assign values to bash variables
  lib_generic_json_assignValue
  for key in "${!json_array[@]}"
  do
    declare $key=${json_array[$key]} &>/dev/null
  done
  # add trailing '/' to target_folder path if not present
  target_folder="$(lib_generic_strings_addTrailingSlash ${target_folder})"

  # [3] display message
  prepare_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"

  # [4] source the build_settings file based on this server's target_folder
  lib_generic_build_sourceTarget

  # [5] handle the flags used to start dse in the correct mode
  flags=""
  if [[ "${mode_search}"    == "true" ]];  then flags="${flags} -s"; fi
  if [[ "${mode_analytics}" == "true" ]];  then flags="${flags} -k"; fi
  if [[ "${mode_graph}"     == "true" ]];  then flags="${flags} -g"; fi
  start_cmd="${dse_untar_bin_folder}dse cassandra${flags}"
  start_agent="${agent_untar_bin_folder}/datastax-agent"

  # [6] display message
  if [[ "${flags}" == "" ]]; then
    prepare_generic_display_msgColourSimple "INFO-->" "starting dse + agent:      cassandra only"
  else
    prepare_generic_display_msgColourSimple "INFO-->" "starting dse + agent:      with flags ${flags}"
  fi

  # [7] start dse + agent
  lib_doStuff_remotely_startDseAgent

done
}

# -------------------------------------------

function task_rollingStart_report(){

## generate a report of start pids finish status

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
    prepare_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  prepare_generic_display_msgColourSimple "SUCCESS" "ALL SERVERS:  dse + agent started"
fi
}
