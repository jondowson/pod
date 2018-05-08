function stages_stubs_buildSendPod(){

stageNumber="${1}"
stageTotal="${2}"

GENERIC_prepare_display_stageCount        "Build and send bespoke pod" "${stageNumber}" "${stageTotal}"
GENERIC_prepare_display_msgColourSimple   "TASK==>"    "TASK: Configuring pod locally and distributing"
task_buildSend
GENERIC_prepare_display_stageTimeCount
}

# ------------------------------------------

function stages_stubs_finish(){

stageNumber="${1}"
stageTotal="${2}"

GENERIC_prepare_display_stageCount        "Summary" "${stageNumber}" "${stageTotal}"
GENERIC_prepare_display_msgColourSimple   "REPORT" "STAGE REPORT:${reset}"
GENERIC_task_testConnectivity_report
GENERIC_task_testWritePaths_report
GENERIC_task_buildSend_report
GENERIC_task_launchPodRemotely_report
}
