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
