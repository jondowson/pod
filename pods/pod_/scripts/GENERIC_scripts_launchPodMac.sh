#!/usr/local/bin/bash

## about:      launch the specified pod on the remote server - Mac version

# ------------------------------------------


# [1] determine this scripts' folder path
parentPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P );
cd ${parentPath};
cd ../../../;
podHomePath="$(pwd)";
source "${podHomePath}/misc/.suitcase";
target_folder=${TARGET_FOLDER};

# -----

# [2] make pod and third party files executable
chmod -R 777 "${podHomePath}/pods/pod_/scripts";
chmod -R 777 "${podHomePath}/third_party/";

# -----

# [3] setup jq - bash jason parser
jqFolderPath="/usr/local/Cellar/jq/1.5_3/bin/";
PATH=${jqFolderPath}:$PATH;
export PATH=$PATH

# -----

# [4] source pod_ + this pod's scripts
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

# [5] source the pod-specific 'builds' folder to use
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
