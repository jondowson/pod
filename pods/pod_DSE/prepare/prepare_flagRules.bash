# author:        jondowson
# about:         rules for handling flags for pod_DSE

# ------------------------------------------

function prepare_flagRules(){

## rules for accepting flags
errorTag="prepare_flagRules()"

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags - please check the help: ${yellow}./launch-pod --help${red}"
servJsonErrMsg="You must supply a server .json definition file - please check the help: ${yellow}./launch-pod --help${red}"

# check flags and values for this mode of operation
if [[ "${clusterstateFlag}" == "true" ]]; then
    # part 1 - check flag combinations
    if [[ "${buildFlag}" != "true" ]] || [[ ${sendsoftFlag} == "true" ]]  || [[ ${regenresourcesFlag} == "true" ]]; then
      lib_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;
    elif [[ "${serversFlag}" != "true" ]]; then
      lib_generic_display_msgColourSimple "ERROR-->" "${servJsonErrMsg}" && exit 1;
    # part 2 - check values are acceptable
  elif [[ "${CLUSTER_STATE}" != "stop" ]] && [[ ${CLUSTER_STATE} != "start" ]]; then
      lib_generic_display_msgColourSimple "ERROR-->" "You must specify --clusterstate as either ${yellow}stop${red} or ${yellow}start${red}" && exit 1;
    fi

# check flags and values for this mode of operation
else
  # part 1 - check flag combinations
  if [[ "${buildFlag}" != "true" ]] && [[ ${serversFlag} != "true" ]]; then
    lib_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;
  # part 2 - check values are acceptable
elif [[ "${BUILD_FOLDER}" == "" ]]; then
    lib_generic_display_msgColourSimple "ERROR-->" "You must supply a value for ${yellow}--builds${red} - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
  elif [[ "${SERVERS_JSON}" == "" ]]; then
    lib_generic_display_msgColourSimple "ERROR-->" "You must supply a value for ${yellow}--servers${red} - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
  elif [[ "${regenresourcesFlag}" == "true" ]] && [[ "${REGENERATE_RESOURCES}" == "" ]] || [[ ${sendsoftFlag} == "true" ]] && [[ "${SEND_POD_SOFTWARE}" == "" ]]; then
     lib_generic_display_msgColourSimple "ERROR-->" "You must supply values for ${yellow}--regenresources${red} and ${yellow}--sendsoft${red} flags - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
  fi
fi
}
