# about:    call in order the stages for this pod

# ------------------------------------------

function pod_JAVA(){

## globally declare arrays utilised by this pod

declare -A build_send_error_array     # stage_buildSend.bash

# ------------------------------------------

## STAGES

## note:
#     generic stages are composed in:   pod_/stages/stage_generic_stubs.bash
# non-generic stages are composed in:   pod_DSE/stages/stage_stubs.bash

stage_generic_stubs_testConnectivity  "1" "6"
stage_generic_stubs_testWritePaths    "2" "6" "TEMP_FOLDER" ""
stage_generic_stubs_sendPodSoftware   "3" "6"
stage_stubs_buildSendPod              "4" "6"
stage_generic_stubs_launchPod         "5" "6"
stage_stubs_finish                    "6" "6"
}
