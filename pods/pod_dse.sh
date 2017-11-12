#!/bin/bash

# author:        jondowson
# about:         configure dse software and distribute to all servers in cluster

# ------------------------------------------

## pod desription: 'pod_dse'

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# 'pod_dse' makes use of 2 user defined files and has 5 STAGES.

# --> ${SERVERS_JSON}
# --> ${BUILD_FOLDER}cluster_settings.sh
# and a DSE version specific prepared 'resources' folder.
# --> ${BUILD_FOLDER}resources

# STAGE [0] - optionally prepare local 'resources' folder
# --> will strip all non-config files from the 'resources' folder in the dse-<version> tarball.
# --> copy to ${BUILD_FOLDER}resources.
# --> OPTIONAL if one already exists.

# STAGE [1] - test cluster connections
# --> test defined paths can be written to.

# STAGE [2] - test cluster write paths
# --> test that ssh can connect.

# STAGE [3] - build and send pod build
# --> duplicate 'pod 'project to a temporary folder and configure for each server.
# --> copy the duplicated and configured version - the pod 'build' - to each server.

# STAGE [4] - build and send software tarballs
# --> copy over the 'DSE_SOFTWARE' folder to each server.

# STAGE [5] - execute pod remotely
# --> remotely run 'launch-pod.sh' on each server.

# ------------------------------------------

function pod_dse(){

## create arrays for capturing errors

declare -A pod_test_connect_error_array
declare -A pod_test_send_error_array_1
declare -A pod_test_send_error_array_2
declare -A pod_test_send_error_array_3
declare -A pod_build_send_error_array
declare -A pod_software_send_pid_array
declare -A pod_build_run_pid_array
declare -A pod_build_launch_pid_array
declare -A pod_start_dse_error_array
declare -A pod_stop_dse_error_array

# ------------------------------------------

## test specified files exist

pod_dse_setup_checkFilesExist

# ------------------------------------------

## STAGE [0] - optional

# prepare local copy of dse 'resources' folder - the basis for each distributed pod build
destination_folder_parent_path="${pod_home_path}/builds/pod_dse/${BUILD_FOLDER}/"
destination_folder_path="${destination_folder_parent_path}resources/"
if [[ "${REGENERATE_RESOURCES}" == "true" ]] || [[ "${REGENERATE_RESOURCES}" == "edit" ]] || [[ ! -d ${destination_folder_path} ]]; then
  pod_generic_display_banner
  pod_generic_display_msgColourSimple "STAGE" "STAGE: Prepare 'resources' Folder"
  pod_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}0${white} 1 2 3 4 5 ]${reset}"
  pod_generic_display_msgColourSimple "TASK"  "TASK: Strip out all non config files"
  pod_dse_prepareResourcesFolder
  if [[ "${REGENERATE_RESOURCES}" == "edit" ]]; then
    pod_generic_display_msgColourSimple "STAGE" "You can now edit each dse config in the folder ${yellow}${destination_folder_path}${reset}"
    printf "%s\n"
    exit 0;
  fi
  pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."
fi

# ------------------------------------------

# create duplicate version of 'pod' project
pod_dse_setup_duplicateResourcesFolder

# ------------------------------------------

## STAGE [1]

if [[ "${CLUSTER_STATE}" != "" ]]; then

  ## STAGE [1]

  pod_generic_display_banner
  pod_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster connections"
  pod_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1${white} 2 3 4 ]${reset}"
  pod_generic_display_msgColourSimple "TASK"       "TASK: Testing server connectivity"
  task_testConnectivity
  task_testConnectivity_report
  pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## STAGE [2]

  if [[ "${CLUSTER_STATE}" == "start" ]]; then
    pod_generic_display_banner
    pod_generic_display_msgColourSimple "STAGE" "STAGE: Starting DSE Cluster"
    pod_generic_display_msgColourSimple "STAGECOUNT" "[ 1 ${cyan}${b}2${white} ]${reset}"
    pod_generic_display_msgColourSimple "TASK"  "TASK: Starting each server in cluster"
    task_rollingStart
    task_rollingStart_report
  else
    pod_generic_display_banner
    pod_generic_display_msgColourSimple "STAGE" "STAGE: Stopping DSE Cluster"
    pod_generic_display_msgColourSimple "STAGECOUNT" "[ 1 ${cyan}${b}2${white} ]${reset}"
    pod_generic_display_msgColourSimple "TASK"  "TASK: Stopping each server in cluster"
    task_rollingStop
    task_rollingStop_report
  fi
  
  # change WHICH_POD to alter final messages
  WHICH_POD=${WHICH_POD}_rollingStartStop  
  
else

  # ------------------------------------------

  ## STAGE [1]

  pod_generic_display_banner
  pod_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster connections"
  pod_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1${white} 2 3 4 5 ]${reset}"
  pod_generic_display_msgColourSimple "TASK"       "TASK: Testing server connectivity"
  task_testConnectivity
  task_testConnectivity_report
  pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## STAGE [2]

  pod_generic_display_banner
  pod_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster write-paths"
  pod_generic_display_msgColourSimple "STAGECOUNT" "[ 1 ${cyan}${b}2${white} 3 4 5 ]${reset}"
  pod_generic_display_msgColourSimple "TASK"       "TASK: Testing server write-paths"
  task_testWritePaths
  task_testWritePaths_report
  pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## STAGE [3]

  pod_generic_display_banner
  pod_generic_display_msgColourSimple "STAGE"      "STAGE: Build and send pod"
  pod_generic_display_msgColourSimple "STAGECOUNT" "[ 1 2 ${cyan}${b}3${white} 4 5 ]${reset}"
  pod_generic_display_msgColourSimple "TASK"       "TASK: Configure and send bespoke pod"
  task_buildSend
  task_buildSend_report
  rm -rf "${tmp_folder}"
  pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## STAGE [4]

  pod_generic_display_banner
  pod_generic_display_msgColourSimple "STAGE" "STAGE: Send DSE_SOFTWARE folder"
  pod_generic_display_msgColourSimple "STAGECOUNT" "[ 1 2 3 ${cyan}${b}4${white} 5 ]${reset}"
  pod_generic_display_msgColourSimple "TASK"  "TASK: Send software in parallel"

  if [[ "${SEND_DSE_SOFTWARE}" == true ]]; then
    task_sendSoftware
    task_sendSoftware_report
  else
    pod_generic_display_msgColourSimple "alert" "You have opted to skip this STAGE"
    pod_generic_misc_timecount "3" "Proceeding to next STAGE..."
  fi
  
  pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."
  
  # ------------------------------------------

  ## STAGE [5]

  pod_generic_display_banner
  pod_generic_display_msgColourSimple "STAGE" "STAGE: Launch pod on cluster"
  pod_generic_display_msgColourSimple "STAGECOUNT" "[ 1 2 3 4 ${cyan}${b}5${white} ]${reset}"
  pod_generic_display_msgColourSimple "TASK"  "TASK: Run launch script remotely"
  task_launchRemote
  task_launchRemote_report
  pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## FINNISH

  pod_generic_display_banner
  pod_generic_display_msgColourSimple "STAGE" "FINISHED !!"
  task_buildSend_report
  if [[ "${SEND_DSE_SOFTWARE}" == true ]]; then task_sendSoftware_report; fi
  task_launchRemote_report

fi 
}
