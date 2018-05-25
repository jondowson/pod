#!/bin/bash

# [1] handle incoming variables
editFile=${1};
label=${2};
block=${3};
WHICH_POD=${4};

# [2] identify host os
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
  printf "%s\n" "OS Not Supported";
  exit 1;
fi;

# [3] determine this scripts' folder path
parentPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P );
cd ${parentPath};
cd ../../../;
podHomePath="$(pwd)";
source "${podHomePath}/misc/.suitcase";

# [5] source pod_ + this pod's scripts
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

# [6] remove any existing block from file
GENERIC_lib_strings_removePodBlockAndEmptyLines "${editFile}" "${WHICH_POD}@${label}";

# [7] add new block to file
cat << EOF >> "${editFile}"

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
${block}
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
