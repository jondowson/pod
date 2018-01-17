# about:    rules for handling flags for this pod

# ------------------------------------------

function prepare_flagRules(){

## rules for accepting flags

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags - please check the help: ${yellow}./launch-pod --help"
buildFolderErrMsg="You must supply a value for ${yellow}--build${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"
servJsonErrMsg="You must supply a value for ${yellow}--servers${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"
removePodErrMsg="You must supply valid values for ${yellow}--removepod${red} --> please check this pod's help: ${yellow}./launch-pod -p ${WHICH_POD} --help"

# part 1 - check flag combinations
if [[ ${buildFlag} != "true" ]] || [[ ${serversFlag} != "true" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}"       && exit 1;
# part 2 - check values are acceptable
elif [[ ${BUILD_FOLDER} == "" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${buildFolderErrMsg}"   && exit 1;
elif [[ ${SERVERS_JSON} == "" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${buildFolderErrMsg}"   && exit 1;
elif [[ ${removepodFlag} != "true" ]] || [[ "${REMOVE_POD}" == "" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${removePodErrMsg}"     && exit 1;
fi
}
