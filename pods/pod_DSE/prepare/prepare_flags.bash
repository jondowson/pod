function prepare_flags_rules(){

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags and values - please check the help: ${yellow}pod --pod ${WHICH_POD} --help${red}"
buildFolderErrMsg="You must supply a value for ${yellow}--build${red} --> please check this pod's help: ${yellow}pod -p ${WHICH_POD} --help"
servJsonErrMsg="You must supply a value for ${yellow}--servers${red} --> please check this pod's help: ${yellow}pod -p ${WHICH_POD} --help"
sendSoftErrMsg="You must supply valid values for ${yellow}--sendsoft${red} --> please check this pod's help: ${yellow}pod -p ${WHICH_POD} --help"
clusterStateValueErrMsg="You must specify --clusterstate as either ${yellow}stop${red} or ${yellow}restart${red}"

# MODE 1: rolling start/stop of cluster using pod_DSE
if [[ "${clusterstateFlag}" == "true" ]]; then

    # PART 1: check flag combinations are acceptable for this mode of operation
    if [[ "${buildFlag}" != "true" ]] || [[ "${serversFlag}" != "true" ]]; then
      prepare_generic_display_msgColourSimple "ERROR-->" "${buildServerErrMsg}" && exit 1;
    elif [[ ${sendsoftFlag} == "true" ]]  || [[ ${regenresourcesFlag} == "true" ]]; then
      prepare_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;

    # PART 2: check values are acceptable for this mode of operation
    elif [[ "${CLUSTER_STATE}" != "stop" ]] && [[ ${CLUSTER_STATE} != "restart" ]]; then
      prepare_generic_display_msgColourSimple "ERROR-->" "${clusterStateValueErrMsg}" && exit 1;
    fi

# MODE 2: installing DSE on cluster using pod_DSE
else

  # PART 1: check flag combinations are acceptable for this mode of operation
  if [[ "${buildFlag}" != "true" ]] || [[ ${serversFlag} != "true" ]]; then
    prepare_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;

  # PART 2: check values are acceptable for this mode of operation
  elif [[ ${BUILD_FOLDER} == "" ]]; then
    prepare_generic_display_msgColourSimple "ERROR-->" "${buildFolderErrMsg}" && exit 1;
  elif [[ ${SERVERS_JSON} == "" ]]; then
    prepare_generic_display_msgColourSimple "ERROR-->" "${servJsonErrMsg}"    && exit 1;
  elif [[ "${regenresourcesFlag}" == "true" ]] && [[ "${REGENERATE_RESOURCES}" == "" ]] || [[ ${sendsoftFlag} == "true" ]] && [[ "${SEND_POD_SOFTWARE}" == "" ]]; then
     prepare_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;
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
    -rr|--regenresources)
        REGENERATE_RESOURCES=$value
        regenresourcesFlag="true"
        break
        ;;
    -cs|--clusterstate)
        CLUSTER_STATE=$value
        clusterstateFlag="true"
        break
        ;;
    *)
      printf "%s\n"
      prepare_generic_display_msgColourSimple "ERROR-->" "Not a recognised flag ${yellow}${1}${red}"
      exit 1;
        ;;
  esac
done
}
