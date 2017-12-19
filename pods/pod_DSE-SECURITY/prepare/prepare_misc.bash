#!/bin/bash

# author:        jondowson
# about:         preperation functions for 'pod_JAVA'

# ------------------------------------------

function prepare_misc_checkFilesExist(){

## test specified files exist

# test POD_SOFTWARE folder and java_tar file are available
if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
  lib_generic_checks_folderExists "prepare_misc.sh#1" "true" "${POD_SOFTWARE}"
  lib_generic_checks_fileExists   "prepare_misc.sh#2" "true" "${java_tar_file}"
fi

}

# ------------------------------------------

function prepare_misc_setDefaults(){

## pod_DSE default settings

SEND_POD_SOFTWARE="true"         # send POD_SOFTWARE tarball bundle on each run
STRICT_START="false"             # exit pod_JAVA if any server cannot be reached or dependencies are not available
}
