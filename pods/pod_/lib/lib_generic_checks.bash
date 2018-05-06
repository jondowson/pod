# about:  variety of checks and error handling functions

# ---------------------------------------

function catchError(){  # short name allowed to break naming convention as it will be utilised heavily

## catch return code of any command and if failure exit with code
## usage:
## catchError "launch-pod#1" "json parsing error" "true" "true" "jq server.json"

# tag to identify calling script
callingScriptTag=${1}
# a helpful tag message outputted to screen
tagMsg=${2}
# if unsuccessful choose whether to abort the script
abort=${3}
# set to true to suppress output of command
quiet=${4}
# command to test
command=${5}

# run the command and check its return code
if [[ ${quiet} == "true" ]]; then
  ${command} &> /dev/null
else
  ${command}
fi
ret=$?
if [[ $ret != 0 ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "Error: ${tagMsg} with return value: [ ${ret} ] ${yellow}[ ${callingScriptTag} ]"
  if [[ ${abort}  == "true" ]]; then
    prepare_generic_misc_clearTheDecks
    exit ${ret};
  fi
fi
}

# ---------------------------------------

function lib_generic_checks_freeTest(){

## generic function to test two values against each other
## usage:
## lib_generic_checks_freeTest "launch-pod#5.2.1" "zero number of servers" "$numberOfServers" "-eq" "0"

# tag to identify calling script
callingScriptTag=${1}
# a helpful tag message outputted to screen
tagMsg=${2}
# test to run
value="$3"
test="$4"
testAgainst="$5"

# ensure there are more than 0 servers
if [ $value $test $testAgainst ]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "Error: ${tagMsg}: ${yellow}[ ${callingScriptTag} ]"
  prepare_generic_misc_clearTheDecks
  exit 1;
fi
}

# ---------------------------------------

function lib_generic_checks_fileExists(){

## check for the existence of a file - option to abort script if failure
## usage:
## lib_generic_checks_fileExists "message" "true" "fileToCheck.sh"

# a helpful tag message outputted to screen
tagMsg=$1
# if unsuccessfull choose whether to abort the script
abort=$2
# file to check for
file=${3}

if [[ ! -f ${file} ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "Error: file not found: ${yellow}[ ${file} ]${red} tag: ${yellow}[ ${tagMsg} ]${red}"
  if [[ "${abort}"  == "true" ]]; then
    prepare_generic_misc_clearTheDecks
    exit 1;
  fi
fi
}

# ---------------------------------------

function lib_generic_checks_folderExists(){

## check for the existence of a folder - option to abort script if failure
## usage:
## lib_generic_checks_folderExists "message" "true" "folderToCheck"

# a helpful tag message outputted to screen
tagMsg=$1
# if unsuccessfull choose whether to abort the script
abort=$2
# folder to check for
folder=${3}

if [[ ! -d ${folder} ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "Error: folder not found: ${yellow}[ ${folder} ]${red} tag: ${yellow}[ ${tagMsg} ]${red}"
  if [[ ${abort}  == "true" ]]; then
    prepare_generic_misc_clearTheDecks
    exit 1;
  fi
fi
}

# ---------------------------------------

function lib_generic_checks_fileFolderExists(){

## check for the existence of a file or folder for a given folder path
## case sensitive approach required as Macs ignore case when listing folders/files
## returns code 0 if file/folder found or error message
## usage:
## lib_generic_checks_folderExistsCaseSensitive "message" "true" "pathToParentFolder" "folder" "file/folderTCheck"
## lib_generic_checks_folderExistsCaseSensitive "message" "false" "pathToParentFolder" "file" "file/folderTCheck"

# a helpful tag message outputted to screen
tagMsg=${1}
# if unsuccessful choose whether to abort the script: 'true' or 'false'
abort=${2}
# full path to folder to search on: /path/to/file or path/to/folder/
listPath=${3}
# is this a folder or a file: 'file' or 'folder'
fileOrFolder=${4}
# the folder/file to check-for: e.g 'myfile.txt' or 'folderX'
checkThis=${5}

# -----

listFolder="${listPath##*/}"
declare -a checks
i=0
for f in ${listPath}/*
do
  checks[i++]="${f#*/${listFolder}/}"
done

# -----

notFound="true"
for((i=0;i<${#checks[@]};i++))
do
  if [[ "${checkThis}" == "${checks[i]}" ]]; then
    if [[ -d "${listPath}/${checkThis}" ]] && [[ $fileOrFolder == "folder" ]]; then
      fileOrFolder="folder" && notFound="false"
      break;
    elif [[ -f "${listPath}/${checkThis}" ]] && [[ $fileOrFolder == "file" ]]; then
      fileOrFolder="file" && notFound="false"
      break;
    fi
  fi
done

# -----

if [[ "${notFound}" != "false" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "Error: not found: ${yellow}[ '${checkThis}' ]${red} tag: ${yellow}[ ${tagMsg} ]${red}"
  if [[ "${abort}" == "true" ]]; then
    prepare_generic_misc_clearTheDecks
    exit 1;
  fi
fi
}

# ---------------------------------------

function lib_generic_checks_localIpMatch(){

## check if an ip is a local ip
## usage:
## lib_generic_checks_localIpMatch "${pub_ip}"s

ipToCheck=${1}
ip addr | grep -wq "${ipToCheck}" &&  printf "%s\n" "true"
}
