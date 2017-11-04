#!/bin/bash

# script_name: functions_generic.sh
# author: jondowson
# about: generic bash functions usable by any script

# ---------------------------------------

function generic_dynamic_os_command(){

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
  generic_msg_colour_simple "error" "functions_generic.sh | generic_dynamic_os_command --> 'Unsupported OS'"
  exit 1;
fi
}

# ---------------------------------------

function generic_ifs_string_delimeter(){

## split a string by delimeter
# e.g. generic_ifs_delimeter "this;that;other" ";"
#      ---> _D1_="this" and _D2_="that" and _D3_="other"

string=${1}
delim=${2}

IFS=${delim} read -r -a array <<< "${string}"
arraySize=${#array[@]}

for x in $(seq 1 $arraySize);
do
  y=$(($x-1))
  declare _Z${x}_="${array[$y]}"
done
}

# ---------------------------------------

function generic_parameter_expansion_delimeter(){

## split a string by delimeter
# e.g. generic_parameter_expansion_delimeter "this;that;other" ";" "2"
#      ---> _D1_="this" and _D2_="that" and _D3_="other"

string=${1}
delim=${2}
noOfDelims=${3}

if [[ "${noOfDelims}" == "1" ]]; then
  _D1_=${string%;*}
  _D2_=${string#*;}
elif [[ "${noOfDelims}" == "2" ]]; then
  _D1_=${string%%${delim}*}
  _D3_=${string##*${delim}}
  _a_=${string#*;}
  _D2_=${_a_%${delim}*}
else
  generic_msg_colour_simple "error" "functions_generic.sh | generic_parameter_expansion_delimeter --> 'Unsupported no. of delimeted values'"
  exit 1;
fi
}

# ---------------------------------------

function generic_sed_string_manipulation(){

## search on substrings in order to add/remove/edit strings in files using sed

sedFunction="${1}"
file="${2}"
searchString="${3}"
newValue="${4}"

if [[ "${os}" == "Mac" ]];then
  cmd=$(printf "%s" "/usr/local/bin/gsed -i")
else
  cmd=$(printf "%s" "sed -i")
fi

case "${1}" in
  "editAfterSubstring" )
      ${cmd} "s,\(${searchString}\s*\).*\$,\1${newValue}," "${file}" ;;
  "removeHashAndLeadingWhitespace" )
      ${cmd} "/${searchString}/s/^#\s*//" "${file}" ;;
  "editAfterSubstringPathFriendly" )
      ${cmd} "s,\(${searchString}\s*\).*\$,\1${newValue}," "${file}" ;;
  "searchFromLineStartAndRemoveEntireLine" )
      ${cmd} "/${searchString}/d" "${file}" ;;
  "searchAndReplaceLabelledBlock" )
      ${cmd} "/#BOF CLEAN-${searchString}/,/#EOF CLEAN-${searchString}/d" ${file} ;;
  "deleteEverythingAfterIncludingSubstring" )
      ${cmd} "/${searchString}/,$d" ${file} ;;
  "hashCommentOutMatchingLine" )    
      ${cmd} -e "/${searchString}/ s/^#*/#/" -i ${file} ;;     
esac
}

# ---------------------------------------

function generic_file_exists_check_abort(){

## check for the existence of a file - abort script if failure

file="${1}"
[[ ! -f ${file} ]] && \
printf "%s\n" && \
generic_msg_colour_simple "error" "Aborting script: ${yellow}${file}${red} - file not found" \
&& exit 1;
}

# ---------------------------------------

function generic_folder_exists_check_abort(){

## check for the existence of a file - abort script if failure

folder="${1}"
[[ ! -d ${folder} ]] && \
printf "%s\n" && \
generic_msg_colour_simple "error" "Aborting script: ${yellow}${folder}${red} - folder not found" \
&& exit 1;
}

# ---------------------------------------

function generic_add_trailing_slash(){

## add trailing slash if needed

STR="${1}"

length=${#STR}
last_char=${STR:length-1:1}

[[ $last_char != "/" ]] && STR="$STR/"; :

printf "%s" "$STR"
}

# ---------------------------------------

function generic_remove_trailing_slash(){

## remove trailing slash if needed

STR="${1}"

length=${#STR}
last_char=${STR:length-1:1}

[[ $last_char == "/" ]] && STR=${STR:0:length-1}; :

printf "%s" "$STR"
}

# ---------------------------------------

function generic_timecount(){
min=0
sec=${1}
message=${2}
echo "${2}"
while [ $min -ge 0 ]; do
      while [ $sec -ge 0 ]; do
          echo -ne "00:0$min:$sec\033[0K\r"
          sec=$((sec-1))
          sleep 1
      done
      sec=59
      min=$((min-1))
done
}
