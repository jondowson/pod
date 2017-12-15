# author: jondowson
# about:  checks and error catching functions

# ---------------------------------------

function catchError(){  # short name allowed to break naming convention as it will be utilised heavily

##  catch return code of any command and if failure exit with code

# a helpful tag message outputted to screen
tagMsg=$1
# if unsuccessful choose whether to abort the script
abort=$2
# run the command and check its return code
${3} &> /dev/null
ret=$?

# usage example
# catchError "message" "true" "commandToRun"

if [[ $ret != 0 ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "Error: command failed: ${yellow}[ $3 ]${red} with return value: ${yellow}[ $ret ]${red} tag: ${yellow}[ ${tagMsg} ]${red}"
  if [[ ${abort}  == "true" ]]; then
    > ${pod_home_path}/misc/.suitcase
    rm -rf ${pod_home_path}/tmp
    exit $ret;
  fi
fi
}

# ---------------------------------------

function lib_generic_checks_fileExists(){

## check for the existence of a file - option to abort script if failure

# usage example
# lib_generic_checks_fileExists "message" "true" "fileToCheck.sh"

# a helpful tag message outputted to screen
tagMsg=$1
# if unsuccessfull choose whether to abort the script
abort=$2
# file to check for
file=${3}

if [[ ! -f ${file} ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "Error: file not found: ${yellow}[ ${file} ]${red} tag: ${yellow}[ ${tagMsg} ]${red}"
  if [[ "${abort}"  == "true" ]]; then
    > ${pod_home_path}/misc/.suitcase
    rm -rf ${pod_home_path}/tmp
    exit 1;
  fi
fi
}

# ---------------------------------------

function lib_generic_checks_folderExists(){

## check for the existence of a folder - option to abort script if failure

# usage example
# lib_generic_checks_folderExists "message" "true" "folderToCheck"

# a helpful tag message outputted to screen
tagMsg=$1
# if unsuccessfull choose whether to abort the script
abort=$2
# folder to check for
folder=${3}

if [[ ! -d ${folder} ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "Error: folder not found: ${yellow}[ ${folder} ]${red} tag: ${yellow}[ ${tagMsg} ]${red}"
  if [[ ${abort}  == "true" ]]; then
    > ${pod_home_path}/misc/.suitcase
    rm -rf ${pod_home_path}/tmp
    exit 1;
  fi
fi
}

# ---------------------------------------

function lib_generic_checks_folderExistsCaseSensitive(){

## check for the existence of a folder (case sensitive for Macs) - option to abort script if failure

# usage example
# lib_generic_checks_folderExistsCaseSensitive "message" "true" "parentFolderToCheckPath" "folderToCheck"

# a helpful tag message outputted to screen
tagMsg=$1
# if unsuccessfull choose whether to abort the script
abort=$2
# folder to list
listFolderPath=${3}
# folder to check-for
checkFolder=${4}

listFolder="${listFolderPath##*/}"

declare -a dirs
i=0
for f in ${listFolderPath}/*
do
    dirs[i++]="${f#*/${listFolder}/}"
done

notFound="true"
for((i=0;i<=${#dirs[@]};i++))
do
  if [[ "${checkFolder}" == "${dirs[i]}" ]]; then
    notFound="false"
    break;
  fi
done

if [[ "${notFound}" == "true" ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "Error: folder not found: ${yellow}[ ${checkFolder} ]${red} tag: ${yellow}[ ${tagMsg} ]${red}"
  if [[ "${abort}" == "true" ]]; then
    > ${pod_home_path}/misc/.suitcase
    rm -rf ${pod_home_path}/tmp
    exit 1;
  fi
fi
}

# ---------------------------------------

function lib_generic_checks_localIpMatch(){

## check if an ip is a local ip
ipToCheck=${1}
ip addr | grep -wq "${ipToCheck}" &&  printf "%s" "true"
}

# ---------------------------------------

function lib_generic_checks_noOfServers(){

noOfServers="${1}"
tagMsg="${2}"

## check if an ip is a local ip
if [[ "$noOfServers" -eq 0 ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "Error: number of servers is empty: ${yellow}[ ${noOfServers} ]${red} tag: ${yellow}[ ${tagMsg} ]${red}"
  > ${pod_home_path}/misc/.suitcase
  rm -rf ${pod_home_path}/tmp
  exit 1;
fi
}
