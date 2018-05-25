function GENERIC_stages_stubs_testConnectivity(){

stageNumber="${1}";
stageTotal="${2}";

GENERIC_prepare_display_stageCount         "Test Connectivity" "${stageNumber}" "${stageTotal}";
GENERIC_prepare_display_msgColourSimple    "TASK==>"    "Task: Testing ssh call";
GENERIC_task_testConnectivity;
GENERIC_prepare_display_stageTimeCount;
};

# ------------------------------------------

function GENERIC_stages_stubs_testWritePaths(){

stageNumber="${1}";
stageTotal="${2}";
# semi-colon delimeter any elements containing paths to be write tested:
buildFolderPaths="${3}";  # from build_settings.bash
jsonPaths="${4}";         # from server json

# note:
# in the json file, for paths to be specified here, they must be put in nested [] brackets.
# this format supports multiple paths but is required here even if only one path exists.
GENERIC_prepare_display_stageCount        "Test Write-Paths" "${stageNumber}" "${stageTotal}";
GENERIC_prepare_display_msgColourSimple   "TASK==>"  "Task: Making remote folders";
GENERIC_task_testWritePaths               "${buildFolderPaths}" "${jsonPaths}";
GENERIC_prepare_display_stageTimeCount;
};

# ------------------------------------------

function GENERIC_stages_stubs_sendPodSoftware(){

stageNumber="${1}";
stageTotal="${2}";

GENERIC_prepare_display_stageCount        "Send POD_SOFTWARE" "${stageNumber}" "${stageTotal}";
GENERIC_prepare_display_msgColourSimple   "TASK==>"    "Task: Sending software in parallel";

if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
  GENERIC_task_sendPodSoftware;
else
  GENERIC_prepare_display_msgColourSimple "ALERT-->" "You have opted to skip this STAGE";
  printf "%s\n";
fi;
GENERIC_prepare_display_stageTimeCount;
};

# ------------------------------------------

function GENERIC_stages_stubs_launchPodRemotely(){

stageNumber="${1}";
stageTotal="${2}";

GENERIC_prepare_display_stageCount        "Launch Pod Build" "${stageNumber}" "${stageTotal}";
GENERIC_prepare_display_msgColourSimple   "TASK==>"  "Task: Running launch script in parallel";
GENERIC_task_launchPodRemotely;
GENERIC_prepare_display_stageTimeCount;
};

# ------------------------------------------

function GENERIC_stages_stubs_finish(){

stageNumber="${1}";
stageTotal="${2}";

GENERIC_prepare_display_stageCount        "Summary" "${stageNumber}" "${stageTotal}";
GENERIC_prepare_display_msgColourSimple   "REPORT"  "STAGE REPORT:${reset}";
if [[ "${rr_flag}" == true ]]; then
  GENERIC_prepare_display_msgColourSimple "SUCCESS" "This server: new resources folder generated";
else
  GENERIC_prepare_display_msgColourSimple "SUCCESS" "This server: old resources folder utilised";
fi;
GENERIC_task_testConnectivity_report;
GENERIC_task_testWritePaths_report;
if [[ "${SEND_POD_SOFTWARE}" == true ]]; then GENERIC_task_sendPodSoftware_report; fi;
GENERIC_task_buildSend_report;
GENERIC_task_launchPodRemotely_report;
};
