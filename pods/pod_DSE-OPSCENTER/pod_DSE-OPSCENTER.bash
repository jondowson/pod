# about:    call in order the stages for this pod

# ------------------------------------------

function pod_DSE-OPSCENTER(){

## globally declare arrays utilised by this pod
## this will make their contents available to functions outside of the function that populates it
declare -A build_send_error_array       # stage_buildSend.bash
declare -A start_opscenter_error_array  # stage_rollingStart.bash
declare -A stop_opscenter_error_array   # stage_rollingStop.bash

## declare all paths (; seperated) to be write tested
## no need to specify target_folder as automatically added !!
## supply the variable string and omit the '$' - e.g "this_path;that_path"
buildPathsToCheck="TEMP_FOLDER"
jsonPathsToCheck=""

# ------------------------------------------

## STAGES
##     generic stages are composed in:   pod_/stages/stage_generic_stubs.bash
## non-generic stages are composed in:   pod_DSE/stages/stage_stubs.bash

# stopping/starting opscenter nodes
if [[ "${clusterstateFlag}" == "true" ]]; then

  stage_generic_stubs_testConnectivity  "1" "3"
  stage_stubs_stopStartCluster          "2" "3"
  stage_stubs_finish                    "3" "3"

# installing pod_DSE-OPSCENTER
else

  stage_generic_stubs_testConnectivity  "1" "6"
  stage_generic_stubs_testWritePaths    "2" "6" "${buildPathsToCheck}" "${jsonPathsToCheck}"
  stage_generic_stubs_sendPodSoftware   "3" "6"
  stage_stubs_buildSendPod              "4" "6"
  stage_generic_stubs_launchPod         "5" "6"
  stage_stubs_finish                    "6" "6"
fi
}
