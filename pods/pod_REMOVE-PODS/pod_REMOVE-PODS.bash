# about:    remove a named pod from POD_INSTALLS and any entries from bash_profile

# ------------------------------------------

## pod desription: pod_REMOVE-PODS

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# pod_REMOVE-PODS makes use of 2 user defined files and has 4 STAGES.

# --> ${SERVERS_JSON}
# --> ${BUILD_FOLDER}cluster_settings.sh
# and a Java version specific in build_settings.bash
# --> ${BUILD_FOLDER}build_settings.bash

# STAGE [1] - test cluster connections
# --> test defined paths can be written to.

# STAGE [2] - test cluster write paths
# --> test that ssh can connect and crete a dummy folder to each specified write path.

# STAGE [3] - build and send pod build
# --> duplicate 'pod 'project to a temporary folder and configure for each server.
# --> copy the duplicated and configured version - the pod 'build' - to each server.

# STAGE [4] - execute pod remotely
# --> remotely run 'launch-pod.sh' on each server.

# ------------------------------------------

function pod_REMOVE-PODS(){

## create pod specific arrays used by its stages

declare -A test_write_error_array     # test write path for folders
declare -A build_send_error_array     # test send pod build

# ------------------------------------------

## STAGES

## STAGE [1]

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Test server connectivity"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 ${white}2 3 4 5 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server connectivity"
task_generic_testConnectivity
task_generic_testConnectivity_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [2]

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster write-paths"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 ${white}3 4 5 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server write-paths"
task_testWritePaths
task_testWritePaths_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [3]

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Build and send bespoke pod"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 ${white}4 5 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Configure locally and distribute"
task_buildSend
task_buildSend_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [4]

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Launch pod remotely"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 ${white}5 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Execute launch script on each server"
task_generic_launchPodRemotely
task_generic_launchPodRemotely_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [5] FINISH

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "Summary"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 5${white} ]${reset}"
task_generic_testConnectivity_report
task_buildSend_report
task_generic_launchPodRemotely_report
}
