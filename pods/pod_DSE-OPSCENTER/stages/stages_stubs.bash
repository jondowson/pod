function stages_stubs_buildSendPod(){

stageNumber="${1}"
stageTotal="${2}"

GENERIC_prepare_display_stageCount        "Build and send bespoke pod" "${stageNumber}" "${stageTotal}"
GENERIC_prepare_display_msgColourSimple   "TASK==>"    "TASK: Configuring pod locally and distributing"
# this will call the pod specific version of this task, which in turn calls the generic one (task_generic_buildSend)
task_buildSend
GENERIC_prepare_display_stageTimeCount
}

# ------------------------------------------

function stages_stubs_stopStartCluster(){

stageNumber="${1}"
stageTotal="${2}"

if [[ "${CLUSTER_STATE}" == "restart" ]]; then
  GENERIC_prepare_display_stageCount        "Opscenter Restart" "${stageNumber}" "${stageTotal}"
  GENERIC_prepare_display_msgColourSimple   "TASK==>"  "TASK: Stopping opscenter daemon"
  task_rollingStop
  GENERIC_prepare_display_msgColourSimple   "TASK==>"  "TASK: Starting opscenter daemon"
  task_rollingStart
  GENERIC_prepare_display_stageTimeCount
else
  GENERIC_prepare_display_stageCount        "Opscenter Stop" "${stageNumber}" "${stageTotal}"
  GENERIC_prepare_display_msgColourSimple   "TASK==>"  "TASK: Stopping opscenter daemon"
  task_rollingStop
  GENERIC_prepare_display_stageTimeCount
fi
}

# ------------------------------------------

function stages_stubs_finish(){

stageNumber="${1}"
stageTotal="${2}"

GENERIC_prepare_display_stageCount          "Summary" "${stageNumber}" "${stageTotal}"
GENERIC_prepare_display_msgColourSimple     "REPORT" "STAGE REPORT:${reset}"
GENERIC_task_testConnectivity_report
if [[ "${clusterstateFlag}" == "true" ]]; then
  if [[ "${CLUSTER_STATE}" == "restart" ]]; then
    task_rollingStart_report
    # change WHICH_POD to alter final message
    WHICH_POD=${WHICH_POD}-rollingStart
  else
    task_rollingStop_report
    # change WHICH_POD to alter final message
    WHICH_POD=${WHICH_POD}-rollingStop
  fi
else
  GENERIC_task_testWritePaths_report
  if [[ "${SEND_POD_SOFTWARE}" == true ]]; then GENERIC_task_sendPodSoftware_report; fi
  GENERIC_task_buildSend_report
  GENERIC_task_launchPodRemotely_report
fi
}
