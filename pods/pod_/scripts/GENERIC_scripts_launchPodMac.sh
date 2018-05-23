#!/usr/local/bin/bash

# about:      script launched on remote server - using mac bash path above

# ------------------------------------------

## [1] determine OS of this computer

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
  GENERIC_prepare_display_msgColourSimple "ERROR-->" "OS Not Supported"
  exit 1;
fi

# -----

## [2] determine this scripts' folder path

parentPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parentPath}
cd ../../../
podHomePath="$(pwd)"
source "${podHomePath}/misc/.suitcase"
target_folder=${TARGET_FOLDER}

# -----

# [3.1] jq - bash jason parser
jqFolderPath="/usr/local/Cellar/jq/1.5_3/bin/"
jqFilePath="${jqFolderPath}jq"
GENERIC_lib_checks_fileExists "launch-pod#3.1.1" "true" "${jqFilePath}"
# [3.2] ensure third party packages are executable
chmod -R 777 "${podHomePath}/third_party/"
PATH=${jqFolderPath}:$PATH

# -----

## [4] source pod_ + this pod's scripts

files="$(find ${podHomePath}/pods/pod_/lib/ -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${podHomePath}/pods/pod_/prepare/ -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${podHomePath}/pods/${WHICH_POD}/lib/ -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

# -----

## [5] source the pod-specific 'builds' folder to use

build_file_path="${build_folder_path}build_settings.bash"
if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  GENERIC_lib_checks_fileExists "scripts_launchPodRemotely#1" "true" "${build_file_path}"
fi


# ------------------------------------------ executed remotely


## configure local environment

# [1] check if Ubuntu to include bash_profile call

if [[ ${os} == *"Ubuntu"* ]]; then
  GENERIC_lib_doStuffRemotely_bashrc
fi

# -----

# [2] run the remote functions for this pod

lib_doStuffRemotely_${WHICH_POD}

# -----

# [3] tidy up
GENERIC_prepare_misc_clearTheDecks
