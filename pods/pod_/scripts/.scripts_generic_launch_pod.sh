#!/usr/local/bin/bash

## about:      script launched on remote server - using mac version bash path above

# ------------------------------------------

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
  prepare_generic_display_msgColourSimple "ERROR-->" "OS Not Supported"
  exit 1;
fi

# -----

## determine this scripts' folder path

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
cd ../../../
pod_home_path="$(pwd)"
source "${pod_home_path}/misc/.suitcase"

# -----

## source pod_ + pod_JAVA lib scripts

files="$(find ${pod_home_path}/pods/pod_/lib/ -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/pods/pod_/prepare/ -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/pods/${WHICH_POD}/lib/ -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

# -----

## source the pod-specific 'builds' folder to use

build_file_path="${build_folder_path}build_settings.bash"
if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  lib_generic_checks_fileExists "scripts_launchPodRemotely#1" "true" "${build_file_path}"
fi

# ------------------------------------------ executed remotely

## configure local environment

# [1] check if Ubuntu to include bash_profile call

if [[ ${os} == *"Ubuntu"* ]]; then
  lib_generic_doStuff_remotely_bashrc
fi

# -----

# [2] run the remite functions for this pod

lib_doStuff_remotely_${WHICH_POD}

# -----

# [3] tidy up
prepare_generic_misc_clearTheDecks
