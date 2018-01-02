# author:        jondowson
# about:         configure dse software and distribute to all servers in cluster

# ------------------------------------------

## pod desription: pod_JAVA

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# pod_JAVA makes use of 2 user defined files and has 5 STAGES.

# --> ${SERVERS_JSON}
# --> ${BUILD_FOLDER}cluster_settings.sh
# and a Java version specific in build_settings.bash
# --> ${BUILD_FOLDER}build_settings.bash

# STAGE [1] - test cluster connections
# --> test defined paths can be written to.

# STAGE [2] - test cluster write paths
# --> test that ssh can connect.

# STAGE [3] - build and send pod build
# --> duplicate 'pod 'project to a temporary folder and configure for each server.
# --> copy the duplicated and configured version - the pod 'build' - to each server.

# STAGE [4] - build and send software tarballs
# --> copy over the 'POD_SOFTWARE' folder to each server.

# STAGE [5] - execute pod remotely
# --> remotely run 'launch-pod.sh' on each server.

# ------------------------------------------

function pod_JAVA(){

## create arrays for capturing errors

declare -A ifsDelimArray
declare -A pod_test_connect_error_array
declare -A pod_test_send_error_array_1
declare -A pod_build_send_error_array
declare -A pod_software_send_pid_array
declare -A pod_build_run_pid_array
declare -A pod_build_launch_pid_array
declare -A pod_start_dse_error_array
declare -A pod_stop_dse_error_array

# ------------------------------------------

## test specified files exist

prepare_misc_checkFilesExist

# ------------------------------------------

# create configurable temp version of pod
catchError "pod_JAVA.sh#1" "true" "false" prepare_generic_misc_podBuildTempFolder

# ------------------------------------------

## STAGES

## STAGE [1]

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster connections"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2${white} 3 4 5 6 ]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server connectivity"
task_generic_testConnectivity
task_generic_testConnectivity_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [2]

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster write-paths"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3${white} 4 5 6 ]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server write-paths"
task_testWritePaths
task_testWritePaths_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [3]

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Send POD_SOFTWARE folder"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4${white} 5 6 ]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Send software in parallel"

if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
  task_generic_sendPodSoftware
  task_generic_sendPodSoftware_report
else
  lib_generic_display_msgColourSimple "ALERT-->" "You have opted to skip this STAGE"
  printf "%s\n"
fi
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [4]

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Build and send pod"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 5${white} 6 ]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Configure and send bespoke pod"
task_buildSend
task_buildSend_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [5]

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Launch pod on cluster"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 5 6${white} ]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Run launch script remotely"
task_generic_launchPodRemotely
task_generic_launchPodRemotely_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## FINISH

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "FINISHED !!"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 5 6${white} ]${reset}"
task_buildSend_report
if [[ "${SEND_POD_SOFTWARE}" == true ]]; then task_generic_sendPodSoftware_report; fi
task_generic_launchPodRemotely_report

}
