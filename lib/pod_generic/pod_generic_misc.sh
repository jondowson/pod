#!/bin/bash

# author: jondowson
# about:  miscellaneous generic bash functions

# ---------------------------------------

function pod_generic_misc_chooseOsCommand(){

## dynamically choose command based on the OS
# e.g. generic_dynamic_os_command "gsed -i" "sed -i" "sed -i" "sed -i"

mac_cmd=${1}
ubuntu_cmd=${2}
centos_cmd=${3}
redhat_cmd=${4}

if [[ "${os}" == "Mac" ]];then
  printf "%s" ${mac_cmd}
elif [[ "${os}" == "Ubuntu" ]];then
  printf "%s" ${ubuntu_cmd}
elif [[ "${os}" == "Centos" ]];then
  printf "%s" ${centos_cmd}
elif [[ "${os}" == "Redhat" ]];then
  printf "%s" ${redhat_cmd}
else
  pod_generic_display_msgColourSimple "error" "functions_generic.sh | generic_dynamic_os_command --> 'Unsupported OS'"
  exit 1;
fi
}

# ---------------------------------------

function pod_generic_misc_fileExistsCheckAbort(){

## check for the existence of a file - abort script if failure

file="${1}"
[[ ! -f ${file} ]] && \
printf "%s\n" && \
pod_generic_display_msgColourSimple "error" "Aborting script: ${yellow}${file}${red} - file not found" \
&& exit 1;
}

# ---------------------------------------

function pod_generic_misc_folderExistsCheckAbort(){

## check for the existence of a file - abort script if failure

folder="${1}"
[[ ! -d ${folder} ]] && \
printf "%s\n" && \
pod_generic_display_msgColourSimple "error" "Aborting script: ${yellow}${folder}${red} - folder not found" \
&& exit 1;
}

# ---------------------------------------

function pod_generic_misc_timecount(){
min=0
sec=${1}
message=${2}
echo "${2}"
while [ $min -ge 0 ]; do
      while [[ $sec -ge 0 ]]; do
          echo -ne "00:0$min:$sec\033[0K\r"
          sec=$((sec-1))
          sleep 1
      done
      sec=59
      min=$((min-1))
done
}

# ---------------------------------------

function pod_generic_misc_timePod(){

## calculate pod runtime

pod_end=$(date +%s)
diff=$((pod_end - pod_start))
}
