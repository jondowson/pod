# about:         configure dse software audit + security settings

# ------------------------------------------

## pod desription: pod_DSE-SECURITY

# note: a pod consists of STAGE(S), which consist of TASK(S), which contain actions.

# pod_DSE-SECURITY makes use of 2 user defined files and has 4 STAGES.

# --> ${SERVERS_JSON}
# --> ${BUILD_FOLDER}build_settings.sh
# and a DSE version specific prepared 'resources' folder (auto-generated).
# --> ${BUILD_FOLDER}resources

# STAGE [1] - test cluster connections
# --> test defined paths can be written to.

# STAGE [2] - build and send pod build
# --> duplicate 'pod 'project to a temporary folder and configure for each server.
# --> copy the duplicated and configured version - the pod 'build' - to each server.

# STAGE [3] - execute pod remotely
# --> remotely run 'launch-pod.sh' on each server.

# STAGE [4] - distribute encryption keys
# --> copy keys from machine running pod to each remote server.
# --> these keys are either backed up copies from the resources folder or freshly generated ones.

# STAGE [5] - summary

# ------------------------------------------

function pod_DSE-SECURITY(){

## create pod specific arrays used by its stages

declare -A build_send_error_array     # test send pod build
declare -A copy_keys_error_array      # test send pod build
declare -A build_launch_pid_array     # test launch pod scripts remotely

# ------------------------------------------

# first check if resources folder already exists locally and is not empty (i.e contains keys)
# if resources folder and keys already exist, distribute these and do not generate new ones on server 1
pod_home_path="$(lib_generic_strings_addTrailingSlash ${pod_home_path})"
resources_folder="${pod_home_path}pods/${WHICH_POD}/builds/${BUILD_FOLDER}/resources/"
mkdir -p ${resources_folder}
# check folder exists
if [[ -d ${resources_folder} ]]; then
  # check folder is not empty
  if [ "$(ls -A ${resources_folder})" ]; then
    generate_keys="false"
  else
    generate_keys="true"
  fi
else
  generate_keys="true"
fi

# ------------------------------------------

## STAGES

## STAGE [1]

lib_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Test cluster connections"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1${white} 2 3 4 5 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Testing server connectivity"
task_generic_testConnectivity
task_generic_testConnectivity_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [2]

lib_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Build and send bespoke pod"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2${white} 3 4 5 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Configure locally and distribute"
task_buildSend
task_buildSend_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [3]

lib_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Launch pod remotely"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3${white} 4 5 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Execute launch script on each server"
task_generic_launchPodRemotely
task_generic_launchPodRemotely_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## STAGE [4]

lib_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Distribute encryption keys"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4${white} 5 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Copy keys to all servers"
task_copyKeys
task_copyKeys_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## [5] Summary

lib_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "Summary"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 5${white} ]${reset}"
task_generic_testConnectivity_report
task_buildSend_report
task_generic_launchPodRemotely_report
task_copyKeys_report
}
