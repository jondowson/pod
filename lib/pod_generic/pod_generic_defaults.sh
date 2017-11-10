#!/bin/bash

# author:        jondowson
# about:         default settings for pod and each pod application

# ------------------------------------------

function pod_generic_defaults_pod(){

VB="false"          # verbose messages
STAGE_PAUSE="2"     # pauses between STAGES
STEP_PAUSE="0"      # pauses between TASK steps within a STAGE
}

# ------------------------------------------

function pod_generic_defaults_pod_dse(){

SEND_DSE_SOFTWARE="false"         # send DSE_SOFTWARE tarball bundle on each run
REGENERATE_RESOURCES="false"      # generate new /builds/pod_dse/dse-x.x.x_name/resources' folder - this action will remove any existing one for this build folder !!
}
