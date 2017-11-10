#!/bin/bash

# author:        jondowson
# about:         determine os on machine

# ------------------------------------------


function pod_generic_identifyOs(){

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

pod_generic_identifyOs

printf "%s\n" "${os}"
