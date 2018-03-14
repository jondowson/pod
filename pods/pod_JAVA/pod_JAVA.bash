# about:         distribute + configure Java to all servers in cluster

# ------------------------------------------

## pod desription: pod_JAVA

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# pod_JAVA makes use of 2 user defined files and has 6 STAGES.

# --> ${SERVERS_JSON}
# --> ${BUILD_FOLDER}build_settings.bash

# STAGE [1] - test cluster connections
# --> test defined paths can be written to.

# STAGE [2] - test cluster write paths
# --> test that ssh can connect and create a dummy folder to each specified write path.

# STAGE [3] - build and send software tarballs
# --> copy over the 'POD_SOFTWARE' folder to each server.

# STAGE [4] - build and send pod build
# --> duplicate 'pod 'project to a temporary folder and configure for each server.
# --> copy the duplicated and configured version - the pod 'build' - to each server.

# STAGE [5] - execute pod remotely
# --> remotely run 'launch-pod.sh' on each server.

# STAGE [6] - pod summary
# --> report for each stage.

# ------------------------------------------

function pod_JAVA(){

## globally declare arrays utilised by this pod

declare -A build_send_error_array       # stage_buildSend

# ------------------------------------------

## STAGES

## STAGE [1]

prepare_generic_display_stageCount        "Test server connectivity" "1" "6"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Testing server connectivity"
task_generic_testConnectivity
task_generic_testConnectivity_report
prepare_generic_display_stageTimeCount

# ------------------------------------------

## STAGE [2]

prepare_generic_display_stageCount        "Test cluster write-paths" "2" "6"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Testing server write-paths"
# semi-colon delimeter any elements containing paths to be write tested: "from build_settings.bash" "from server json"
task_generic_testWritePaths "TEMP_FOLDER" ""
task_generic_testWritePaths_report
prepare_generic_display_stageTimeCount

# ------------------------------------------

## STAGE [3]

prepare_generic_display_stageCount        "Send POD_SOFTWARE folder" "3" "6"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Send software in parallel"

if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
  task_generic_sendPodSoftware
  task_generic_sendPodSoftware_report
else
  prepare_generic_display_msgColourSimple "ALERT-->" "You have opted to skip this STAGE"
  printf "%s\n"
fi
prepare_generic_display_stageTimeCount

# ------------------------------------------

## STAGE [4]

prepare_generic_display_stageCount        "Build and send bespoke pod" "4" "6"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Configure locally and distribute"
task_buildSend
task_buildSend_report
prepare_generic_display_stageTimeCount

# ------------------------------------------

## STAGE [5]

prepare_generic_display_stageCount        "Launch pod remotely" "5" "6"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Execute launch script on each server"
task_generic_launchPodRemotely
task_generic_launchPodRemotely_report
prepare_generic_display_stageTimeCount

# ------------------------------------------

## STAGE [6] FINISH

prepare_generic_display_stageCount        "Summary" "6" "6"
prepare_generic_display_msgColourSimple   "REPORT" "STAGE REPORT:${reset}"
task_generic_testConnectivity_report
task_generic_testWritePaths_report
if [[ "${SEND_POD_SOFTWARE}" == true ]]; then task_generic_sendPodSoftware_report; fi
task_buildSend_report
task_generic_launchPodRemotely_report
}
