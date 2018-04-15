# about:    call in order the stages for this pod

# ------------------------------------------

function pod_JAVA(){

## globally declare arrays utilised by this pod
## this will make their contents available to functions outside of the function that populates it
declare -A build_send_error_array     # populated in stage_buildSend.bash

## declare all paths (; seperated) to be write tested
## no need to specify target_folder as automatically added !!
## supply the variable string and omit the '$' - e.g "this_path;that_path"
buildPathsToCheck="TEMP_FOLDER"
jsonPathsToCheck=""

# ------------------------------------------

## STAGES

## note:
##     generic stages are composed in:   pod_/stages/stage_generic_stubs.bash
## non-generic stages are composed in:   pod_DSE/stages/stage_stubs.bash

stage_generic_stubs_testConnectivity  "1" "6"
stage_generic_stubs_testWritePaths    "2" "6" "${buildPathsToCheck}" "${jsonPathsToCheck}"
stage_generic_stubs_sendPodSoftware   "3" "6"
stage_stubs_buildSendPod              "4" "6"
stage_generic_stubs_launchPod         "5" "6"
stage_stubs_finish                    "6" "6"
}
