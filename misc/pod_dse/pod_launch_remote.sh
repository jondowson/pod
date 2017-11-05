#!/bin/bash

# script_name:   pod_launch_remote.sh
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
  generic_msg_colour_simple "error" "OS Not Supported"
  exit 1;
fi

#-------------------------------------------

## determine this scripts' folder path

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
podSetupFolder="$(cd ../../; pwd)"

#-------------------------------------------

## source pod lib scripts

files="$(find ${podSetupFolder}/lib -name "*.sh*" | grep -v  "dependencies_mac.sh" | grep -v  "format.sh")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

#-------------------------------------------

## source the config settings folder to use

# folder specified at top of this script
build_file_folder="${build_folder_path}"
build_file_path="${build_file_folder}cluster_settings.sh"
if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  generic_file_exists_check_abort "${build_file_path}"
fi

#-------------------------------------------

## install dse on each server

# [1] make folders and un-compress software

pod_remote_create_dse_folders

if [[ ${JAVA_INSTALL_TYPE} == "tar" ]] && [[ ${os} != "Mac" ]]; then
  pod_remote_install_java_tar
fi

pod_remote_install_dse_tar

# -----

# [2] merge the copied over 'resources' folder to the untarred one

cp -R "${build_file_folder}resources" "${INSTALL_FOLDER}${DSE_VERSION}"

# -----

# [3] configure local environment

pod_remote_configure_dse_bash_profile

if [[ ${JAVA_INSTALL_TYPE} == "tar" ]] && [[ ${os} != "Mac" ]]; then
  pod_remote_configure_java_bash_profile
fi

pod_remote_configure_bashrc
