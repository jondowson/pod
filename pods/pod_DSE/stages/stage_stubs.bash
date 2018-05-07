function stage_stubs_createResourcesFolder(){

stageNumber="${1}"
stageTotal="${2}"

destBuildFolderPath="${podHomePath}/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
destResourcesFolderPath="${destBuildFolderPath}resources/"
newResourcesFolder="false" # becomes true if stage is run

GENERIC_prepare_display_stageCount        "Prepare 'resources' Folder" "${stageNumber}" "${stageTotal}"
GENERIC_prepare_display_msgColourSimple   "TASK==>"  "TASK: Strip out all non config files"

if [[ "${REGENERATE_RESOURCES}" == "true" ]] || [[ "${REGENERATE_RESOURCES}" == "edit" ]] || [[ ! -d ${destResourcesFolderPath} ]]; then
  task_makeResourcesFolder
  if [[ "${REGENERATE_RESOURCES}" == "edit" ]]; then
    GENERIC_prepare_display_msgColourSimple "STAGE" "You can now edit each dse config in the folder ${yellow}${destResourcesFolderPath}${reset}"
    printf "%s\n"
    exit 0;
  fi
else
  GENERIC_prepare_display_msgColourSimple "ALERT" "You have opted to skip this STAGE"
fi
GENERIC_prepare_display_stageTimeCount
}

# ------------------------------------------

function stage_stubs_stopStartCluster(){

stageNumber="${1}"
stageTotal="${2}"

if [[ "${CLUSTER_STATE}" == "restart" ]]; then
  GENERIC_prepare_display_stageCount        "DSE Cluster Restart" "${stageNumber}" "${stageTotal}"
  GENERIC_prepare_display_msgColourSimple   "TASK==>"  "TASK: Stopping dse + agent"
  task_rollingStop
  GENERIC_prepare_display_msgColourSimple   "TASK==>"  "TASK: Starting dse + agent"
  task_rollingStart
  GENERIC_prepare_display_stageTimeCount
elif [[ "${CLUSTER_STATE}" == "agent-restart" ]]; then
  GENERIC_prepare_display_stageCount        "DSE Cluster Restart" "${stageNumber}" "${stageTotal}"
  GENERIC_prepare_display_msgColourSimple   "TASK==>"  "TASK: Stopping agent"
  task_rollingStop
  GENERIC_prepare_display_msgColourSimple   "TASK==>"  "TASK: Starting agent"
  task_rollingStart
  GENERIC_prepare_display_stageTimeCount
elif [[ "${CLUSTER_STATE}" == "agent-stop" ]]; then
  GENERIC_prepare_display_stageCount        "DSE Cluster Stop" "${stageNumber}" "${stageTotal}"
  GENERIC_prepare_display_msgColourSimple   "TASK==>"  "TASK: Stopping agent"
  task_rollingStop
  GENERIC_prepare_display_stageTimeCount
else
  GENERIC_prepare_display_stageCount        "DSE Cluster Stop" "${stageNumber}" "${stageTotal}"
  GENERIC_prepare_display_msgColourSimple   "TASK==>"  "TASK: Stopping dse + agent"
  task_rollingStop
  GENERIC_prepare_display_stageTimeCount
fi
}

# ------------------------------------------

function stage_stubs_buildSendPod(){

stageNumber="${1}"
stageTotal="${2}"

GENERIC_prepare_display_stageCount        "Build and send bespoke pod" "${stageNumber}" "${stageTotal}"
GENERIC_prepare_display_msgColourSimple   "TASK==>"    "TASK: Configuring pod locally and distributing"
# this will call the pod specific version of this task - that in a loop finishes by calling the generic version of this function (task_buildSend_GENERIC)
task_buildSend
GENERIC_prepare_display_stageTimeCount
}

# ------------------------------------------

function stage_stubs_finish(){

stageNumber="${1}"
stageTotal="${2}"

GENERIC_prepare_display_stageCount        "Summary" "${stageNumber}" "${stageTotal}"
GENERIC_prepare_display_msgColourSimple   "REPORT" "STAGE REPORT:${reset}"
if [[ "${clusterstateFlag}" == "true" ]]; then
  task_generic_testConnectivity_report
  if [[ "${CLUSTER_STATE}" == *"restart"* ]]; then
    task_rollingStart_report
  else
    task_rollingStop_report
  fi
  # change WHICH_POD to alter final message
  WHICH_POD=${WHICH_POD}-rollingStopStart
else
  if [[ "${REGENERATE_RESOURCES}" == "true" ]] || [[ "${REGENERATE_RESOURCES}" == "edit" ]] || [[ "${flagOne}" == "true" ]]; then
    GENERIC_prepare_display_msgColourSimple "SUCCESS" "This server:  new resources folder generated"
  else
    GENERIC_prepare_display_msgColourSimple "SUCCESS" "This server:  existing resources folder utilised"
  fi
  GENERIC_task_testConnectivity_report
  GENERIC_task_testWritePaths_report
  if [[ "${SEND_POD_SOFTWARE}" == true ]]; then GENERIC_task_sendPodSoftware_report; fi
  GENERIC_task_buildSend_report
  GENERIC_task_launchPodRemotely_report
fi
}
