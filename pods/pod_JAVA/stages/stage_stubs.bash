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

function stage_stubs_finish(){

stageNumber="${1}"
stageTotal="${2}"

prepare_generic_display_stageCount        "Summary" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "REPORT" "STAGE REPORT:${reset}"
task_generic_testConnectivity_report
task_generic_testWritePaths_report
if [[ "${SEND_POD_SOFTWARE}" == true ]]; then task_generic_sendPodSoftware_report; fi
task_buildSend_report
task_generic_launchPodRemotely_report
}