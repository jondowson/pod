function prepare_flags_rules(){

## rules for accepting flags

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags - please check the help: ${yellow}pod --help"
buildFolderErrMsg="You must supply a value for ${yellow}--build${red} --> please check this pod's help: ${yellow}pod -p ${WHICH_POD} --help"
servJsonErrMsg="You must supply a value for ${yellow}--servers${red} --> please check this pod's help: ${yellow}pod -p ${WHICH_POD} --help"
removePodErrMsg="You must supply valid values for ${yellow}--removepod${red} --> please check this pod's help: ${yellow}pod -p ${WHICH_POD} --help"

# part 1 - check flag combinations
if [[ ${buildFlag} != "true" ]] || [[ ${serversFlag} != "true" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}"       && exit 1;
# part 2 - check values are acceptable
elif [[ ${BUILD_FOLDER} == "" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "${buildFolderErrMsg}"   && exit 1;
elif [[ ${SERVERS_JSON} == "" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "${buildFolderErrMsg}"   && exit 1;
elif [[ ${removepodFlag} != "true" ]] || [[ "${REMOVE_POD}" == "" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "${removePodErrMsg}"     && exit 1;
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
    -rp|--removepod)
        REMOVE_POD=$value
        removepodFlag="true"
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
