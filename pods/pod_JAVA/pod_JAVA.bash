# about:    call in order the stages for this pod

# ------------------------------------------

function pod_JAVA(){

## globally declare arrays utilised by this pod
## this will make their contents available to functions outside of the function that populates it
# n/a for this pod

## declare all paths (; seperated) to be write tested
## no need to specify target_folder as automatically added !!
## supply the variable string and omit the '$' - e.g "this_path;that_path"
buildPathsToCheck="TEMP_FOLDER"
jsonPathsToCheck=""

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

stage_generic_stubs_testConnectivity  "1" "6"
stage_generic_stubs_testWritePaths    "2" "6" "${buildPathsToCheck}" "${jsonPathsToCheck}"
stage_generic_stubs_sendPodSoftware   "3" "6"
stage_stubs_buildSendPod              "4" "6"
stage_generic_stubs_launchPod         "5" "6"
stage_stubs_finish                    "6" "6"
}
