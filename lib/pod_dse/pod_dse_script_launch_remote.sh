#!/bin/bash

# script_name:   pod_dse_script_launch_remote.sh
# author:        jondowson
# about:         script run on each server to install configured software  

#===========================================AUTO-EDITED!!

build_folder_path="AUTO-EDITED"

#===========================================END!!

# uncomment to see full bash trace (debug)
#set -x

#-------------------------------------------

## determine OS of this computer

os=$(uname -a)
if [[ ${os} == *"Darwin"* ]]; then
  os="Mac"
elif [[ ${os} == *"Ubuntu"* ]]; then
  os="Ubuntu"
elif [[ "$(cat /etc/system-release-cpe)" == *"centos"* ]]; then
  os="Centos"
elif [[ "$(cat /etc/system-release-cpe)" == *"redhat"* ]]; then
  os="Redhat"
else
  os="Bad"
  pod_generic_display_msgColourSimple "error" "OS Not Supported"
  exit 1;
fi

#-------------------------------------------

## determine this scripts' folder path

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
cd ../../
pod_home_path="$(pwd)"

#-------------------------------------------

## source pod_generic _ pod_dse lib scripts

files="$(find ${pod_home_path}/lib/pod_generic -name "*.sh" | grep -v  "pod_generic_preperation.sh"  | grep -v  "pod_generic_display.sh")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/lib/pod_dse -name "*.sh*" | grep -v  "pod_dse_script_*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

#-------------------------------------------

## source the pod-specific 'builds' folder to use

source ${build_folder_path}cluster_settings.sh

# folder specified at top of this script
build_file_folder="${build_folder_path}"
build_file_path="${build_file_folder}cluster_settings.sh"
if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  pod_generic_misc_fileExistsCheckAbort "${build_file_path}"
fi

#-------------------------------------------

## install dse on each server

# [1] make folders

pod_dse_run_remote_createDseFolders

# -----

# [2] un-compress software

if [[ ${JAVA_INSTALL_TYPE} == "tar" ]] && [[ ${os} != "Mac" ]]; then
  pod_dse_run_remote_installJavaTar
fi

pod_dse_run_remote_installDseTar

# -----

# [3] merge the copied over 'resources' folder to the untarred one

cp -R "${build_file_folder}resources" "${INSTALL_FOLDER}${DSE_VERSION}"

# -----

# [4] configure local environment

pod_dse_run_remote_dseBashProfile
pod_dse_run_remote_bashrc

if [[ ${JAVA_INSTALL_TYPE} == "tar" ]] && [[ ${os} != "Mac" ]]; then
  pod_dse_run_remote_javaBashProfile
fi
