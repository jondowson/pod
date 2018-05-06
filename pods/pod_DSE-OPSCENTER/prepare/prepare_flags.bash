function prepare_flags_rules(){

## rules for accepting flags

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags - please check the help: ${yellow}pod --help"
buildFolderErrMsg="You must supply a value for ${yellow}--build${red} --> please check this pod's help: ${yellow}pod -p ${WHICH_POD} --help"
servJsonErrMsg="You must supply a value for ${yellow}--servers${red} --> please check this pod's help: ${yellow}pod -p ${WHICH_POD} --help"
sendSoftErrMsg="You must supply valid values for ${yellow}--sendsoft${red} --> please check this pod's help: ${yellow}pod -p ${WHICH_POD} --help"
clusterStateValueErrMsg="You must specify --clusterstate as either ${yellow}stop${red} or ${yellow}restart${red}"

# MODE 1: rolling start/stop of cluster using pod_DSE-OPSCENTER
if [[ "${clusterstateFlag}" == "true" ]]; then

    # PART 1: check flag combinations are acceptable for this mode of operation
    if [[ "${buildFlag}" != "true" ]] || [[ "${serversFlag}" != "true" ]]; then
      GENERIC_prepare_display_msgColourSimple "ERROR-->" "${buildServerErrMsg}" && exit 1;
    elif [[ ${sendsoftFlag} == "true" ]]  || [[ ${regenresourcesFlag} == "true" ]]; then
      GENERIC_prepare_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;

    # PART 2: check values are acceptable for this mode of operation
    elif [[ "${CLUSTER_STATE}" != "stop" ]] && [[ ${CLUSTER_STATE} != "restart" ]]; then
      GENERIC_prepare_display_msgColourSimple "ERROR-->" "${clusterStateValueErrMsg}" && exit 1;
    fi

# MODE 2: installing opscenter on cluster using pod_DSE-OPSCENTER
else
  # PART 1: check all required flags have been passed
  if [[ ${buildFlag} != "true" ]] || [[ ${serversFlag} != "true" ]]; then
    GENERIC_prepare_display_msgColourSimple "ERROR-->" "${defaultErrMsg}"     && exit 1;

  # PART 2: check passed flag values are acceptable
  elif [[ ${BUILD_FOLDER} == "" ]]; then
    GENERIC_prepare_display_msgColourSimple "ERROR-->" "${buildFolderErrMsg}" && exit 1;
  elif [[ ${SERVERS_JSON} == "" ]]; then
    GENERIC_prepare_display_msgColourSimple "ERROR-->" "${servJsonErrMsg}"    && exit 1;
  elif [[ ${sendsoftFlag} == "true" ]] && [[ "${SEND_POD_SOFTWARE}" != "true" ]] && [[ "${SEND_POD_SOFTWARE}" != "false" ]]; then
    GENERIC_prepare_display_msgColourSimple "ERROR-->" "${sendSoftErrMsg}"    && exit 1;
  fi
fi
}

# ------------------------------------------

function prepare_flags_handle(){

flag=${1}
value=${2}

while test $# -gt 0; do
  case "$flag" in
    -s|--servers)
        SERVERS_JSON=$value
        serversFlag="true"
        break
        ;;
    -b|--build)
        BUILD_FOLDER=$value
        buildFlag="true"
        break
        ;;
    -ss|--sendsoft)
        SEND_POD_SOFTWARE=$value
        sendsoftFlag="true"
        break
        ;;
    -cs|--clusterstate)
        CLUSTER_STATE=$value
        clusterstateFlag="true"
        break
        ;;
    *)
      printf "%s\n"
      GENERIC_prepare_display_msgColourSimple "ERROR-->" "Not a recognised flag ${yellow}${1}${red}"
      exit 1;
        ;;
  esac
done
}
