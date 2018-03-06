# about:         distribute + configure Java to all servers in cluster

# ------------------------------------------

## pod desription: pod_DSE-OPSCENTER

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# pod_DSE-OPSCENTER makes use of 2 user defined files and has 5 STAGES.

# --> ${SERVERS_JSON}
# --> ${BUILD_FOLDER}build_settings.bash

# STAGE [1] - test cluster connections
# --> test defined paths can be written to.

# STAGE [2] - test cluster write paths
# --> test that ssh can connect and crete a dummy folder to each specified write path.

# STAGE [3] - build and send software tarballs
# --> copy over the 'POD_SOFTWARE' folder to each server.

# STAGE [4] - build and send pod build
# --> duplicate 'pod 'project to a temporary folder and configure for each server.
# --> copy the duplicated and configured version - the pod 'build' - to each server.

# STAGE [5] - execute pod remotely
# --> remotely run 'launch-pod.sh' on each server.

# ------------------------------------------

function pod_DSE-OPSCENTER(){

## create pod specific arrays used by its stages

declare -A test_write_error_array     # test write path for folders
declare -A build_send_error_array     # test send pod build
declare -A build_launch_pid_array     # test launch pod scripts remotely

# ------------------------------------------

## STAGES

## STAGE [1]

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Test server connectivity"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 ${white}2 3 4 5 6 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server connectivity"
task_generic_testConnectivity
task_generic_testConnectivity_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [2]

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster write-paths"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 ${white}3 4 5 6 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server write-paths"
task_testWritePaths
task_testWritePaths_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [3]

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Send POD_SOFTWARE folder"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 ${white}4 5 6 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Send software in parallel"

if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
  task_generic_sendPodSoftware
  task_generic_sendPodSoftware_report
else
  prepare_generic_display_msgColourSimple "ALERT-->" "You have opted to skip this STAGE"
  printf "%s\n"
fi
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [4]

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Build and send bespoke pod"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 ${white}5 6 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Configure locally and distribute"
task_buildSend
task_buildSend_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [5]

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Launch pod remotely"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 5 ${white}6 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Execute launch script on each server"
task_generic_launchPodRemotely
task_generic_launchPodRemotely_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [6] FINISH

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "Summary"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 5 6${white} ]${reset}"
task_generic_testConnectivity_report
task_testWritePaths_report
task_buildSend_report
if [[ "${SEND_POD_SOFTWARE}" == true ]]; then task_generic_sendPodSoftware_report; fi
task_generic_launchPodRemotely_report
}
