function GENERIC_lib_strings_ifsStringDelimeter(){

## split a string by any number of delimiters and insert into an array

# then in calling function access split elements in the array
# for whatever in "${array[@]}"
# do
#  echo ${!whatever}
# done

delim=$1;
string=$2;

IFS=${delim} read -r -a array <<< "${string}";
unset IFS;
arraySize=${#array[@]};
};

# ---------------------------------------

function GENERIC_lib_strings_expansionDelimiter(){

## split a string by delimeter (limited to 2 delimiters !)
## e.g. pod_strings_expansionDelimiter "this;that;other" ";" "2"
##      ---> _D1_="this" and _D2_="that" and _D3_="other"

string=${1};
delim=${2};
noOfDelims=${3};

if [[ "${noOfDelims}" == "1" ]]; then
  _D1_=${string%;*};
  _D2_=${string#*;};
elif [[ "${noOfDelims}" == "2" ]]; then
  _D1_=${string%%${delim}*};
  _D3_=${string##*${delim}};
  _a_=${string#*;};
  _D2_=${_a_%${delim}*};
else
  GENERIC_prepare_display_msgColourSimple "ERROR-->" "functions.sh | pod_strings_expansionDelimiter --> 'Unsupported no. of delimeted values'";
  exit 1;
fi;
};

# ---------------------------------------

function GENERIC_lib_strings_sedStringManipulation(){

## search on substrings in order to add/remove/edit strings in files using sed

sedFunction="${1}";
file="${2}";
searchString="${3}";
newValue="${4}";

if [[ "${os}" == "Mac" ]];then
  cmd=$(printf "%s" "/usr/local/bin/gsed -i");
else
  cmd=$(printf "%s" "sed -i");
fi;

case "${1}" in
  "editAfterSubstring" )
      ${cmd} "s,\(${searchString}\s*\).*\$,\1${newValue}," "${file}" ;;
  "removeHashAndLeadingWhitespace" )
      ${cmd} "/${searchString}/s/^#\s*//" "${file}" ;;
  "editAfterSubstringPathFriendly" )
      ${cmd} "s,\(${searchString}\s*\).*\$,\1${newValue}," "${file}" ;;
  "searchFromLineStartAndRemoveEntireLine" )
      ${cmd} "/${searchString}/d" "${file}" ;;
  "searchAndReplaceLabelledBlock" )  # remove all blocks for a given pod and label e.g. a particular block within a configuration file
      ${cmd} "/#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${searchString}/,/#>>>>>END-ADDED-BY__${WHICH_POD}@${searchString}/d" ${file} ;;
  "searchAndReplaceLabelledBlock2" ) # remove all blocks for a given pod e.g. all entries in bash_profile
      ${cmd} "/#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@/,/#>>>>>END-ADDED-BY__${WHICH_POD}@/d" ${file} ;;
  "deleteEverythingAfterIncludingSubstring" )
      ${cmd} "/${searchString}/,$d" ${file} ;;
  "hashCommentOutMatchingLine" )
      ${cmd} -e "/${searchString}/ s/^#*/#/" -i ${file} ;;
  "searchAndReplaceStringGlobal" )
      ${cmd} -e "s,${searchString},${newValue},g" -i ${file} ;;
  "searchSubstringAndRemoveEverythingAfterOnLine" )
      ${cmd} -e "s,${searchString}.*,${newValue}," -i ${file} ;;
  "removeLastLineFromFile" )
      ${cmd} "$ d" ${file} ;;
esac;
};

# ---------------------------------------

function GENERIC_lib_strings_removePodBlockAndEmptyLines(){

## cleanly remove an existing pod insertion block, leaving no following blank line gaps
## usage:
## GENERIC_lib_strings_removePodBlockAndEmptyLines "thisFile" "pod_XYZ@<label>"

# file to search and the pod block label
file="${1}";
blockLabel="${2}";

# define block to remove from file
beginBlockTag="#>>>>>BEGIN-ADDED-BY__${blockLabel}";
endBlockTag="#>>>>>END-ADDED-BY__${blockLabel}";

# remove any empty blank lines at end of file
a=$(<$file); printf "%s\n" "$a" > $file;

# find line numbers of begin and end of block
beginMatch=$(sed -n /"${beginBlockTag}"/= "${file}");
endMatch=$(sed -n /"${endBlockTag}"/= "${file}");

# if the block already exists - determine its position and also delete any blank lines following it (leave one blank line if any exist)
if [[ ${beginMatch} != "" ]] && [[ ${endMatch} != "" ]]; then

  # identify continous blank lines after inserted block and delete all but one
  start=$(($endMatch+1));
  finish=$(($start+20));    # unlikely to be close to 20 blank lines but increase number if necessary !!

  for i in `seq $start $finish`
  do
    # search following lines until a non empty line is found
    if [[ ! $(sed "${i}q;d" "${file}") == "" ]]; then

      if [[ "${i}" == "${start}" ]]; then
        lastEntry=${endMatch};
      else
        lastEntry=$(($i-1));
      fi
      break;
    else
      lastEntry=${endMatch};
    fi;
  done;

  IFS='%';
  dynamic_cmd="$(GENERIC_lib_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')";
  unset IFS;

  # delete any existing block and unneccessary empty lines
  ${dynamic_cmd} "${beginMatch},${lastEntry}d" ${file};

  # remove any empty blank lines at end of file
  a=$(<$file); printf "%s\n" "$a" > $file;
fi;
};

# ---------------------------------------

function GENERIC_lib_strings_addTrailingSlash(){

## add trailing slash if needed

STR="${1}";

length=${#STR};
last_char=${STR:length-1:1};

[[ $last_char != "/" ]] && STR="$STR/";

printf "%s" "$STR";
};

# ---------------------------------------

function GENERIC_lib_strings_removeTrailingSlash(){

## remove trailing slash if needed

STR="${1}";

length=${#STR};
last_char=${STR:length-1:1};

[[ $last_char == "/" ]] && STR=${STR:0:length-1};

printf "%s" "$STR";
};
