function stage_stubs_buildSendPod(){

stageNumber="${1}"
stageTotal="${2}"

prepare_generic_display_stageCount        "Build and send bespoke pod" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Configuring pod locally and distributing"
# this will call the pod specific version of this task, which in turn calls the generic one (task_generic_buildSend)
task_buildSend
prepare_generic_display_stageTimeCount
}

# ------------------------------------------

function stage_stubs_stopStartCluster(){

stageNumber="${1}"
stageTotal="${2}"

if [[ "${CLUSTER_STATE}" == "restart" ]]; then
  prepare_generic_display_stageCount        "Opscenter Restart" "${stageNumber}" "${stageTotal}"
  prepare_generic_display_msgColourSimple   "TASK==>"  "TASK: Stopping opscenter daemon"
  task_rollingStop
  prepare_generic_display_msgColourSimple   "TASK==>"  "TASK: Starting opscenter daemon"
  task_rollingStart
  prepare_generic_display_stageTimeCount
else
  prepare_generic_display_stageCount        "Opscenter Stop" "${stageNumber}" "${stageTotal}"
  prepare_generic_display_msgColourSimple   "TASK==>"  "TASK: Stopping opscenter daemon"
  task_rollingStop
  prepare_generic_display_stageTimeCount
fi
}

# ------------------------------------------

function stage_stubs_finish(){

stageNumber="${1}"
stageTotal="${2}"

prepare_generic_display_stageCount        "Summary" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "REPORT" "STAGE REPORT:${reset}"
task_generic_testConnectivity_report
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
  task_generic_testWritePaths_report
  if [[ "${SEND_POD_SOFTWARE}" == true ]]; then task_generic_sendPodSoftware_report; fi
  task_generic_buildSend_report
  task_generic_launchPodRemotely_report
fi
}
