#!/bin/bash

# author:        jondowson
# about:         functions to source scripts and check files exist for 'pod_java'

# ------------------------------------------

function pod_java_setup_checkFilesExist(){

## test specified files exist

# check /servers/<json> file exists
pod_generic_misc_fileExistsCheckAbort "${servers_json_path}"

# check jq library is available
if [[ "${os}" != "Mac" ]]; then
  pod_generic_misc_fileExistsCheckAbort "${jq_file_path}"
fi

# test java folder is available
pod_generic_misc_fileExistsCheckAbort "${java_tar_file}"
}
