#!/bin/bash

# author: jondowson
# about: generic bash string manipulation functions

# ---------------------------------------

function pod_generic_strings_ifsStringDelimeter(){

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

function pod_generic_strings_expansionDelimiter(){

## split a string by delimeter
# e.g. pod_generic_strings_expansionDelimiter "this;that;other" ";" "2"
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
  pod_generic_display_msgColourSimple "error" "functions_generic.sh | pod_generic_strings_expansionDelimiter --> 'Unsupported no. of delimeted values'"
  exit 1;
fi
}

# ---------------------------------------

function pod_generic_strings_sedStringManipulation(){

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
  "searchAndReplaceStringGlobal" )
      ${cmd} -e "s,${searchString},${newValue},g" -i ${file} ;;
esac
}

# ---------------------------------------

function pod_generic_strings_addTrailingSlash(){

## add trailing slash if needed

STR="${1}"

length=${#STR}
last_char=${STR:length-1:1}

[[ $last_char != "/" ]] && STR="$STR/"; :

printf "%s" "$STR"
}

# ---------------------------------------

function pod_generic_strings_removeTrailingSlash(){

## remove trailing slash if needed

STR="${1}"

length=${#STR}
last_char=${STR:length-1:1}

[[ $last_char == "/" ]] && STR=${STR:0:length-1}; :

printf "%s" "$STR"
}
