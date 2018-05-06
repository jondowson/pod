function pod_REMOVE-PODS(){

## globally declare arrays utilised by this pod
## this will make their contents available to functions outside of the function that populates it
# n/a for this pod

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

stage_generic_stubs_testConnectivity  "1" "5"
stage_generic_stubs_testWritePaths    "2" "5" "${BUILDPATHS_WRITETEST}" "${JSONPATHS_WRITETEST}"   # set in build_settings.bash
stage_stubs_buildSendPod              "3" "5"
stage_generic_stubs_launchPod         "4" "5"
stage_stubs_finish                    "5" "5"
}
