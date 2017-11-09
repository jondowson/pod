#!/bin/bash

# script_name:   pod_dse.sh
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

# STAGE [1] - test cluster readiness
# --> test that ssh can connect.
# --> test defined paths can be written to.

# STAGE [2] - locally prepare 'resources' folder
# --> will strip all non-config files from the 'resources' folder in the dse-<version> tarball.
# --> copy to ${BUILD_FOLDER}resources.
# --> OPTIONAL if one already exists.

# STAGE [3] - loop over servers
# --> duplicate 'pod 'project to a temporary folder and configure for each server.
# --> copy the duplicated and configured version - the pod 'build' - to each server.

# STAGE [4] - loop over servers
# --> copy over the 'DSE_SOFTWARE' folder to each server.

# STAGE [5] - loop over servers
# --> remotely run 'setup_dse_remote.sh' on each server.

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

# ------------------------------------------

## test specified files exist

pod_dse_setup_checkFilesExist

# ------------------------------------------

## STAGE [1]

# prepare local copy of dse 'resources' folder - the basis for each distributed pod build
destination_folder_parent_path="${pod_home_path}/builds/pod_dse/${BUILD_FOLDER}/"
destination_folder_path="${destination_folder_parent_path}resources/"
if [[ "${REGENERATE_RESOURCES}" == "true" ]] || [[ ! -d ${destination_folder_path} ]]; then
  pod_dse_display_banner
  pod_generic_display_msgColourSimple "STAGE" "STAGE: Preparing dse 'resources' Folder"
  pod_generic_display_msgColourSimple "TASK"  "TASK: Stripping out non config files"
  pod_dse_prepareResourcesFolder
  pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."
fi

# prepare duplicate version of 'pod' project
pod_dse_setup_duplicateResourcesFolder

# ------------------------------------------

## STAGE [2]

pod_dse_display_banner
pod_generic_display_msgColourSimple "STAGE" "STAGE: Test Cluster Readiness"
pod_generic_display_msgColourSimple "TASK"  "TASK: Testing server connectivity"
task_pod_test_connect
task_pod_test_connect_report
pod_generic_display_msgColourSimple "TASK"  "TASK: Testing server write-paths"
task_pod_test_write
task_pod_test_write_report
pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [3]

pod_dse_display_banner
pod_generic_display_msgColourSimple "STAGE" "STAGE: Create Pod For Each Server"
pod_generic_display_msgColourSimple "TASK"  "TASK: Configuring and sending pod "
task_pod_build_send
task_pod_build_send_report
rm -rf "${tmp_folder}"
pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [4]

if [[ "${SEND_DSE_SOFTWARE}" == true ]]; then
  pod_dse_display_banner
  pod_generic_display_msgColourSimple "STAGE" "STAGE: Send DSE_SOFTWARE To Each Server"
  pod_generic_display_msgColourSimple "TASK"  "TASK: Sending DSE_SOFTWARE in parallel"
  task_pod_software_send
  task_pod_software_send_report
  pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."
fi

# ------------------------------------------

## STAGE [5]

pod_dse_display_banner
pod_generic_display_msgColourSimple "STAGE" "STAGE: Launch Pod On Each Server"
pod_generic_display_msgColourSimple "TASK"  "TASK: Running launch script remotely"
task_pod_launch_remote
task_pod_launch_remote_report
pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## FINNISH

pod_dse_display_banner
pod_generic_display_msgColourSimple "STAGE" "FINISHED !!"                                                                        && sleep "${STEP_PAUSE}"
task_pod_build_send_report
task_pod_launch_remote_report
pod_generic_display_msgColourSimple "TASK" "Next Steps"                                                                          && sleep "${STEP_PAUSE}"

# used when calculating script timings
if   [[ "${REGENERATE_RESOURCES}" == "true" ]]  &&  [[ "${SEND_DSE_SOFTWARE}" == "true" ]]; then
  stage_count=5
elif [[ "${REGENERATE_RESOURCES}" == "false" ]] &&  [[ "${SEND_DSE_SOFTWARE}" == "true" ]] ; then
  stage_count=3
elif [[ "${REGENERATE_RESOURCES}" == "true" ]]  &&  [[ "${SEND_DSE_SOFTWARE}" == "false" ]] ; then
  stage_count=4
else
  stage_count=2
fi
}
