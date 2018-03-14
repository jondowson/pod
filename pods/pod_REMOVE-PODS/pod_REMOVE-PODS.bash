# about:    remove a named pod from POD_INSTALLS and any entries from bash_profile

# ------------------------------------------

## pod desription: pod_REMOVE-PODS

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# pod_REMOVE-PODS makes use of 2 user defined files and has 6 STAGES.

# --> ${SERVERS_JSON}
# --> ${BUILD_FOLDER}build_settings.sh (dummy for this pod - all pods require this be specified)

# STAGE [1] - test cluster connections
# --> test defined paths can be written to.

# STAGE [2] - test cluster write paths
# --> test that ssh can connect and create a dummy folder to each specified write path.

# STAGE [3] - build and send pod build
# --> duplicate 'pod 'project to a temporary folder and configure for each server.
# --> copy the duplicated and configured version - the pod 'build' - to each server.

# STAGE [4] - execute pod remotely
# --> remotely run 'launch-pod.sh' on each server.

# STAGE [5] - pod summary
# --> report for each stage.

# ------------------------------------------

function pod_REMOVE-PODS(){

## create pod specific arrays used by its stages

declare -A build_send_error_array     # test send pod build

# ------------------------------------------

## STAGES

## STAGE [1]

prepare_generic_display_stageCount        "Test server connectivity" "1" "5"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Testing server connectivity"
task_generic_testConnectivity
task_generic_testConnectivity_report
prepare_generic_display_stageTimeCount

# ------------------------------------------

## STAGE [2]

prepare_generic_display_stageCount        "Test cluster write-paths" "2" "5"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Testing server write-paths"
# semi-colon delimeter any elements containing paths to be write tested: "from build_settings.bash" "from server json"
# note: paths specified here from json need to be put in nested [] brackets - even if only one path exists + no need to specify target_folder
# if nothing is specified - the write test will check only the target_folder specified in the json
task_generic_testWritePaths "" ""
task_generic_testWritePaths_report
prepare_generic_display_stageTimeCount

# ------------------------------------------

## STAGE [3]

prepare_generic_display_stageCount        "Build and send bespoke pod" "3" "5"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Configure locally and distribute"
task_buildSend
task_buildSend_report
prepare_generic_display_stageTimeCount

# ------------------------------------------

## STAGE [4]

prepare_generic_display_stageCount        "Launch pod remotely" "4" "5"
prepare_generic_display_msgColourSimple   "TASK==>"    "TASK: Execute launch script on each server"
task_generic_launchPodRemotely
task_generic_launchPodRemotely_report
prepare_generic_display_stageTimeCount

# ------------------------------------------

## STAGE [5] FINISH

prepare_generic_display_stageCount        "Summary" "5" "5"
prepare_generic_display_msgColourSimple   "REPORT" "STAGE REPORT:${reset}"
task_generic_testConnectivity_report
task_generic_testWritePaths_report
task_buildSend_report
task_generic_launchPodRemotely_report
}
