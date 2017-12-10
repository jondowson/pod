#!/bin/bash

# author:        jondowson
# about:         script run on each server to install configured software

#-------------------------------------------

# uncomment to see full bash trace (debug)
# set -x

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
  lib_generic_display_msgColourSimple "ERROR-->" "OS Not Supported"
  exit 1;
fi

#-------------------------------------------

## determine this scripts' folder path

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
cd ../../
pod_home_path="$(pwd)"

source "${pod_home_path}/pods/pod_DSE/builds/dynamic_build_settings" 

#-------------------------------------------

## source pod_generic _ pod_dse lib scripts

files="$(find ${pod_home_path}/pod_/lib -name "*.sh" | grep -v "lib_generic_display.sh")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/pod_DSE/lib/ -name "*.sh*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

#-------------------------------------------

## source the pod-specific 'builds' folder to use

source ${build_folder_path}build_settings.sh

# folder specified at top of this script
build_file_folder="${build_folder_path}"
build_file_path="${build_file_folder}build_settings.sh"
if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  lib_generic_checks_fileExists "scripts_generic_launchPodRemotely#1" "true" "${build_file_path}"
fi

#-------------------------------------------

## install dse on each server

# [1] make folders

lib_doStuff_remotely_createDseFolders

# -----

# [2] un-compress software

lib_doStuff_remotely_installDseTar

# -----

# [3] merge the copied over 'resources' folder to the untarred one

cp -R "${build_file_folder}resources" "${INSTALL_FOLDER}${DSE_VERSION}"

# -----

# [4] configure local environment

lib_doStuff_remotely_dseBashProfile

if [[ ${os} == *"Ubuntu"* ]]; then
  lib_doStuff_remotely_bashrc
fi
