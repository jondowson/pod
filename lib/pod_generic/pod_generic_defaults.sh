#!/bin/bash

function pod_dse_defaults(){

## script runtime options

# send DSE_SOFTWARE folder to each server - this will take a few minutes and so you may want to do it only once
SEND_DSE_SOFTWARE="false"
# generate new 'CONFIG_FOLDER/resources' folder - this will remove any existing one !!
REGENERATE_RESOURCES="false"
# verbose messages to the screen
VB="false"
# pauses i.e. time allowed to read screen
STAGE_PAUSE="2"   # between stages
STEP_PAUSE="0"    # between steps within a stage
}
