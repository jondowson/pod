function GENERIC_lib_json_writeTest(){
checkValue=${1};
status="999";
if [[ "${status}" != "0" ]]; then
  retry=0;
  until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
  do
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${checkValue}";
    ssh -q -o ForwardX11=no -i ${ssh_key} ${user}@${pub_ip} "mkdir -p ${checkValue}dummyFolder && rm -rf ${checkValue}dummyFolder" exit;
    status=${?};
    arrayTestWrite2["${checkValue}"]="${status};${tag}";
    ((retry++));
  done;
fi;
};
# ---------------------------------------
function GENERIC_lib_json_writeTestArray(){
arrayJsonValues="$(jq -r '.server_'${id}'.'$key'[]' ${serversJsonPath})";
for checkValue in $arrayJsonValues
do
  checkValue=$(echo "${checkValue}" | sed "s@\${BUILD_FOLDER}@${BUILD_FOLDER}@g" | sed "s@\${target_folder}@${target_folder}@g" | sed "s@\${WHICH_POD}@${WHICH_POD}@g" | sed "s@\${SERVERS_JSON}@${SERVERS_JSON}@g" 2>/dev/null);
  # check if nested path is itself a delimited string
  GENERIC_lib_strings_ifsStringDelimeter "${delim}" "${checkValue}";
  if [[ ${arraySize} -gt "1" ]]; then
    checkValue=${array[0]} # grab the path which should be the first part of the delimited string
  fi
  GENERIC_lib_json_writeTest "${checkValue}";
done
};
# ---------------------------------------
function GENERIC_lib_json_writeTestObject(){
arrayObjectPaths=$(jq -r '.server_'${id}'.'${parentElement}' | keys[]' ${serversJsonPath});
for nestedElement in $arrayObjectPaths
do
  checkType=$(jq -r '.server_'${id}'.'${parentElement}'.'${nestedElement}'.'${childElement}' | type' ${serversJsonPath} 2>/dev/null);
  if [[ ${checkType} == "array" ]];then
    GENERIC_lib_json_writeTestArray "${parentElement}.${nestedElement}.${childElement}";
  else
    checkValue=$(jq -r '.server_'${id}'.'${parentElement}'.'${nestedElement}'.'${childElement} ${serversJsonPath});
    checkValue=$(echo "${checkValue}" | sed "s@\${BUILD_FOLDER}@${BUILD_FOLDER}@g" | sed "s@\${target_folder}@${target_folder}@g" | sed "s@\${WHICH_POD}@${WHICH_POD}@g" | sed "s@\${SERVERS_JSON}@${SERVERS_JSON}@g");
    GENERIC_lib_json_writeTest "${checkValue}";
  fi;
done;
};
# ---------------------------------------
function GENERIC_lib_json_writePathTest(){
# [1] the json key with the path(s) to test - defined in build_settings.bash as JSONPATHS_WRITETEST
delim=${1};
key=${2};
# [2] test json key for its type and whether it is empty
checkType=$(jq -r '.server_'${id}'.'$key' | type' ${serversJsonPath} 2>/dev/null);
checkValue=$(jq -r '.server_'${id}'.'$key ${serversJsonPath} 2>/dev/null);
# [3] replace any of the 'accepted' variables that may be embeded in the string
checkValue=$(echo "${checkValue}" | sed "s@\${BUILD_FOLDER}@${BUILD_FOLDER}@g" | sed "s@\${target_folder}@${target_folder}@g" | sed "s@\${WHICH_POD}@${WHICH_POD}@g" | sed "s@\${SERVERS_JSON}@${SERVERS_JSON}@g");
# [4.1] if a key value pair

if [[ ${checkType} == "string" ]];then
  GENERIC_lib_json_writeTest "${checkValue}";
# [4.2] if an array (list), extract each member
elif [[ ${checkType} == "array" ]];then
  GENERIC_lib_json_writeTestArray;
# [4.3] if an object, determine number of nested key elements and for each extract the path to test
else
    # identify preceeding and following strings to wildcard that represents every nested element
    parentElement=$(echo $key | sed "s/\..*//");
    childElement=$(echo $key  | sed "s/.*\.//");
    checkType=$(jq -r '.server_'${id}'.'${parentElement}' | type' ${serversJsonPath} 2>/dev/null);
    if [[ ${checkType} == "object" ]];then
      GENERIC_lib_json_writeTestObject;
    else
      arrayTestWrite["${key}"]="1;Bad entry for JSONPATHS_WRITETEST in build_settings.sh";
    fi;
fi;
};


# ---------------------------------------

