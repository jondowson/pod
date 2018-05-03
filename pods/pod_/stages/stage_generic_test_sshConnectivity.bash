# about:    test connectivity and write-paths for all servers in servers json definition

#-------------------------------------------

function task_generic_testConnectivity(){

## for each server test ssh connectivity + authorisation

for id in $(seq 1 ${numberOfServers});
do

  # [1] assign json variable to bash variables
  tag=$(jq            -r '.server_'${id}'.tag'            "${servers_json_path}")
  user=$(jq           -r '.server_'${id}'.user'           "${servers_json_path}")
  sshKey=$(jq         -r '.server_'${id}'.sshKey'         "${servers_json_path}")
  target_folder=$(jq  -r '.server_'${id}'.target_folder'  "${servers_json_path}")
  pubIp=$(jq          -r '.server_'${id}'.pubIp'          "${servers_json_path}")
  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

  # [2] display message
  prepare_generic_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}$pubIp${reset}" #&& printf "\n%s"
  prepare_generic_display_msgColourSimple "INFO-->" "testing ssh:"

  # [3] test ssh connectivity 5 times
  status="999"
  if [[ "${status}" != "0" ]]; then
    retry=1
    until [[ "${retry}" == "6" ]] || [[ "${status}" == "0" ]]
    do
      lib_generic_checks_fileExists "stage_generic_test_sshConnectivity.sh#1" "true" "${sshKey}"
      # determine remote server os as test
      lib_generic_doStuff_remotely_identifyOs
      status=${?}
      if [[ "${status}" == "0" ]]; then
        prepare_generic_display_msgColourSimple "INFO-->" "ssh return code:       ${green}${status}"
      else
        prepare_generic_display_msgColourSimple "INFO-->" "ssh return code:       ${red}${status}${white}(retry ${retry}/5)"
      fi
      test_connect_error_array["${tag}"]="${status};${pubIp}"
      ((retry++))
    done
  fi
done
}

#-------------------------------------------

function task_generic_testConnectivity_report(){

## generate a report of all failed ssh connectivity attempts

declare -a pod_test_connect_report_array
count=0
for k in "${!test_connect_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${test_connect_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    pod_test_connect_fail="true"
    pod_test_connect_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with error code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${pod_test_connect_fail}" == "true" ]]; then
  printf "%s\n"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}Connection errors report:"
  printf "%s\n"
  for k in "${pod_test_connect_report_array[@]}"
  do
    prepare_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
  printf "%s\n"
  prepare_generic_display_msgColourSimple "ERROR" "Aborting script as not all servers are reachable"
  exit 1;
else
  prepare_generic_display_msgColourSimple "SUCCESS" "Each server:  connectivity test passed"
fi
}
