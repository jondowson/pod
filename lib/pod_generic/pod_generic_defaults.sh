#!/bin/bash

# author:        jondowson
# about:         default settings for pod and each pod application

# ------------------------------------------

function pod_generic_defaults(){

## general pod settings

VB="false"           # verbose messages
STAGE_PAUSE="10"     # pauses between STAGES
STEP_PAUSE="2"       # pauses between TASK steps within a STAGE

case "${WHICH_POD}" in
  pod_dse)
    SEND_DSE_SOFTWARE="true"         # send DSE_SOFTWARE tarball bundle on each run
    REGENERATE_RESOURCES="false"     # generate new /builds/pod_dse/dse-x.x.x_name/resources' folder - this action will remove any existing one for this build folder !!
    USE_BUILDS="true"                # does this pod require the builds folder?
    ;;
  pod_dse_rollingStartStop)
    USE_BUILDS="false"               # does this pod require the builds folder?
    ;;
  *)
    pod_generic_display_msgColourSimple "error" "cannot resolve pod defaults for pod: ${WHICH_POD}"
    ;;
  esac
}
