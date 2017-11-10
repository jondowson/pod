#!/bin/bash

# script_name:   pod_dse_startStop.sh
# author:        jondowson
# about:         start | stop a dse cluster based on a pod server json definition file

# ------------------------------------------

## pod desription: 'pod_dse'

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# required inputs:
# 'pod_dse_startStop' makes use of 1 user defined files and has 5 STAGES.
# --> ${SERVERS_JSON}

# STAGE [1] - test cluster readiness
# --> test that ssh can connect.

# STAGE [2] - loop over servers and one by one (rolling) issue graceful start |stop command 
# --> start | stop each server passing flags (-s -k -g) based on its servers json definition

# ------------------------------------------

function pod_dse(){

## create arrays for capturing errors

declare -A pod_test_connect_error_array
declare -A pod_start_dse_error_array

# ------------------------------------------

## test specified files exist

pod_dse_startStop_setup_checkFilesExist

# ------------------------------------------

## STAGE [1]

pod_dse_display_banner
pod_generic_display_msgColourSimple "STAGE" "STAGE: Test Cluster Readiness"
pod_generic_display_msgColourSimple "TASK"  "TASK: Testing server connectivity"
task_pod_start_dse
task_pod_start_dse_report
pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [2]

pod_dse_display_banner
pod_generic_display_msgColourSimple "STAGE" "STAGE: Create Pod For Each Server"
pod_generic_display_msgColourSimple "TASK"  "TASK: Configuring and sending pod "

pod_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## FINNISH

pod_dse_display_banner
pod_generic_display_msgColourSimple "STAGE" "FINISHED !!"                                                                        && sleep "${STEP_PAUSE}"
task_pod_start_dse_report
pod_generic_display_msgColourSimple "TASK" "Next Steps"                                                                          && sleep "${STEP_PAUSE}"

}
