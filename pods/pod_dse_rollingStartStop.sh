#!/bin/bash

# author:        jondowson
# about:         rolling start | stop of a dse cluster utilising a server json definition file

# ------------------------------------------

## pod desription: 'pod_dse'

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# required inputs:
# 'pod_dse_rollingStartStop' makes use of 1 user defined files and has 3 STAGES.
# --> ${SERVERS_JSON}

# STAGE [1] - test cluster readiness
# --> test that ssh can connect.

# STAGE [2] - loop over servers and one by one (rolling) issue graceful start |stop command
# --> start | stop each server passing flags (-s -k -g) based on its servers json definition

# ------------------------------------------

function pod_dse_rollingStartStop(){

## create arrays for capturing errors

declare -A pod_test_connect_error_array
declare -A pod_start_dse_error_array
declare -A pod_stop_dse_error_array

# ------------------------------------------

## test specified files exist

pod_dse_startStop_setup_checkFilesExist

# ------------------------------------------

## STAGE [1]

pod_generic_display_banner
pod_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster readiness"
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
fi

# ------------------------------------------

## STAGE [3]
if [[ "${CLUSTER_STATE}" == "stop" ]]; then
  pod_generic_display_banner
  pod_generic_display_msgColourSimple "STAGE" "STAGE: Stopping DSE Cluster"
  pod_generic_display_msgColourSimple "STAGECOUNT" "[ 1 ${cyan}${b}2${white} ]${reset}"
  pod_generic_display_msgColourSimple "TASK"  "TASK: Stopping each server in cluster"
  task_rollingStop
  task_rollingStop_report
fi
}
