#!/bin/bash

# author:        jondowson
# about:         functions required prior to running a pod

# ------------------------------------------

function lib_generic_prepare_flagRules(){

## rules for accepting flags

# part 1 - flag checks
case ${WHICH_POD} in

  "pod_DSE" )

      if [[ ${clusterstateFlag} == "true" ]]; then
          if [[ ${buildFlag} == "true" ]] || [[ ${sendsoftFlag} == "true" ]]  || [[ ${regenresourcesFlag} == "true" ]]; then 
            lib_generic_display_msgColourSimple "error" "You must supply the correct combination of flags - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
          elif [[ ${serversFlag} != "true" ]]; then
            lib_generic_display_msgColourSimple "error" "You must supply a server .json definition file - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
          elif [[ ${CLUSTER_STATE} != "stop" ]] && [[ ${CLUSTER_STATE} != "start" ]]; then
            lib_generic_display_msgColourSimple "error" "You must specify --clusterstate as either ${yellow}stop${red} or ${yellow}start${red}" && exit 1;
          fi
      else
        if [[ ${buildFlag} != "true" ]] && [[ ${serversFlag} != "true" ]]; then 
          printf "\n%s\n\n" "${b}${red}error: You must supply both a build folder and a server json definition file - please check the help: ${yellow}./launch-pod --help${red} !! ${reset}" && exit 1; 
        elif [[ ${BUILD_FOLDER} == "" ]]; then 
          lib_generic_display_msgColourSimple "error" "You must supply a value for ${yellow}--builds${red} - please check the help: ${yellow}./launch-pod --help${red}" && exit 1; 
        elif [[ ${SERVERS_JSON} == "" ]]; then 
          lib_generic_display_msgColourSimple "error" "You must supply a value for ${yellow}--servers${red} - please check the help: ${yellow}./launch-pod --help${red}" && exit 1; 
        elif [[ ${regenresourcesFlag} == "true" ]] && [[ "${REGENERATE_RESOURCES}" == "" ]] || [[ ${sendsoftFlag} == "true" ]] && [[ "${SEND_POD_SOFTWARE}" == "" ]]; then
           lib_generic_display_msgColourSimple "error" "You must supply values for ${yellow}--regenresources${red} and ${yellow}--sendsoft${red} flags - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
        fi
      fi ;;
  *)
      printf "%s\n" "${b}${red}error: You have specified an invalid pod: ${yellow}${WHICH_POD}${red} !! ${reset}" && exit 1 ;;
esac
}

# ------------------------------------------

function lib_generic_prepare_identifyOs(){

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
  lib_generic_display_msgColourSimple "error" "OS Not Supported"
  exit 1;
fi
}

# ------------------------------------------

function lib_generic_prepare_getPodPath(){

## determine the folder path of pod

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
cd ../../
pod_home_path="$(pwd)/"
}

# ------------------------------------------

function lib_generic_prepare_sourceGenericLib(){

## source pod-specific + 'pod_generic' lib scripts

files="$(find ${pod_home_path}/lib/pod_GENERIC -name "*.sh*" | grep -v  "lib_generic_prepare_pod.sh" | grep -v  "lib_generic_script_")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done
}

# ------------------------------------------

function lib_generic_prepare_sourcePodLib(){

## source pod-specific lib scripts

files="$(find ${pod_home_path}/lib/${WHICH_POD} -name "*.sh*" | grep -v  "lib_script_*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done
}

# ------------------------------------------

function lib_generic_prepare_sourcePodStages(){

## source pod-specific stages scripts

files="$(find ${pod_home_path}/stages/${WHICH_POD} -name "*.sh*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/stages/pod_GENERIC -name "*.sh*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done
}

# ------------------------------------------

function lib_generic_prepare_sourcePodBuilds(){

## source the pod-specific 'builds' folder to use

build_file_folder="${pod_home_path}/builds/${WHICH_POD}/${BUILD_FOLDER}/"
build_file_path="${build_file_folder}build_settings.sh"

if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  lib_generic_misc_fileExistsCheckAbort "build file path is wrong: ${build_file_path}"
fi
}

# ---------------------------------------

function lib_generic_prepare_hashBang(){

## ensure bash interpreter is set correctly for pod on remote os

# determine what comes after #!/ at top of remote launch script
if [[ ${remote_os} == *"Mac"* ]]; then
  hashBang="usr/local/bin/bash"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}launch-pod" "bin/bash" "${hashBang}"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/${WHICH_POD}/lib_script_launchRemotely.sh" "bin/bash" "${hashBang}"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/${WHICH_POD}/lib_doStuff_remotely.sh" "bin/bash" "${hashBang}"
elif [[ ${remote_os} == "Ubuntu" ]]; then
  hashBang="bin/bash"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}launch-pod" "usr/local/bin/bash" "${hashBang}"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/${WHICH_POD}/${WHICH_POD}lib_script_launchRemotely.sh" "usr/local/bin/bash" "${hashBang}"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/${WHICH_POD}/${WHICH_POD}lib_doStuff_remotely.sh" "usr/local/bin/bash" "${hashBang}"
elif [[ ${remote_os} == "Centos" ]]; then
  hashBang="bin/bash"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}launch-pod" "usr/local/bin/bash" "${hashBang}"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/${WHICH_POD}/${WHICH_POD}lib_script_launchRemotely.sh" "usr/local/bin/bash" "${hashBang}"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/${WHICH_POD}/${WHICH_POD}lib_doStuff_remotely.sh" "usr/local/bin/bash" "${hashBang}"
elif [[ ${remote_os} == "Redhat" ]]; then
  hashBang="bin/bash"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}launch-pod" "usr/local/bin/bash" "${hashBang}"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/${WHICH_POD}/${WHICH_POD}lib_script_launchRemotely.sh" "usr/local/bin/bash" "${hashBang}"
  lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/${WHICH_POD}/${WHICH_POD}lib_doStuff_remotely.sh" "usr/local/bin/bash" "${hashBang}"
else
  os="Bad"
  lib_generic_display_msgColourSimple "error" "OS Not Supported"
  exit 1;
fi
}
