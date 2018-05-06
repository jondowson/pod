function stage_stubs_buildSendPod(){

stageNumber="${1}"
stageTotal="${2}"

GENERIC_prepare_display_stageCount        "Build and send bespoke pod" "${stageNumber}" "${stageTotal}"
GENERIC_prepare_display_msgColourSimple   "TASK==>"    "TASK: Configuring pod locally and distributing"
task_buildSend
GENERIC_prepare_display_stageTimeCount
}

# ------------------------------------------

function stage_stubs_finish(){

stageNumber="${1}"
stageTotal="${2}"

GENERIC_prepare_display_stageCount        "Summary" "${stageNumber}" "${stageTotal}"
GENERIC_prepare_display_msgColourSimple   "REPORT" "STAGE REPORT:${reset}"
task_generic_testConnectivity_report
task_generic_testWritePaths_report
task_generic_buildSend_report
task_generic_launchPodRemotely_report
}
