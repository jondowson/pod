#!/bin/bash

# script_name:   pod_generic_setup_functions.sh
# author:        jondowson
# about:         functions required prior to running a pod

# ------------------------------------------

function pod_generic_functions_get_ready_serversJson(){

servers_json_path="${pod_home_path}/servers/${SERVERS_JSON}"
}

# ------------------------------------------

function pod_generic_functions_get_ready_identifyOs(){

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
}

# ------------------------------------------

function pod_get_ready_get_pod_path(){

## determine the folder path of pod

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
cd ../../
pod_home_path="$(pwd)/"
}

# ------------------------------------------

function pod_generic_functions_get_ready_sourceFiles(){

## source pod-specific + 'pod_generic' lib scripts

files="$(find ${pod_home_path}/lib/pod_generic -name "*.sh*" | grep -v  "pod_generic_functions_get_ready.sh")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/lib/${which_pod} -name "*.sh*" | grep -v  "pod_dse_script_*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

# -----

## source pod-specific stages scripts

files="$(find ${pod_home_path}/stages/${which_pod} -name "*.sh*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

# -----

## source the pod-specific 'builds' folder to use

build_file_folder="${pod_home_path}/builds/${which_pod}/${BUILD_FOLDER}/"
build_file_path="${build_file_folder}cluster_settings.sh"

if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  generic_file_exists_check_abort "${build_file_path}"
fi
}
