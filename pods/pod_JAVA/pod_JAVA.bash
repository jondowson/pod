function pod_JAVA(){

## globally declare arrays utilised by this pod so their contents are available to other functions
# n/a for this pod

# ------------------------------------------

## STAGES

## Workflow of STAGES through TASKS to ACTIONS
# [1] CALL ALL STAGES - in order from this file:
# --> pod_<NAME>.bash
# [2] FOR EACH STAGE  - use its composition stub function:
# --> generic stubs:           pod_/stages/stages_generic_stubs.bash
# --> pod specific stubs:      pod_<NAME>/stages/stages_stubs.bash
# [3] STAGE STUB FUNCTIONS call STAGE TASKS:
# --> generic tasks:           pod_ 'stages' folder
# --> pod specific tasks:      this pod's 'stages' folder
# [4] TASKS call ACTIONS (functions):
# --> generic functions:       pod_ 'lib' folder
# --> pod specific functions:  this pod's 'lib' folder

GENERIC_stages_stubs_testConnectivity   "1" "6"
GENERIC_stages_stubs_testWritePaths     "2" "6" "${BUILDPATHS_WRITETEST}" "${JSONPATHS_WRITETEST}"   # set in build_settings.bash
GENERIC_stages_stubs_sendPodSoftware    "3" "6"
stages_stubs_buildSendPod               "4" "6"
GENERIC_stages_stubs_launchPodRemotely  "5" "6"
stages_stubs_finish                     "6" "6"
}
