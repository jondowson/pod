#!/bin/bash

## about:      launch the specified pod on the remote server

# ------------------------------------------


# [1] determine OS of this computer
os=$(uname -a);
if [[ ${os} == *"Darwin"* ]]; then
  os="Mac";
elif [[ ${os} == *"Ubuntu"* ]]; then
  os="Ubuntu";
elif [[ "$(cat /etc/system-release-cpe)" == *"centos"* ]]; then
  os="Centos";
elif [[ "$(cat /etc/system-release-cpe)" == *"redhat"* ]]; then
  os="Redhat";
else
  os="Bad";
  printf "%s\n" "ERROR: OS Not Supported";
  exit 1;
fi;

# -----

# [2] determine this scripts' folder path
parentPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P );
cd ${parentPath};
cd ../../../;
podHomePath="$(pwd)";
source "${podHomePath}/misc/.suitcase";
target_folder=${TARGET_FOLDER};

# -----

# [3] make pod and third party files executable
chmod -R 777 "${podHomePath}/pods/pod_/scripts";
chmod -R 777 "${podHomePath}/third_party/";

# -----

# [4] use Mac version as uses different bash interpreter
if [[ "${os}" == "Mac" ]]; then
  . ${podHomePath}/pods/pod_/scripts/GENERIC_scripts_launchPodMac.sh
  exit;
fi

# -----

# [5] make pod and third party files executable
chmod -R 777 "${podHomePath}/pods/pod_/scripts/*.sh";
chmod -R 777 "${podHomePath}/third_party/";

# -----

# [6] setup jq - bash jason parser
if [[ "${os}" == "Mac" ]]; then
  jqFolderPath="/usr/local/Cellar/jq/1.5_3/bin/";
else
  jqFolderPath="${podHomePath}/third_party/jq-linux64/";
fi
PATH=${jqFolderPath}:$PATH;
export PATH=$PATH

# -----

# [7] source pod_ + this pod's scripts
files="$(find ${podHomePath}/pods/pod_/lib/ -name "*.bash")";
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file;
done;

files="$(find ${podHomePath}/pods/pod_/prepare/ -name "*.bash")";
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file;
done;

files="$(find ${podHomePath}/pods/${WHICH_POD}/lib/ -name "*.bash")";
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file;
done;

# -----

# [8] source the pod-specific 'builds' folder to use
build_file_path="${build_folder_path}build_settings.bash";
if [[ -f ${build_file_path} ]]; then
  source ${build_file_path};
else
  GENERIC_lib_checks_fileExists "scripts_launchPodRemotely#1" "true" "${build_file_path}";
fi;


# ------------------------------------------ run remote functions

# [A] check if Ubuntu to include bash_profile call
if [[ ${os} == *"Ubuntu"* ]]; then
  GENERIC_lib_doStuffRemotely_bashrc;
fi;

# -----

# [B] run functions for this pod
lib_doStuffRemotely_${WHICH_POD};

# -----

# [C] tidy up any tmp files
GENERIC_prepare_misc_clearTheDecks;
