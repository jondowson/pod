# about:         function calls for pod specific (non-generic) stages

# ------------------------------------------

function stage_stubs_buildSendPod(){

stageNumber="${1}"
stageTotal="${2}"

prepare_generic_display_stageCount        "Build and send bespoke pod" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Configure pod locally and distribute"
task_buildSend
task_buildSend_report
prepare_generic_display_stageTimeCount
}

# ------------------------------------------

function stage_stubs_stopStartCluster(){

stageNumber="${1}"
stageTotal="${2}"

if [[ "${CLUSTER_STATE}" == "restart" ]]; then
  prepare_generic_display_stageCount        "Restarting opscenter" "${stageNumber}" "${stageTotal}"
  prepare_generic_display_msgColourSimple   "TASK==>"  "TASK: Restarting daemon on each server"
  task_rollingStop
  task_rollingStart
  task_rollingStart_report
else
  prepare_generic_display_stageCount        "Stopping opscenter" "${stageNumber}" "${stageTotal}"
  prepare_generic_display_msgColourSimple   "TASK==>"  "TASK: Stopping daemon on each server"
  task_rollingStop
  task_rollingStop_report
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
  else
    task_rollingStop_report
  fi
  # change WHICH_POD to alter final message
  WHICH_POD=${WHICH_POD}-rollingStart
else
  task_generic_testWritePaths_report
  if [[ "${SEND_POD_SOFTWARE}" == true ]]; then task_generic_sendPodSoftware_report; fi
  task_buildSend_report
  task_generic_launchPodRemotely_report
fi
}
