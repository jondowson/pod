#!/bin/bash

# author:        jondowson
# about:         distribute java software and configure environment for each server

# ------------------------------------------

## pod desription: 'pod_java'

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# 'pod_java' makes use of 2 user defined files and has 5 STAGES.

# --> ${SERVERS_JSON}
# --> ${BUILD_FOLDER}cluster_settings.sh

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

function pod_dse(){

## create arrays for capturing errors

declare -A ifsDelimArray
declare -A pod_test_connect_error_array
declare -A pod_test_send_error_array_1
declare -A pod_test_send_error_array_2
declare -A pod_test_send_error_array_3
declare -A pod_build_send_error_array
declare -A pod_software_send_pid_array
declare -A pod_build_run_pid_array
declare -A pod_build_launch_pid_array

# ------------------------------------------

## test specified files exist

pod_java_setup_checkFilesExist

# ------------------------------------------

## STAGE [1]

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster connections"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1${white} 2 3 4 5 ]${reset}"
lib_generic_display_msgColourSimple "TASK"       "TASK: Testing server connectivity"
task_testConnectivity
task_testConnectivity_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [2]

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster write-paths"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ 1 ${cyan}${b}2${white} 3 4 5 ]${reset}"
lib_generic_display_msgColourSimple "TASK"       "TASK: Testing server write-paths"
task_testWritePaths
task_testWritePaths_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [3]

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Build and send pod"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ 1 2 ${cyan}${b}3${white} 4 5 ]${reset}"
lib_generic_display_msgColourSimple "TASK"       "TASK: Configure and send bespoke pod"
task_buildSend
task_buildSend_report
rm -rf "${tmp_folder}"
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [4]

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE" "STAGE: Send POD_SOFTWARE folder"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ 1 2 3 ${cyan}${b}4${white} 5 ]${reset}"
lib_generic_display_msgColourSimple "TASK"  "TASK: Send software in parallel"

if [[ "${SEND_POD_SOFTWARE}" == true ]]; then
  task_sendSoftware
  task_sendSoftware_report
else
  lib_generic_display_msgColourSimple "alert" "You have opted to skip this STAGE"
  lib_generic_misc_timecount "3" "Proceeding to next STAGE..."
fi

lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [5]

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE" "STAGE: Launch pod on cluster"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ 1 2 3 4 ${cyan}${b}5${white} ]${reset}"
lib_generic_display_msgColourSimple "TASK"  "TASK: Run launch script remotely"
task_launchRemote
task_launchRemote_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## FINNISH

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE" "FINISHED !!"
task_buildSend_report
if [[ "${SEND_POD_SOFTWARE}" == true ]]; then task_sendSoftware_report; fi
task_launchRemote_report

}
