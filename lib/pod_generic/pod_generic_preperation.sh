#!/bin/bash

# author:        jondowson
# about:         functions required prior to running a pod

# ------------------------------------------

function pod_generic_preperation_flagRules(){

## rules for accepting flags

# part 1 - flag checks
case ${WHICH_POD} in

  "pod_dse" )

      if [[ ${clusterstateFlag} == "true" ]]; then
          if [[ ${buildFlag} == "true" ]] || [[ ${sendsoftFlag} == "true" ]]  || [[ ${regenresourcesFlag} == "true" ]]; then 
            pod_generic_display_msgColourSimple "error" "You must supply the correct combination of flags - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
          elif [[ ${serversFlag} != "true" ]]; then
            pod_generic_display_msgColourSimple "error" "You must supply a server .json definition file - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
          elif [[ ${CLUSTER_STATE} != "stop" ]] && [[ ${CLUSTER_STATE} != "start" ]]; then
            pod_generic_display_msgColourSimple "error" "You must specify --clusterstate as either ${yellow}stop${red} or ${yellow}start${red}" && exit 1;
          fi
      else
        if [[ ${buildFlag} != "true" ]] && [[ ${serversFlag} != "true" ]]; then 
          printf "\n%s\n\n" "${b}${red}error: You must supply both a build folder and a server json definition file - please check the help: ${yellow}./launch-pod --help${red} !! ${reset}" && exit 1; 
        elif [[ ${BUILD_FOLDER} == "" ]]; then 
          pod_generic_display_msgColourSimple "error" "You must supply a value for ${yellow}--builds${red} - please check the help: ${yellow}./launch-pod --help${red}" && exit 1; 
        elif [[ ${SERVERS_JSON} == "" ]]; then 
          pod_generic_display_msgColourSimple "error" "You must supply a value for ${yellow}--servers${red} - please check the help: ${yellow}./launch-pod --help${red}" && exit 1; 
        elif [[ ${regenresourcesFlag} == "true" ]] && [[ "${REGENERATE_RESOURCES}" == "" ]] || [[ ${sendsoftFlag} == "true" ]] && [[ "${SEND_DSE_SOFTWARE}" == "" ]]; then
           pod_generic_display_msgColourSimple "error" "You must supply values for ${yellow}--regenresources${red} and ${yellow}--sendsoft${red} flags - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
        fi
      fi ;;
  *)
      printf "%s\n" "${b}${red}error: You have specified an invalid pod: ${yellow}${WHICH_POD}${red} !! ${reset}" && exit 1 ;;
esac
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

# ------------------------------------------

function pod_generic_preperation_sourcePodBuilds(){

## source the pod-specific 'builds' folder to use

build_file_folder="${pod_home_path}/builds/${WHICH_POD}/${BUILD_FOLDER}/"
build_file_path="${build_file_folder}cluster_settings.sh"

if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  pod_generic_misc_fileExistsCheckAbort "build file path is wrong: ${build_file_path}"
fi
}
