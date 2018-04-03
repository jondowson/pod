# about:    rules for handling flags for this pod

# ------------------------------------------

function prepare_flags_rules(){

## rules for accepting flags
errorTag="prepare_flagRules()"

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags and values - please check the help: ${yellow}pod --pod ${WHICH_POD} --help${red}"

# PART 1: check flag combinations are acceptable for this mode of operation
if [[ "${buildFlag}" != "true" ]] || [[ ${serversFlag} != "true" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;

# PART 2: check values are acceptable for this mode of operation
elif [[ "${BUILD_FOLDER}" == "" ]] || [[ "${SERVERS_JSON}" == "" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;
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
    *)
      printf "%s\n"
      prepare_generic_display_msgColourSimple "ERROR-->" "Not a recognised flag ${yellow}${1}${red}"
      exit 1;
        ;;
  esac
done
}
