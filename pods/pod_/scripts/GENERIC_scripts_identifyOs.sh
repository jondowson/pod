#!/bin/bash

# about: script to output os on remote machine - works for both mac and linux

# ---------------------------------------

function GENERIC_scripts_identifyOs(){

## determine OS of computer

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
  os="Unrecognised"
fi
}

GENERIC_scripts_identifyOs
printf "%s\n" "${os}"
