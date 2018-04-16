# about:    call in order the stages for this pod

# ------------------------------------------

function pod_REMOVE-PODS(){

## create pod specific arrays used by its stages

declare -A build_send_error_array     # stage_buildSend.bash

## declare all paths (; seperated) to be write tested
## no need to specify target_folder as automatically added !!
## supply the variable string and omit the '$' - e.g "this_path;that_path"
buildPathsToCheck=""
jsonPathsToCheck=""

# ------------------------------------------

## STAGES

## note:
#     generic stages are composed in:   pod_/stages/stage_generic_stubs.bash
# non-generic stages are composed in:   pod_DSE/stages/stage_stubs.bash

stage_generic_stubs_testConnectivity  "1" "6"
stage_generic_stubs_testWritePaths    "2" "6" "${buildPathsToCheck}" "${jsonPathsToCheck}"
stage_stubs_buildSendPod              "3" "6"
stage_generic_stubs_launchPod         "4" "6"
stage_stubs_finish                    "5" "6"
}
