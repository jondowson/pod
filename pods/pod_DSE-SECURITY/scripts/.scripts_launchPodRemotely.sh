#!/usr/local/bin/bash

# author:        jondowson
# about:         script run on each server to install configured software for Macs

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

# ------------------------------------------

## source pod_ + pod_DSE-SECURITY scripts

files="$(find ${pod_home_path}/pods/pod_/lib -name "*.bash" | grep -v "lib_generic_display.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/pods/pod_/prepare -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/pods/pod_DSE-SECURITY/lib/ -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

# ------------------------------------------

## source the pod-specific 'builds' folder to use

# build_folder_path specified in suitcase
build_file_path="${build_folder_path}build_settings.bash"
if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  lib_generic_checks_fileExists "scripts_launchPodRemotely#1" "true" "${build_file_path}"
fi

# ------------------------------------------

## edit DSE config files

# [1] delete any previous java install folder with the same version

lib_doStuff_remotely_dseYamlTDE
lib_doStuff_remotely_dseYamlAuditLogging
