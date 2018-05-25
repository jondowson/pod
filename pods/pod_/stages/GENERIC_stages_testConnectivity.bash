function GENERIC_task_testConnectivity(){

## for each server test ssh connectivity + authorisation

# identify all keys for this json file from the first server block
#keys=$(jq -r '.server_1 | keys[]' ${serversJsonPath})

for id in $(seq 1 ${numberOfServers});
do

  # [1] for this server, loop through its json block and assign values to bash variables
  GENERIC_lib_json_assignValue;
  for key in "${!arrayJson[@]}"
  do
    declare $key=${arrayJson[$key]} &>/dev/null;
  done;
  # add trailing '/' to target_folder path if not present
  target_folder="$(GENERIC_lib_strings_addTrailingSlash ${target_folder})";

  # [2] display message
  GENERIC_prepare_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}$pub_ip${reset}";
  GENERIC_prepare_display_msgColourSimple "INFO-->" "testing ssh:";

  # [3] test ssh connectivity 5 times
  status="999";
  if [[ "${status}" != "0" ]]; then
    retry=1;
    until [[ "${retry}" == "6" ]] || [[ "${status}" == "0" ]]
    do
      GENERIC_lib_checks_fileExists "stages_testConnectivity.sh#1" "true" "${ssh_key}";
      # determine remote server os as test
      GENERIC_lib_doStuffRemotely_identifyOs;
      status=${?};
      if [[ "${status}" == "0" ]]; then
        GENERIC_prepare_display_msgColourSimple "INFO-->" "ssh return code:       ${green}${status}";
      else
        GENERIC_prepare_display_msgColourSimple "INFO-->" "ssh return code:       ${red}${status}${white}(retry ${retry}/5)";
      fi;
      arrayTestConnect["${tag}"]="${status};${pub_ip}";
      ((retry++));
    done;
  fi;
done;
};

#-------------------------------------------

function GENERIC_task_testConnectivity_report(){

## generate a report of all failed ssh connectivity attempts

declare -a pod_test_connect_report_array;
count=0;
for k in "${!arrayTestConnect[@]}"
do
  GENERIC_lib_strings_expansionDelimiter ${arrayTestConnect[$k]} ";" "1";
  if [[ "${_D1_}" != "0" ]]; then
    pod_test_connect_fail="true";
    pod_test_connect_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with error code ${red}${_D1_}${reset}";
    (( count++ ));
  fi;
done;

if [[ "${pod_test_connect_fail}" == "true" ]]; then
  printf "%s\n";
  GENERIC_prepare_display_msgColourSimple "INFO-BOLD" "--> ${red}Connection errors report:";
  printf "%s\n";
  for k in "${pod_test_connect_report_array[@]}"
  do
    GENERIC_prepare_display_msgColourSimple "INFO" "${cross} ${k}";
  done;
  printf "%s\n";
  GENERIC_prepare_display_msgColourSimple "ERROR" "Aborting script as not all servers are reachable";
  exit 1;
else
  GENERIC_prepare_display_msgColourSimple "SUCCESS" "Each server:  connectivity test passed";
fi;
};