function GENERIC_lib_json_assignValueold(){

## loop through json server block and create a bash variable (same name as json key) and assign its value to it
# values are stored in an associative array and this is then expanded in the calling script to make variables globally available
## this function allows nested json objects to a depth of four - e.g. c1.2.3.x below //TODO make recursive?

# {
#  "server_1":{
#    "a1":  "value",
#    "b1": "value",
#    "c1": {
#      "c1.1": {
#        "c1.1.1": "value",
#        "c1.1.2": "value"
#        "c1.2.3": {
#          "c1.2.3.1" : "value",
#          "c1.2.3.2" : "value"
#       }
#      }
#    }
#  }
# }

# -----

# dynamically select the correct command for the OS
IFS='%';
dynamic_cmd="$(GENERIC_lib_misc_chooseOsCommand 'gsed -r' 'sed -r' 'sed -r' 'sed -r')";
unset IFS;

# -----
# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${serversJsonPath})
for k in $keys
do
  # declare a variable of the same name and assign its value to it
  arrayJson[$k]="$(jq -r '.server_'${id}'.'$k ${serversJsonPath})";

  # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
  nestedCheck=$(jq -r '.server_'${id}'.'$k' | paths' ${serversJsonPath});
  if [[ $nestedCheck != *[0]* ]] && [[ $nestedCheck != "" ]]; then

    # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
    nestedKeys=$(echo $nestedCheck | tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//');
    nestedKeys=$(echo $nestedKeys  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//');

    # for each level two key
    for nk in $nestedKeys
    do
      # declare a variable of the same name and assign its value to it - using underscore between nested levels for variable name
      arrayJson[$k$u$nk]="$(jq -r '.server_'${id}'.'$k'.'$nk ${serversJsonPath})";

      # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
      nestedCheckTwo=$(jq -r '.server_'${id}'.'$k'.'$nk' | paths' ${serversJsonPath});
      if [[ $nestedCheckTwo != *[0]* ]] && [[ $nestedCheckTwo != "" ]]; then

        # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
        nestedKeysTwo=$(echo $nestedCheckTwo |  tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//');
        nestedKeysTwo=$(echo $nestedKeysTwo  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//');

        # for each level three key
        for nnk in $nestedKeysTwo
        do
          # declare a variable of the same name and assign its value to it - using underscore between nested levels for variable name
          arrayJson[$k$u$nk$u$nnk]="$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk ${serversJsonPath})";
          # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
          nestedCheckThree=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk' | paths' ${serversJsonPath});
          if [[ $nestedCheckThree != *[0]* ]] && [[ $nestedCheckThree != "" ]]; then

            # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
            nestedKeysThree=$(echo $nestedCheckThree |  tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//');
            nestedKeysThree=$(echo $nestedKeysThree  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//');

            # for each level four key
            for nnnk in $nestedKeysThree
            do
              arrayJson[$k$u$nk$u$nnk$u$nnnk]="$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'.'$nnnk ${serversJsonPath})";
            done;
          fi;
        done;
      fi;
    done;
  fi;
done;
};
function GENERIC_lib_json_assignValue(){
## loop through json server block and create a bash variable (same name as json key) and assign its value to it
## values are stored in an associative array and this is then expanded in the calling script to make variables globally available
## this function allows nested json objects to a depth of four - e.g. c1.2.3.x below //TODO make recursive?
# {
#  "server_1":{
#    "a1":  "value",
#    "b1": "value",
#    "c1": {
#      "c1.1": {
#        "c1.1.1": "value",
#        "c1.1.2": "value"
#        "c1.2.3": {
#          "c1.2.3.1" : "value",
#          "c1.2.3.2" : "value"
#       }
#      }
#    }
#  }
# }
# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${serversJsonPath})

### [level 0 keys]
for k in $keys
do
  # check if key has nested key value pairs - ignore if it is empty
  nestedCheck=$(jq -r '.server_'${id}'.'$k' | paths[]' ${serversJsonPath} 2>/dev/null);
  valueCheck=$(jq -r '.server_'${id}'.'$k ${serversJsonPath} 2>/dev/null);
  valueCheckArray=$(printf "${valueCheck//[[:space:]]/}")
  typeCheck=$(jq -r '.server_'${id}'.'$k' | type' ${serversJsonPath} 2>/dev/null);
  typeCheckStatus=$?
  if [[ ${nestedCheck} == "" ]] && [[ ${valueCheck} != "null" ]] && [[ ${valueCheck} != "" ]] && [[ ${typeCheck} != "array" ]] && [[ ${typeCheckStatus} == "0" ]]; then
    arrayJson[$k]="$(jq -r '.server_'${id}'.'$k ${serversJsonPath})";
  # if list assign all comma separated items to one bash variable
  elif [[ ${typeCheck} == "array" ]] && [[ ${valueCheckArray} != "[]" ]] && [[ ${valueCheckArray} != "null" ]];then
    arrayJsonValues="$(jq -r '.server_'${id}'.'$k'[]' ${serversJsonPath})";
    arrayJsonValues=$(echo ${arrayJsonValues} | sed 's/ /,/g')
    arrayJson[$k]="${arrayJsonValues}";
  else
    nestedKeys=$(echo "${nestedCheck[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ');
####### [level 1 keys]
    for nk in $nestedKeys
    do
      nestedCheckTwo=$(jq -r '.server_'${id}'.'$k'.'$nk' | paths[]' ${serversJsonPath} 2>/dev/null);
      valueCheck=$(jq -r '.server_'${id}'.'$k'.'$nk ${serversJsonPath} 2>/dev/null);
      valueCheckArray=$(printf "${valueCheck//[[:space:]]/}")
      typeCheck=$(jq -r '.server_'${id}'.'$k'.'$nk' | type' ${serversJsonPath} 2>/dev/null);
      typeCheckStatus=$?
      if [[ ${nestedCheckTwo} == "" ]] && [[ ${valueCheck} != "null" ]] && [[ ${valueCheck} != "" ]] && [[ ${typeCheck} != "array" ]] && [[ ${typeCheckStatus} == "0" ]]; then
        arrayJson[$k$u$nk]="$(jq -r '.server_'${id}'.'$k'.'$nk ${serversJsonPath})";
      elif [[ ${typeCheck} == "array" ]] && [[ ${valueCheckArray} != "[]" ]] && [[ ${valueCheckArray} != "null" ]];then
        arrayJsonValues[$k$u$nk]="$(jq -r '.server_'${id}'.'$k'.'$nk'[]' ${serversJsonPath})";
        arrayJsonValues=$(echo ${arrayJsonValues} | sed 's/ /,/g')
        arrayJson[$k$u$nk]="${arrayJsonValues}";
      else
        nestedKeysTwo=$(echo "${nestedCheckTwo[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ');
########### [level 2 keys]
        for nnk in $nestedKeysTwo
        do
          nestedCheckThree=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk' | paths[]' ${serversJsonPath} 2>/dev/null);
          valueCheck=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk ${serversJsonPath} 2>/dev/null);
          valueCheckArray=$(printf "${valueCheck//[[:space:]]/}")
          typeCheck=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk' | type' ${serversJsonPath} 2>/dev/null);
          typeCheckStatus=$?
          if [[ ${nestedCheckThree} == "" ]] && [[ ${valueCheck} != "null" ]] && [[ ${valueCheck} != "[]" ]] && [[ ${typeCheck} != "array" ]] && [[ ${typeCheckStatus} == "0" ]]; then
            arrayJson[$k$u$nk$u$nnk]="$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk ${serversJsonPath} 2>/dev/null)";
          elif [[ ${typeCheck} == "array" ]] && [[ ${valueCheckArray} != "[]" ]] && [[ ${valueCheckArray} != "null" ]];then
            arrayJsonValues[$k$u$nk$u$nnk]="$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'[]' ${serversJsonPath})";
            arrayJsonValues=$(echo ${arrayJsonValues} | sed 's/ /,/g')
            arrayJson[$k$u$nk$u$nnk]="${arrayJsonValues}";
          else
            nestedKeysThree=$(echo "${nestedCheckThree[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ');
############### [level 3 keys]
            for nnnk in $nestedKeysThree
            do
              nestedCheckFour=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'.'$nnnk' | paths[]' ${serversJsonPath} 2>/dev/null);
              valueCheck=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'.'$nnnk ${serversJsonPath} 2>/dev/null);
              valueCheckArray=$(printf "${valueCheck//[[:space:]]/}")
              typeCheck=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'.'$nnnk' | type' ${serversJsonPath} 2>/dev/null);
              typeCheckStatus=$?
              if [[ ${nestedCheckFour} == "" ]] && [[ ${valueCheck} != "null" ]] && [[ ${valueCheck} != "" ]] && [[ ${typeCheck} != "array" ]] && [[ ${typeCheckStatus} == "0" ]]; then
                  arrayJson[$k$u$nk$u$nnk$u$nnnk]="$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'.'$nnnk ${serversJsonPath} 2>/dev/null)";
              elif [[ ${typeCheck} == "array" ]] && [[ ${valueCheckArray} != "[]" ]] && [[ ${valueCheckArray} != "null" ]];then
                arrayJsonValues[$k$u$nk$u$nnk$u$nnnk]="$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'.'$nnnk'[]' ${serversJsonPath})";
                arrayJsonValues=$(echo ${arrayJsonValues} | sed 's/ /,/g')
                arrayJson[$k$u$nk$u$nnk$u$nnnk]="${arrayJsonValues}";
              fi
            done;
          fi;
        done;
      fi;
    done;
  fi;
done;
};
