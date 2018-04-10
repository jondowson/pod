# about:    call in order the stages for this pod

# ------------------------------------------

function pod_DSE(){

# globally declare arrays utilised by this pod's own stages
declare -A build_send_error_array     # stage_buildSend.bash
declare -a build_send_data_array      # stage_buildSend.bash
declare -A start_dse_error_array      # stage_rollingStart.bash
declare -A stop_dse_error_array       # stage_rollingStop.bash

# declare all paths (; seperated) from the build folder + json file that should be write tested
buildPathsToCheck="TEMP_FOLDER;PARENT_DATA_FOLDER;PARENT_LOG_FOLDER;spark_local_data;spark_worker_data;"
jsonPathsToCheck="cass_data;dsefs_data"

# ------------------------------------------

## STAGES
##     generic stages are composed in:   pod_/stages/stage_generic_stubs.bash
## non-generic stages are composed in:   pod_DSE/stages/stage_stubs.bash

# stopping/starting dse nodes
if [[ "${clusterstateFlag}" == "true" ]]; then

  stage_generic_stubs_testConnectivity  "1" "3"
  stage_stubs_stopStartCluster          "2" "3"
  stage_stubs_finish                    "3" "3"

# installing pod_DSE
else

  stage_stubs_createResourcesFolder     "1" "7"
  stage_generic_stubs_testConnectivity  "2" "7"
  stage_generic_stubs_testWritePaths    "3" "7"  "${buildPathsToCheck}" "${jsonPathsToCheck}"
  stage_generic_stubs_sendPodSoftware   "4" "7"
  stage_stubs_buildSendPod              "5" "7"
  stage_generic_stubs_launchPod         "6" "7"
  stage_stubs_finish                    "7" "7"
fi
}
