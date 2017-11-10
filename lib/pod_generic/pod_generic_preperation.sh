#!/bin/bash

# author:        jondowson
# about:         functions required prior to running a pod

# ------------------------------------------

function pod_generic_preperation_flagRules(){

## rules for accepting flags
  
# pod_general
if [[ ${WHICH_POD} == "" ]]; then printf "\n%s\n\n" "${b}${red}error: You must specify which ${yellow}pod${red} to run !! ${reset}" && exit; fi; 

# pod_dse 
if [[ ${WHICH_POD} == "pod_dse" ]] && [[ ${BUILD_FOLDER} == "" ]]; then printf "\n%s\n\n" "${b}${red}error: You must specify a build folder for ${yellow}pod_dse${red} !! ${reset}" && exit; fi;
if [[ ${WHICH_POD} == "pod_dse" ]] && [[ ${SERVERS_JSON} == "" ]]; then printf "\n%s\n\n" "${b}${red}error: You must specify a server json definition file for ${yellow}pod_dse${red} !! ${reset}" && exit; fi;  
}

# ------------------------------------------

function pod_generic_preperation_identifyOs(){

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
}

# ------------------------------------------

function pod_generic_preperation_getPodPath(){

## determine the folder path of pod

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
cd ../../
pod_home_path="$(pwd)/"
}

# ------------------------------------------

function pod_generic_preperation_sourceGenericLib(){

## source pod-specific + 'pod_generic' lib scripts

files="$(find ${pod_home_path}/lib/pod_generic -name "*.sh*" | grep -v  "pod_generic_preperation.sh" | grep -v  "pod_generic_script_")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done
}

# ------------------------------------------

function pod_generic_preperation_sourcePodLib(){

## source pod-specific lib scripts

files="$(find ${pod_home_path}/lib/${WHICH_POD} -name "*.sh*" | grep -v  "pod_dse_script_*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done
}

# ------------------------------------------

function pod_generic_preperation_sourcePodStages(){

## source pod-specific stages scripts

files="$(find ${pod_home_path}/stages/${which_pod} -name "*.sh*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done
}
