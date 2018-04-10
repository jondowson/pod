# about:  json processing functions

# ---------------------------------------

function lib_generic_json_writePathTest(){

## for a given element in a json block, grab its paths and write a dummy test folder
## if path is itself part of a mixed delimted string, then grab the path portion of the string
## e.g. "/path/to/here;10;100"

# the json element to find
delim="${1}"
element="${2}"

# if path contains ${BUILD_FOLDER} variable then substitute in the user supplied value
folders=$(jq -r --arg bf "${BUILD_FOLDER}" '.server_'${id}'.'${element}'[] | sub("\\${BUILD_FOLDER}";$bf)' "${servers_json_path}")
# for each path nested within this element
for folder in ${folders}
do
  # check if nested path is itself a delimited string
  lib_generic_strings_ifsStringDelimeter "${delim}" "$folder"
  if [[ ${arraySize} -gt "1" ]]; then
    path=${array[0]} # grab the path which should be the first part of the delimited string
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "mkdir -p ${path}dummyFolder && rm -rf ${path}dummyFolder" exit
        status=${?}
        test_write_error_array_2[${path}]="${status};${tag}"
        ((retry++))
      done
    fi
  else
    status="999"
    if [[ "${status}" != "0" ]]; then
      retry=0
      until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
      do
        ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "mkdir -p ${folder}dummyFolder && rm -rf ${folder}dummyFolder" exit
        status=${?}
        test_write_error_array_2[${folder}]="${status};${tag}"
        ((retry++))
      done
    fi
  fi
done
}

# ---------------------------------------

function lib_generic_jason_assignValues(){

## loop through json server block and create a bash variable (same name as json key) and assign its value to it
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
IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -r' 'sed -r' 'sed -r' 'sed -r')"
unset IFS

# -----

# for each level one key
for k in $keys
do
  # declare a variable of the same name and assign its value to it
  declare "$k=$(jq -r '.server_'${id}'.'$k ${servers_json_path})"

  # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
  nestedCheck=$(jq -r '.server_'${id}'.'$k' | paths' ${servers_json_path})
  if [[ $nestedCheck != *[0]* ]] && [[ $nestedCheck != "" ]]; then

    # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
    nestedKeys=$(echo $nestedCheck | tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    nestedKeys=$(echo $nestedKeys  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

    # for each level two key
    for nk in $nestedKeys
    do
      # declare a variable of the same name and assign its value to it - using underscore between nested levels for variable name
      declare "$k$u$nk=$(jq -r '.server_'${id}'.'$k'.'$nk ${servers_json_path})"

      # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
      nestedCheckTwo=$(jq -r '.server_'${id}'.'$k'.'$nk' | paths' ${servers_json_path})
      if [[ $nestedCheckTwo != *[0]* ]] && [[ $nestedCheckTwo != "" ]]; then

        # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
        nestedKeysTwo=$(echo $nestedCheckTwo |  tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        nestedKeysTwo=$(echo $nestedKeysTwo  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} -r ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

        # for each level three key
        for nnk in $nestedKeysTwo
        do
          # declare a variable of the same name and assign its value to it - using underscore between nested levels for variable name
          declare "$k$u$nk$u$nnk=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk ${servers_json_path})"

          # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
          nestedCheckThree=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk' | paths' ${servers_json_path})
          if [[ $nestedCheckThree != *[0]* ]] && [[ $nestedCheckThree != "" ]]; then

            # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
            nestedKeysThree=$(echo $nestedCheckThree |  tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            nestedKeysThree=$(echo $nestedKeysThree  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} -r ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

            # for each level four key
            for nnnk in $nestedKeysThree
            do
              declare "$k$u$nk$u$nnk$u$nnnk=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'.'$nnnk ${servers_json_path})"
            done
          fi
        done
      fi
    done
  fi
done

## add trailing '/' to target_folder path if not present
target_folder="$(lib_generic_strings_addTrailingSlash ${target_folder})"
}
