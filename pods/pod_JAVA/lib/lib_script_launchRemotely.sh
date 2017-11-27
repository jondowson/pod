#!/bin/bash

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

files="$(find ${pod_home_path}/lib/pod_generic -name "*.sh" | grep -v  "pod_generic_preperation.sh" | grep -v "pod_generic_display.sh" | grep -v "pod_generic_script_")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/lib/pod_dse -name "*.sh*" | grep -v  "pod_java_script_*")"
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

pod_java_run_remote_createJavaFolders

# -----

# [2] un-compress software

pod_java_run_remote_installJavaTar

# -----

# [3] configure local environment

pod_java_run_remote_javaBashProfile
pod_java_run_remote_bashrc
