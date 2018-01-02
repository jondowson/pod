#!/bin/bash

# author:        jondowson
# about:         establish and test ssh connection + authentication to each server

# ------------------------------------------

## pod desription: 'pod_SSH-TEST'

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# 'pod_SSH-AUTH' makes use of 1 user defined file andd has 1 STAGE.

# --> ${SERVERS_JSON}

# STAGE [1] - test cluster connections
# --> test that ssh can connect.

# ------------------------------------------

function pod_SSH-AUTH(){

## create arrays for capturing errors

declare -A ifsDelimArray
declare -A pod_test_connect_error_array

# ------------------------------------------

## test specified files exist

# no addtional files used by this pod

# ------------------------------------------

## STAGE [1]

if [[ ${MODE} == "test" ]]; then

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster connections"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}single stage${white} ]${reset}"
lib_generic_display_msgColourSimple "TASK"       "TASK: Testing server connectivity"
task_generic_testConnectivity
task_generic_testConnectivity_report

elif [[ ${MODE} == "copy" ]]; then

  echo copy

else
  printf "%s\n"
  lib_generic_display_msgColourSimple "error" "Not a recognised value for SSH-AUTH mode ${yellow}${MODE_SSH-AUTH}${red}"
  printf "%s\n"
  exit 1;
fi

# ------------------------------------------

## FINNISH

# no need for a finish on this single stage pod !

}
