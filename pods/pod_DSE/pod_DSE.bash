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
# --> copy over the 'POD_SOFTWARE' folder to each server.

# STAGE [5] - execute pod remotely
# --> remotely run 'launch-pod.sh' on each server.

# ------------------------------------------

function pod_DSE(){

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
declare -A pod_start_dse_error_array
declare -A pod_stop_dse_error_array

# ------------------------------------------

## test specified files exist

prepare_misc_checkFilesExist

# ------------------------------------------

## STAGES

if [[ "${clusterstateFlag}" == "true" ]]; then

  ## STAGE [1]

  lib_generic_display_banner
  lib_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster connections"
  lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1${white} 2 ]${reset}"
  lib_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server connectivity"
  task_generic_testConnectivity
  task_generic_testConnectivity_report
  lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## STAGE [2]

  if [[ "${CLUSTER_STATE}" == "start" ]]; then
    lib_generic_display_banner
    lib_generic_display_msgColourSimple "STAGE" "STAGE: Starting DSE Cluster"
    lib_generic_display_msgColourSimple "STAGECOUNT" "[ 1 ${cyan}${b}2${white} ]${reset}"
    lib_generic_display_msgColourSimple "TASK==>"  "TASK: Starting each server in cluster"
    task_rollingStart
    task_rollingStart_report
  else
    lib_generic_display_banner
    lib_generic_display_msgColourSimple "STAGE" "STAGE: Stopping DSE Cluster"
    lib_generic_display_msgColourSimple "STAGECOUNT" "[ 1 ${cyan}${b}2${white} ]${reset}"
    lib_generic_display_msgColourSimple "TASK==>"  "TASK: Stopping each server in cluster"
    task_rollingStop
    task_rollingStop_report
  fi

  # change WHICH_POD to alter final messages
  WHICH_POD=${WHICH_POD}_rollingStartStop

else

  # ------------------------------------------

  ## STAGE [1] - optional

  # prepare local copy of dse 'resources' folder - the basis for each distributed pod build
  destination_folder_parent_path="${pod_home_path}/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
  destination_folder_path="${destination_folder_parent_path}resources/"
  lib_generic_display_banner
  lib_generic_display_msgColourSimple "STAGE" "STAGE: Prepare 'resources' Folder"
  lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1${white} 2 3 4 5 6 ]${reset}"
  lib_generic_display_msgColourSimple "TASK==>"  "TASK: Strip out all non config files"

  if [[ "${REGENERATE_RESOURCES}" == "true" ]] || [[ "${REGENERATE_RESOURCES}" == "edit" ]] || [[ ! -d ${destination_folder_path} ]]; then
    task_makeResourcesFolder
    if [[ "${REGENERATE_RESOURCES}" == "edit" ]]; then
      lib_generic_display_msgColourSimple "STAGE" "You can now edit each dse config in the folder ${yellow}${destination_folder_path}${reset}"
      printf "%s\n"
      exit 0;
    fi
  else
    lib_generic_display_msgColourSimple "ALERT-->" "You have opted to skip this STAGE"
    printf "%s\n"
  fi
  lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  # create configurable temp version of pod
  catchError "pod_DSE.sh#1" "true" prepare_generic_misc_podBuildTempFolder

  # ------------------------------------------

  ## STAGE [2]

  lib_generic_display_banner
  lib_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster connections"
  lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2${white} 3 4 5 6 ]${reset}"
  lib_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server connectivity"
  task_generic_testConnectivity
  task_generic_testConnectivity_report
  lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## STAGE [3]

  lib_generic_display_banner
  lib_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster write-paths"
  lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3${white} 4 5 6 ]${reset}"
  lib_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server write-paths"
  task_testWritePaths
  task_testWritePaths_report
  lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## STAGE [4]

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

  ## STAGE [5]

  lib_generic_display_banner
  lib_generic_display_msgColourSimple "STAGE"      "STAGE: Build and send pod"
  lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 5${white} 6 ]${reset}"
  lib_generic_display_msgColourSimple "TASK==>"    "TASK: Configure and send bespoke pod"
  task_buildSend
  task_buildSend_report
  lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

  # ------------------------------------------

  ## STAGE [6]

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
fi
}
