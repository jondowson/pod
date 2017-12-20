# author:        jondowson
# about:         configure dse software and distribute to all servers in cluster

# ------------------------------------------

## pod desription: pod_

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

function pod_(){

## create arrays for capturing errors

declare -A ifsDelimArray
declare -A pod_test_connect_error_array
declare -A pod_test_send_error_array_1
declare -A pod_build_send_error_array
declare -A pod_software_send_pid_array
declare -A pod_build_run_pid_array
declare -A pod_build_launch_pid_array
declare -A pod_remove_pod_report_array
declare -A pod_remove_pod_error_array

# ------------------------------------------

## test specified files exist

#prepare_misc_checkFilesExist

# ------------------------------------------

# create configurable temp version of pod
#catchError "pod_generic.sh#1" "true" prepare_generic_misc_podBuildTempFolder

# ------------------------------------------

## STAGES

if [[ "${removepodFlag}" == "true" ]]; then

  ## STAGE [1]

  lib_generic_display_banner
  lib_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster connections"
  lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 ${white}2 3 ]${reset}"
  lib_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server connectivity"
  task_generic_testConnectivity
  task_generic_testConnectivity_report
  lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## STAGE [2]

  lib_generic_display_banner
  lib_generic_display_msgColourSimple "STAGE"      "STAGE: Remove ${WHICH_POD} from POD_INSTALLS"
  lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 ${white}3 ]${reset}"
  lib_generic_display_msgColourSimple "TASK==>"    "TASK: Remove ${WHICH_POD}"
  task_removePod
  task_removePod_report
  lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## STAGE [3] FINISH

  lib_generic_display_banner
  lib_generic_display_msgColourSimple "STAGE"      "FINISHED !!"
  lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 ${white} ]${reset}"
  printf "%s\n" 
  lib_generic_display_msgColourSimple "SUCCESS" "${REMOVE_POD} was successfully removed from ${INSTALL_FOLDER} on all servers"
fi
}
