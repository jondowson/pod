# about:    rules for handling user supplied flags for this pod

# ------------------------------------------

function prepare_flagRules(){

## rules for accepting flags

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags - please check the help: ${yellow}./launch-pod --help"
buildFolderErrMsg="You must supply a value for ${yellow}--build${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"
servJsonErrMsg="You must supply a value for ${yellow}--servers${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"
sendSoftErrMsg="You must supply valid values for ${yellow}--sendsoft${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"

# PART 1: check all required flags have been passed
if [[ ${buildFlag} != "true" ]] || [[ ${serversFlag} != "true" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}"     && exit 1;

# PART 2: check passed flag values are acceptable
elif [[ ${BUILD_FOLDER} == "" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${buildFolderErrMsg}" && exit 1;
elif [[ ${SERVERS_JSON} == "" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${servJsonErrMsg}"    && exit 1;
elif [[ ${sendsoftFlag} == "true" ]] && [[ "${SEND_POD_SOFTWARE}" != "true" ]] && [[ "${SEND_POD_SOFTWARE}" != "false" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${sendSoftErrMsg}"    && exit 1;
fi
}
