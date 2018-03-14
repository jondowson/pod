# about:         configure dse software and distribute to all servers in cluster

# ------------------------------------------

## pod desription: pod_DSE

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# pod_DSE makes use of 2 user defined files and has 7 STAGES.

# --> ${SERVERS_JSON}
# --> ${BUILD_FOLDER}build_settings.sh
# and a DSE version specific prepared 'resources' folder.
# --> ${BUILD_FOLDER}resources

# STAGE [1] - optionally prepare local 'resources' folder
# --> will strip all non-config files from the 'resources' folder in the dse-<version> tarball.
# --> copy to ${BUILD_FOLDER}resources.
# --> OPTIONAL if one already exists.

# STAGE [2] - test cluster connections
# --> test defined paths can be written to.

# STAGE [3] - test cluster write paths
# --> test that ssh can connect and create a dummy folder to each specified write path.

# STAGE [4] - build and send software tarballs
# --> copy over the 'POD_SOFTWARE' folder to each server.

# STAGE [5] - build and send pod build
# --> duplicate 'pod 'project to a temporary folder and configure for each server.
# --> copy the duplicated and configured version - the pod 'build' - to each server.

# STAGE [6] - execute pod remotely
# --> remotely run 'launch-pod.sh' on each server.

# STAGE [7] - pod summary
# --> report for each stage.

# ------------------------------------------

function pod_DSE(){

## globally declare arrays utilised by this pod

# (1) array to write_test that holds the 'parent' folders specified in the BUILD_FOLDER
#
# (2) generic arrays to hold results of actions performed by pod_ functions
declare -A test_write_error_array_1   # stage_generic_testWritePaths      - test writeTest_array paths (specified above)
declare -A test_write_error_array_2   # stage_generic_testWritePaths      - test paths specified in json
declare -A build_launch_pid_array     # stage_generic_launch_podRemotely  - did script launch successfully on remote server

## (3) specific arrays utilised by this pod
declare -A build_send_error_array     # stage_buildSend
declare -A start_dse_error_array      # stage_rollingStart
declare -A stop_dse_error_array       # stage_rollingStop

# ------------------------------------------

## STAGES

# if using pod_DSE rolling start or stop feature - 3 stages are used.
if [[ "${clusterstateFlag}" == "true" ]]; then

  ## STAGE [1]

  prepare_generic_display_stageCount      "Test server connectivity" "1" "3"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server connectivity"
  task_generic_testConnectivity
  task_generic_testConnectivity_report
  prepare_generic_display_stageTimeCount

  # ------------------------------------------

  ## STAGE [2]

  if [[ "${CLUSTER_STATE}" == "restart" ]]; then
    prepare_generic_display_stageCount      "Restarting DSE Cluster" "2" "3"
    prepare_generic_display_msgColourSimple "TASK==>"  "TASK: Restarting each server in cluster"
    task_rollingStop
    task_rollingStart
    task_rollingStart_report
  else
    prepare_generic_display_stageCount      "Stopping DSE Cluster" "2" "3"
    prepare_generic_display_msgColourSimple "TASK==>"  "TASK: Stopping each server in cluster"
    task_rollingStop
    task_rollingStop_report
  fi

  # ------------------------------------------

  ## STAGE [3]

  prepare_generic_display_stageCount      "Summary" "3" "3"
  task_generic_testConnectivity_report
  if [[ "${CLUSTER_STATE}" == "restart" ]]; then
    task_rollingStart_report
  else
    task_rollingStop_report
  fi
  # change WHICH_POD to alter final message displayed by pod_ generic function
  WHICH_POD=${WHICH_POD}_rollingStartStop

  # ------------------------------------------



else # installing pod_DSE

  ## STAGE [1] - optional

  # prepare local copy of dse 'resources' folder - the basis for each distributed pod build
  destination_folder_parent_path="${pod_home_path}/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
  destination_folder_path="${destination_folder_parent_path}resources/"

  prepare_generic_display_stageCount      "Prepare 'resources' Folder" "1" "7"
  prepare_generic_display_msgColourSimple "TASK==>"  "TASK: Strip out all non config files"

  if [[ "${REGENERATE_RESOURCES}" == "true" ]] || [[ "${REGENERATE_RESOURCES}" == "edit" ]] || [[ ! -d ${destination_folder_path} ]]; then
    task_makeResourcesFolder
    rr_flag="true"
    if [[ "${REGENERATE_RESOURCES}" == "edit" ]]; then
      prepare_generic_display_msgColourSimple "STAGE" "You can now edit each dse config in the folder ${yellow}${destination_folder_path}${reset}"
      printf "%s\n"
      exit 0;
    fi
  else
    prepare_generic_display_msgColourSimple "ALERT" "You have opted to skip this STAGE"
    printf "%s\n"
  fi
  prepare_generic_display_stageTimeCount

  # ------------------------------------------

  ## STAGE [2]

  prepare_generic_display_stageCount      "Test cluster connections" "2" "7"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server connectivity"
  task_generic_testConnectivity
  task_generic_testConnectivity_report
  prepare_generic_display_stageTimeCount

  # ------------------------------------------

  ## STAGE [3]

  prepare_generic_display_stageCount      "Test cluster write-paths" "3" "7"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server write-paths"
  # semi-colon delimeter any elements containing paths to be write tested: "from build_settings.bash" "from server json"
  task_generic_testWritePaths "TEMP_FOLDER;PARENT_DATA_FOLDER;PARENT_LOG_FOLDER" "cass_data;dsefs_data"
  task_generic_testWritePaths_report
  prepare_generic_display_stageTimeCount

  # ------------------------------------------

  ## STAGE [4]

  prepare_generic_display_stageCount      "Send POD_SOFTWARE folder" "4" "7"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Send software in parallel"

  if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
    task_generic_sendPodSoftware
    task_generic_sendPodSoftware_report
  else
    prepare_generic_display_msgColourSimple "ALERT-->" "You have opted to skip this STAGE"
    printf "%s\n"
  fi
  prepare_generic_display_stageTimeCount

  # ------------------------------------------

  ## STAGE [5]

  prepare_generic_display_stageCount      "Build and send bespoke pod" "5" "7"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Configure locally and distribute"
  task_buildSend
  task_buildSend_report
  prepare_generic_display_stageTimeCount

  # ------------------------------------------

  ## STAGE [6]

  prepare_generic_display_stageCount      "Launch pod remotely" "6" "7"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Execute launch script on each server"
  task_generic_launchPodRemotely
  task_generic_launchPodRemotely_report
  prepare_generic_display_stageTimeCount

  # ------------------------------------------

  ## STAGE [7]

  prepare_generic_display_stageCount        "Summary" "7" "7"
  prepare_generic_display_msgColourSimple   "REPORT" "STAGE REPORT:${reset}"
  if [[ "${rr_flag}" == true ]]; then
    prepare_generic_display_msgColourSimple "SUCCESS" "LOCAL SERVER: resources folder generated"
  else
    prepare_generic_display_msgColourSimple "SUCCESS" "LOCAL SERVER: resources folder untouched"
  fi
  task_generic_testConnectivity_report
  task_generic_testWritePaths_report
  if [[ "${SEND_POD_SOFTWARE}" == true ]]; then task_generic_sendPodSoftware_report; fi
  task_buildSend_report
  task_generic_launchPodRemotely_report
fi
}
