#!/usr/local/bin/bash

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

## source pod_ + pod_DSE lib scripts

files="$(find ${pod_home_path}/pods/pod_/lib -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/pods/pod_/prepare -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

files="$(find ${pod_home_path}/pods/pod_DSE/lib/ -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

# ------------------------------------------

## source the pod-specific 'builds' folder to use

build_file_path="${build_folder_path}build_settings.bash"
if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  lib_generic_checks_fileExists "scripts_launchPodRemotely#1" "true" "${build_file_path}"
fi

# ------------------------------------------

## install dse + agents on each server

# [1] delete any previous pod build folder with the same name

rm -rf ${INSTALL_FOLDER_POD}${BUILD_FOLDER}

# [2] make folders

lib_doStuff_remotely_createDseFolders

# -----

# [3] un-compress software

lib_generic_doStuff_remotely_unpackTar "${dse_tar_file}" "${INSTALL_FOLDER_POD}${BUILD_FOLDER}"
lib_generic_doStuff_remotely_unpackTar "${agent_tar_file}" "${INSTALL_FOLDER_POD}${BUILD_FOLDER}"

# -----

# [4] merge the copied over 'resources' folder to the untarred one
cp -R "${build_folder_path}resources" "${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${DSE_VERSION}"

# -----

# [5] update the datastax-agent address.yaml to point to opscenter and environment to find JAVA_HOME

lib_doStuff_remotely_agentAddressYaml
lib_doStuff_remotely_agentEnvironment

# -----

# [6] rename this redundant and meddlesome file !!

lib_doStuff_remotely_cassandraTopologyProperties

# -----

# [7] configure local environment

lib_generic_doStuff_remotely_updatePathBashProfile "CASSANDRA" "${dse_untar_bin_folder}"

if [[ ${os} == *"Ubuntu"* ]]; then
  lib_generic_doStuff_remotely_bashrc
fi

# -----

# [7] tidy up
prepare_generic_misc_clearTheDecks
