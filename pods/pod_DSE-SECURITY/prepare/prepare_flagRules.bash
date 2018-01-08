# about:    rules for handling flags for this pod

# ------------------------------------------

function prepare_flagRules(){

## rules for accepting flags
errorTag="prepare_flagRules()"

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags and values - please check the help: ${yellow}./launch-pod --pod ${WHICH_POD} --help${red}"

# PART 1: check flag combinations are acceptable for this mode of operation
if [[ "${buildFlag}" != "true" ]] || [[ ${serversFlag} != "true" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;

# PART 2: check values are acceptable for this mode of operation
elif [[ "${BUILD_FOLDER}" == "" ]] || [[ "${SERVERS_JSON}" == "" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;
fi
}
