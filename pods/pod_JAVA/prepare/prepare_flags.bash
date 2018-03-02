# about:    rules for handling flags for pod_JAVA

# ------------------------------------------

function prepare_flags_rules(){

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags - please check the help: ${yellow}./launch-pod --help"
buildFolderErrMsg="You must supply a value for ${yellow}--build${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"
servJsonErrMsg="You must supply a value for ${yellow}--servers${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"
sendSoftErrMsg="You must supply valid values for ${yellow}--sendsoft${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"

# PART 1: check all required flags have been passed
if [[ ${buildFlag} != "true" ]] || [[ ${serversFlag} != "true" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}"     && exit 1;

# PART 2: check passed flag values are acceptable
elif [[ ${BUILD_FOLDER} == "" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "${buildFolderErrMsg}" && exit 1;
elif [[ ${SERVERS_JSON} == "" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "${servJsonErrMsg}"    && exit 1;
elif [[ ${sendsoftFlag} == "true" ]] && [[ "${SEND_POD_SOFTWARE}" != "true" ]] && [[ "${SEND_POD_SOFTWARE}" != "false" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "${sendSoftErrMsg}"    && exit 1;
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
    *)
      printf "%s\n"
      prepare_generic_display_msgColourSimple "ERROR-->" "Not a recognised flag ${yellow}${1}${red}"
      exit 1;
        ;;
  esac
done
}
