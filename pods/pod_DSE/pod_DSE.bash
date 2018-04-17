function pod_DSE(){

## globally declare arrays utilised by this pod
## this will make their contents available to functions outside of the function that populates it
declare -A start_dse_error_array      # populated in stage_rollingStart.bash
declare -A stop_dse_error_array       # populated in stage_rollingStop.bash

## declare all paths (; seperated) to be write tested
## no need to specify target_folder as automatically added !!
## supply the variable string and omit the '$' - e.g "data_path;log_path"
buildPathsToCheck="TEMP_FOLDER;PARENT_DATA_FOLDER;PARENT_LOG_FOLDER;spark_local_data;spark_worker_data;"
jsonPathsToCheck="cass_data;dsefs_data"

# ------------------------------------------

## STAGES

## Workflow of STAGES through TASKS to ACTIONS
## [1] CALL ALL STAGES - in order from this file:
## --> pod_<NAME>.bash
## [2] FOR EACH STAGE  - use its composition stub function:
## --> generic stubs:           pod_/stages/stage_generic_stubs.bash
## --> pod specific stubs:      pod_<NAME>/stages/stage_stubs.bash
## [3] STAGE STUB FUNCTIONS call STAGE TASKS:
## --> generic tasks:           pod_ 'stages' folder
## --> pod specific tasks:      this pod's 'stages' folder
## [4] TASKS call ACTIONS (functions):
## --> generic functions:       pod_ 'lib' folder
## --> pod specific functions:  this pod's 'lib' folder

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
