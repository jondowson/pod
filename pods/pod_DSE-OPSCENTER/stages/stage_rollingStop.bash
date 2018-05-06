function task_rollingStop(){

## for each server stop dse based on its json defined mode

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

  # [3] display messages
  GENERIC_prepare_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}$pub_ip${white} on os ${yellow}${remote_os}${reset}"
  lib_doStuffRemotely_getOpscenterVersion
  lib_doStuffRemotely_getAgentVersion

  # [4] stop opscenter
  lib_doStuffRemotely_stopOpscenter

done
}

# -------------------------------------------

function task_rollingStop_report(){

## generate a report of all failed ssh connectivity attempts

declare -a stop_opscenter_report_array
count=0
for k in "${!arrayStopDse[@]}"
do
  GENERIC_lib_strings_expansionDelimiter ${arrayStopOpscenter[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    stop_dse_fail="true"
    stop_opscenter_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with error code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${stop_opscenter_fail}" == "true" ]]; then
  printf "%s\n"
  for k in "${stop_opscenter_report_array[@]}"
  do
    GENERIC_prepare_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  GENERIC_prepare_display_msgColourSimple "SUCCESS" "Each server:  opscenter stopped"
fi
}
