#!/bin/bash

# author:        jondowson
# about:         default settings for pod and each pod application

# ------------------------------------------

function lib_generic_defaults(){

## general pod settings

VB="false"           # verbose messages
STAGE_PAUSE="10"     # pauses between STAGES

case "${WHICH_POD}" in
  pod_DSE)
    SEND_POD_SOFTWARE="true"         # send POD_SOFTWARE tarball bundle on each run
    REGENERATE_RESOURCES="false"     # generate new /builds/pod_dse/dse-x.x.x_name/resources' folder - this action will remove any existing one for this build folder !!
    ;;
  *)
    lib_generic_display_msgColourSimple "error" "cannot resolve pod defaults for pod: ${WHICH_POD}"
    ;;
  esac
}
