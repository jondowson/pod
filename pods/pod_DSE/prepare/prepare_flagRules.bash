# about:    rules for handling flags for this pod

# ------------------------------------------

function prepare_flagRules(){

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags and values - please check the help: ${yellow}./launch-pod --pod ${WHICH_POD} --help${red}"
buildFolderErrMsg="You must supply a value for ${yellow}--build${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"
servJsonErrMsg="You must supply a value for ${yellow}--servers${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"
sendSoftErrMsg="You must supply valid values for ${yellow}--sendsoft${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"
clusterStateValueErrMsg="You must specify --clusterstate as either ${yellow}stop${red} or ${yellow}restart${red}"

# MODE 1: rolling start/stop of cluster using pod_DSE
if [[ "${clusterstateFlag}" == "true" ]]; then

    # PART 1: check flag combinations are acceptable for this mode of operation
    if [[ "${buildFlag}" != "true" ]] || [[ "${serversFlag}" != "true" ]]; then
      lib_generic_display_msgColourSimple "ERROR-->" "${buildServerErrMsg}" && exit 1;
    elif [[ ${sendsoftFlag} == "true" ]]  || [[ ${regenresourcesFlag} == "true" ]]; then
      lib_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;

    # PART 2: check values are acceptable for this mode of operation
    elif [[ "${CLUSTER_STATE}" != "stop" ]] && [[ ${CLUSTER_STATE} != "restart" ]]; then
      lib_generic_display_msgColourSimple "ERROR-->" "${clusterStateValueErrMsg}" && exit 1;
    fi

# MODE 2: installing DSE on cluster using pod_DSE
else

  # PART 1: check flag combinations are acceptable for this mode of operation
  if [[ "${buildFlag}" != "true" ]] || [[ ${serversFlag} != "true" ]]; then
    lib_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;

  # PART 2: check values are acceptable for this mode of operation
  elif [[ ${BUILD_FOLDER} == "" ]]; then
    lib_generic_display_msgColourSimple "ERROR-->" "${buildFolderErrMsg}" && exit 1;
  elif [[ ${SERVERS_JSON} == "" ]]; then
    lib_generic_display_msgColourSimple "ERROR-->" "${servJsonErrMsg}"    && exit 1;
  elif [[ "${regenresourcesFlag}" == "true" ]] && [[ "${REGENERATE_RESOURCES}" == "" ]] || [[ ${sendsoftFlag} == "true" ]] && [[ "${SEND_POD_SOFTWARE}" == "" ]]; then
     lib_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;
  fi

fi
}
