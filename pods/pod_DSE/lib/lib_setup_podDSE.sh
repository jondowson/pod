#!/bin/bash

# author:        jondowson
# about:         functions to source scripts and check files exist for 'pod_dse'

# ------------------------------------------

function pod_dse_setup_checkFilesExist(){

## test specified files exist

if [[ ${clusterstateFlag} != "true" ]]; then
  # test POD_SOFTWARE folder is available
  if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
    lib_generic_misc_folderExistsCheckAbort "${POD_SOFTWARE}"
    lib_generic_misc_fileExistsCheckAbort   "${dse_tar_file}"
  fi
fi
}

# ------------------------------------------

function pod_dse_setup_duplicateResourcesFolder(){

## prepare duplicate version of 'pod' project

# this requires an existing local resources folder
# note: it is this duplicate folder will be configured locally and then sent to remote server(s)

tmp_build_folder="${pod_home_path}/tmp/pod/"
tmp_build_file_folder="${tmp_build_folder}pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
tmp_build_file_path="${tmp_build_file_folder}build_settings.sh"

# delete any existing duplicated 'pod' folder from '/tmp'
tmp_folder="${pod_home_path}/tmp/"
rm -rf "${tmp_folder}"

# duplicate 'pod' folder to working directory '/tmp'
tmp_working_folder="${pod_home_path}/tmp/pod/"
mkdir -p "${tmp_working_folder}"

cp -rp "${pod_home_path}/pods" "${tmp_working_folder}"
cp -rp "${pod_home_path}/lib" "${tmp_working_folder}"
cp -rp "${pod_home_path}/misc" "${tmp_working_folder}"
cp -rp "${pod_home_path}/third_party" "${tmp_working_folder}"
cp -p ${pod_home_path}/*.* "${tmp_working_folder}"
cp -p ${pod_home_path}/launch-pod "${tmp_working_folder}"
}
