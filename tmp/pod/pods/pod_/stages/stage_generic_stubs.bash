# about:         functions for each stage

# ------------------------------------------

function stage_generic_stubs_testConnectivity(){

stageNumber="${1}"
stageTotal="${2}"

prepare_generic_display_stageCount        "Test server connectivity" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Testing server connectivity"
task_generic_testConnectivity
task_generic_testConnectivity_report
prepare_generic_display_stageTimeCount
}

# ------------------------------------------

function stage_generic_stubs_testWritePaths(){

stageNumber="${1}"
stageTotal="${2}"
# semi-colon delimeter any elements containing paths to be write tested:
buildFolderPaths="${3}"  # from build_settings.bash
jsonPaths="${4}"         # from server json
# note:
# in the json file, for paths to be specified here, they must be put in nested [] brackets.
# this format supports multiple paths but is required here even if only one path exists.
prepare_generic_display_stageCount        "Test cluster write-paths" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Testing server write-paths"
task_generic_testWritePaths "${buildFolderPaths}" "${jsonPaths}"
task_generic_testWritePaths_report
prepare_generic_display_stageTimeCount
}

# ------------------------------------------

function stage_generic_stubs_sendPodSoftware(){

stageNumber="${1}"
stageTotal="${2}"

prepare_generic_display_stageCount        "Send POD_SOFTWARE folder" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Send software in parallel"

if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
  task_generic_sendPodSoftware
  task_generic_sendPodSoftware_report
else
  prepare_generic_display_msgColourSimple "ALERT-->" "You have opted to skip this STAGE"
  printf "%s\n"
fi
prepare_generic_display_stageTimeCount
}

# ------------------------------------------

function stage_generic_stubs_launchPod(){

stageNumber="${1}"
stageTotal="${2}"

prepare_generic_display_stageCount        "Launch pod remotely" "${stageNumber}" "${stageTotal}"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Execute launch script on each server"
task_generic_launchPodRemotely
task_generic_launchPodRemotely_report
prepare_generic_display_stageTimeCount
}

# ------------------------------------------

function stage_generic_stubs_finish(){

stageNumber="${1}"
stageTotal="${2}"

prepare_generic_display_stageCount        "Summary" "${stageNumber}" "${stageTotal}"
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
}
