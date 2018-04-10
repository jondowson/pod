# about:         function calls for pod specific (non-generic) stages

# ------------------------------------------

function stage_stubs_createResourcesFolder(){

stageNumber="${1}"
stageTotal="${2}"

destination_folder_parent_path="${pod_home_path}/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
destination_folder_path="${destination_folder_parent_path}resources/"

prepare_generic_display_stageCount        "Prepare 'resources' Folder" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "TASK==>"  "TASK: Strip out all non config files"

if [[ "${REGENERATE_RESOURCES}" == "true" ]] || [[ "${REGENERATE_RESOURCES}" == "edit" ]] || [[ ! -d ${destination_folder_path} ]]; then
  task_makeResourcesFolder
  if [[ "${REGENERATE_RESOURCES}" == "edit" ]]; then
    prepare_generic_display_msgColourSimple "STAGE" "You can now edit each dse config in the folder ${yellow}${destination_folder_path}${reset}"
    printf "%s\n"
    exit 0;
  fi
else
  prepare_generic_display_msgColourSimple "ALERT" "You have opted to skip this STAGE"
fi
prepare_generic_display_stageTimeCount
}

# ------------------------------------------

function stage_stubs_stopStartCluster(){

stageNumber="${1}"
stageTotal="${2}"

if [[ "${CLUSTER_STATE}" == "restart" ]]; then
  prepare_generic_display_stageCount        "Restarting DSE Cluster" "${stageNumber}" "${stageTotal}"
  prepare_generic_display_msgColourSimple   "TASK==>"  "TASK: Restarting each server in cluster"
  task_rollingStop
  task_rollingStart
  task_rollingStart_report
else
  prepare_generic_display_stageCount        "Stopping DSE Cluster" "${stageNumber}" "${stageTotal}"
  prepare_generic_display_msgColourSimple   "TASK==>"  "TASK: Stopping each server in cluster"
  task_rollingStop
  task_rollingStop_report
fi
}

# ------------------------------------------

function stage_stubs_buildSendPod(){

stageNumber="${1}"
stageTotal="${2}"

prepare_generic_display_stageCount        "Build and send bespoke pod" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Configure pod locally and distribute"
task_buildSend
task_generic_buildSend_report
prepare_generic_display_stageTimeCount
}

# ------------------------------------------

function stage_stubs_finish(){

stageNumber="${1}"
stageTotal="${2}"

prepare_generic_display_stageCount        "Summary" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "REPORT" "STAGE REPORT:${reset}"
if [[ "${clusterstateFlag}" == "true" ]]; then
  task_generic_testConnectivity_report
  if [[ "${CLUSTER_STATE}" == "restart" ]]; then
    task_rollingStart_report
  else
    task_rollingStop_report
  fi
  # change WHICH_POD to alter final message
  WHICH_POD=${WHICH_POD}-rollingStart
else
  if [[ "${REGENERATE_RESOURCES}" == "true" ]] || [[ "${REGENERATE_RESOURCES}" == "edit" ]]; then
    prepare_generic_display_msgColourSimple "SUCCESS" "LOCAL SERVER: new resources folder generated"
  else
    prepare_generic_display_msgColourSimple "SUCCESS" "LOCAL SERVER: old resources folder utilised"
  fi
  task_generic_testConnectivity_report
  task_generic_testWritePaths_report
  if [[ "${SEND_POD_SOFTWARE}" == true ]]; then task_generic_sendPodSoftware_report; fi
  task_buildSend_report
  task_generic_launchPodRemotely_report
fi
}
