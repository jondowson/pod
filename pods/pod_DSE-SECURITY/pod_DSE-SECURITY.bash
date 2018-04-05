# about:    call in order the stages for this pod

# ------------------------------------------

function pod_DSE-SECURITY(){

## globally declare arrays utilised by this pod's own stages

declare -A build_send_error_array     # stage_buildSend.bash
declare -A copy_keys_error_array      # test send pod build

## declare any variables used below

buildPathsToCheck="TEMP_FOLDER;PARENT_DATA_FOLDER;PARENT_LOG_FOLDER;spark_local_data;spark_worker_data;"
jsonPathsToCheck="cass_data;dsefs_data"

# ------------------------------------------

## STAGES

## note:
#     generic stages are composed in:   pod_/stages/stage_generic_stubs.bash
# non-generic stages are composed in:   pod_DSE/stages/stage_stubs.bash

# run pod_DSE-SECURITY stages

stage_stubs_createResourcesFolder     "1" "7"
stage_generic_stubs_testConnectivity  "2" "7"
stage_generic_stubs_testWritePaths    "3" "7"  "${buildPathsToCheck}" "${jsonPathsToCheck}"
stage_generic_stubs_sendPodSoftware   "4" "7"
if [[ "${PACKAGE}" != "" ]]; then
  stage_stubs_buildSendPod            "5" "7"
fi
stage_generic_stubs_launchPod         "6" "7"
stage_stubs_finish                    "7" "7"
}




# about:         configure dse software audit + security settings


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


## STAGE [4]

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Distribute encryption keys"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4${white} 5 ]${reset}"
prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Copy keys to all servers"
task_copyKeys
task_copyKeys_report
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ------------------------------------------

## [5] Summary

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGE"      "Summary"
prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 5${white} ]${reset}"
task_generic_testConnectivity_report
task_buildSend_report
task_generic_launchPodRemotely_report
task_copyKeys_report
}
