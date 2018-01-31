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

files="$(find ${pod_home_path}/pods/${WHICH_POD}/lib/ -name "*.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

# ------------------------------------------

## source the pod-specific 'builds' folder to use

build_file_path="${build_folder_path}build_settings.bash"
if [[ -f ${build_file_path} ]]; then
  source ${build_file_path}
else
  lib_generic_checks_fileExists ".scripts_launchPodRemotely#1" "true" "${build_file_path}"
fi

# ------------------------------------------

## configure audit + security settings

# [1] create folders

lib_generic_doStuff_remotely_createFolders "${system_key_directory}"

# [2] edit dse.yaml config file

lib_doStuff_remotely_dseYamlTDE
lib_doStuff_remotely_dseYamlAuditLogging

# -----

# [3] edit cassandra.yaml config file

lib_doStuff_remotely_cassandraYamlServerEncryption
lib_doStuff_remotely_cassandraYamlClientEncryption

# -----

# [4] create keys / distribute keys

if [[ "${generate_keys}" ==  "true" ]]; then
  if [[ "${first_server_flag}" ==  "true" ]]; then
    lib_doStuff_remotely_dseYamlSystemKeyDirectory
    if [[ "${system_key_flag}" ==  "true" ]]; then
      lib_doStuff_remotely_dsetoolCreateSystemKey "system_key"
    fi
    lib_doStuff_remotely_dsetoolCreateSystemKey "${application_key_name}"
  fi
fi

# -----

# [5] tidy up

prepare_generic_misc_clearTheDecks
rm -rf ${INSTALL_FOLDER_POD}        # this folder is empty so tidy it up
