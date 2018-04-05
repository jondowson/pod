# about:    call in order the stages for this pod

# ------------------------------------------

function pod_DSE-OPSCENTER(){

## globally declare arrays utilised by this pod

declare -A build_send_error_array       # stage_buildSend.bash
declare -A start_opscenter_error_array  # stage_rollingStart.bash
declare -A stop_opscenter_error_array   # stage_rollingStop.bash

# ------------------------------------------

## STAGES

## note:
#     generic stages are composed in pods/pod_:   /stages/stage_generic_stubs.bash
# non-generic stages are composed in this pod:    /stages/stage_stubs.bash

# stopping/starting opscenter nodes
if [[ "${clusterstateFlag}" == "true" ]]; then

  stage_generic_stubs_testConnectivity  "1" "3"
  stage_stubs_stopStartCluster          "2" "3"
  stage_stubs_finish                    "3" "3"

# installing pod_DSE-OPSCENTER
else

  stage_generic_stubs_testConnectivity  "1" "6"
  stage_generic_stubs_testWritePaths    "2" "6" "TEMP_FOLDER" ""
  stage_generic_stubs_sendPodSoftware   "3" "6"
  stage_stubs_buildSendPod              "4" "6"
  stage_generic_stubs_launchPod         "5" "6"
  stage_stubs_finish                    "6" "6"
fi
}
