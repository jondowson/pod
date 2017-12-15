#!/bin/bash

# author:        jondowson
# about:         script run on each server to install configured software

# ------------------------------------------

# uncomment to see full bash trace (debug)
# set -x

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
  lib_generic_display_msgColourSimple "ERROR-->" "OS Not Supported"
  exit 1;
fi

# ------------------------------------------

## determine this scripts' folder path

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
cd ../../../
pod_home_path="$(pwd)"
source "${pod_home_path}/misc/.suitcase"

if [[ "${os}" == "Mac" ]]; then

  chmod +x ${pod_home_path}/pods/pod_JAVA/scripts/.scripts_launchPodRemotely.sh
  . ${pod_home_path}/pods/pod_JAVA/scripts/.scripts_launchPodRemotely.sh

else

# ------------------------------------------

  ## source pod_ + pod_JAVA lib scripts

  files="$(find ${pod_home_path}/pods/pod_/lib -name "*.bash" | grep -v "lib_generic_display.bash")"
  for file in $(printf "%s\n" "$files"); do
      [ -f $file ] && . $file
  done

  files="$(find ${pod_home_path}/pods/pod_/prepare -name "*.bash")"
  for file in $(printf "%s\n" "$files"); do
      [ -f $file ] && . $file
  done

  files="$(find ${pod_home_path}/pods/pod_JAVA/lib/ -name "*.bash*")"
  for file in $(printf "%s\n" "$files"); do
      [ -f $file ] && . $file
  done

# ------------------------------------------

  ## source the pod-specific 'builds' folder to use

  source ${build_folder_path}build_settings.bash

  # folder specified at top of this script
  build_file_folder="${build_folder_path}"
  build_file_path="${build_file_folder}build_settings.bash"
  if [[ -f ${build_file_path} ]]; then
    source ${build_file_path}
  else
    lib_generic_checks_fileExists "scripts_launchPodRemotely#1" "true" "${build_file_path}"
  fi

# ------------------------------------------

  ## install java on each server

  # [1] delete any previous java install folder with the same version

  rm -rf ${java_untar_folder}

  # [2] make folders

  lib_doStuff_remotely_createJavaFolders

# -----

  # [3] un-compress software

  lib_doStuff_remotely_installJavaTar

# -----

  # [4] configure local environment

  lib_doStuff_remotely_javaBashProfile

  if [[ ${os} == *"Ubuntu"* ]]; then
    lib_doStuff_remotely_bashrc
  fi

# -----

  # [5] tidy up
  prepare_generic_misc_clearTheDecks

fi
