#!/bin/bash

# script_name:   pod_dse.sh
# author:        jondowson
# about:         configure dse software and distribute to all servers in cluster

# ------------------------------------------

## a pod has STAGES, which consist of TASK(S), which contain STEP(S).

# pod_dse:

# makes use of 2 user defined files
# --> ${SERVERS_JSON}
# --> ${BUILD_FOLDER}cluster_settings.sh
# and a DSE version specific prepared 'resources' folder.
# --> ${BUILD_FOLDER}resources

# STAGE [1] - locally prepare 'resources' folder
# --> will strip all non-config files from the 'resources' folder in the dse-<version> tarball.
# --> copy to ${BUILD_FOLDER}resources.
# --> OPTIONAL if one already exists.

# STAGE [2] - loop over servers
# --> duplicate 'pod 'project to a temporary folder and configure for each server.
# --> copy the duplicated and configured version - the 'build' - to each server.

# STAGE [3] - loop over servers
# --> copy over the 'DSE_SOFTWARE' folder to each server.

# STAGE [4] - loop over servers
# --> remotely run 'setup_dse_remote.sh' on each server.

function pod_dse(){

#===========================================EDIT-ME!!

## specify settings to use

## script run options

# send DSE_SOFTWARE folder to each server
SEND_DSE_SOFTWARE="false"

# generate new 'CONFIG_FOLDER/resources' folder - will remove any existing one !!
REGENERATE_RESOURCES="false"

# verbose messages
VB="false"

# pauses i.e. time allowed to read screen
STAGE_PAUSE="5"   # between stages
STEP_PAUSE="2"    # between steps within a stage

#===========================================END!!

## test specified files exist

pod_dse_check_files_exist

# ------------------------------------------

# STAGE [1] - prepare local 'resources' folder - the basis for the 'build(s)'

if [ "${REGENERATE_RESOURCES}" == true ]; then ${pod_home_path}lib/pod_dse/pod_dse_script_prepare_resources_folder.sh "${BUILD_FOLDER}" "${STAGE_PAUSE}"; fi

# -----------------------------------------

## prepare duplicate version of 'pod' project

pod_dse_duplicate_resources_folder

#-------------------------------------------

## create arrays for capturing errors

declare -A pod_test_connect_error_array
declare -A pod_test_send_error_array_1
declare -A pod_test_send_error_array_2
declare -A pod_test_send_error_array_3
declare -A pod_build_send_error_array
declare -A pod_software_send_pid_array 
declare -A pod_build_run_pid_array
declare -A pod_build_launch_pid_array

#-------------------------------------------

## ( STAGES { TASKS [steps] } )

# STAGE [2]
 
banner
generic_msg_colour_simple "STAGE" "STAGE: Test Cluster Readiness"
generic_msg_colour_simple "TASK"  "TASK: Testing server connectivity"
task_pod_test_connect
task_pod_test_connect_report
generic_msg_colour_simple "TASK"  "TASK: Testing server write-paths"
task_pod_test_write
task_pod_test_write_report
generic_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ----------

# STAGE [3] 

banner
generic_msg_colour_simple "STAGE" "STAGE: Create Pod For Each Server"
generic_msg_colour_simple "TASK"  "TASK: Configuring and sending pod "
task_pod_build_send
task_pod_build_send_report
rm -rf "${tmp_folder}"
generic_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..." 

# ----------

# STAGE [4] 

if [[ "${SEND_DSE_SOFTWARE}" == true ]]; then
  banner
  generic_msg_colour_simple "STAGE" "STAGE: Send DSE_SOFTWARE To Each Server"
  generic_msg_colour_simple "TASK"  "TASK: Sending DSE_SOFTWARE in parallel"
  task_pod_software_send
  task_pod_software_send_report
  generic_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..." 
fi

# ----------

# STAGE [5] 

banner
generic_msg_colour_simple "STAGE" "STAGE: Launch Pod On Each Server"
generic_msg_colour_simple "TASK"  "TASK: Running launch script remotely"
task_pod_launch_remote
task_pod_launch_remote_report
generic_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..." 

#-------------------------------------------

# Finnish Summary 

banner
generic_msg_colour_simple "STAGE" "Finished !!"                                                                        && sleep "${STEP_PAUSE}"
task_pod_build_send_report
task_pod_launch_remote_report
generic_msg_colour_simple "TASK" "Next Steps"                                                                          && sleep "${STEP_PAUSE}"

# -----------------script timings

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
