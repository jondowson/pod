#!/bin/bash

# author:        jondowson
# about:         rules for handling flags for pod_JAVA

# ------------------------------------------

function prepare_flagRules(){

## rules for accepting flags
errorTag="prepare_flagRules()"

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags - please check the help: ${yellow}./launch-pod --help${red}"
servJsonErrMsg="You must supply a server .json definition file - please check the help: ${yellow}./launch-pod --help${red}"

# part 1 - check flag combinations
if [[ ${buildFlag} != "true" ]] || [[ ${serversFlag} != "true" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "${defaultErrMsg}" && exit 1;
# part 2 - check values are acceptable
elif [[ ${BUILD_FOLDER} == "" ]] && [[ ${removepodFlag} != "true" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "You must supply a value for ${yellow}--builds${red} - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
elif [[ ${SERVERS_JSON} == "" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "You must supply a value for ${yellow}--servers${red} - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
elif [[ ${removepodFlag} != "true" ]] || [[ ${removepodFlag} == "true" ]] && [[ "${REMOVE_POD}" == "" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "You must supply a value for ${yellow}--removepod${red} flag - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
elif [[ ${removepodFlag} == "true" ]] && [[ "${REMOVE_POD}" != "pod_DSE" ]] && [[ "${REMOVE_POD}" != "pod_JAVA" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "You must supply valid values for ${yellow}--removepod${red} flag - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
fi
}
