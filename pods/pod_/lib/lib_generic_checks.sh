#!/bin/bash

# author: jondowson
# about:  checks and error catching functions

# ---------------------------------------

function catchError(){  # short name allowed to break naming convention as it will be utilised heavily 
 
##  catch return code of any command and if failure exit with code

# a helpful tag message outputted to screen 
tagMsg=$1
# if unsuccessfull choose whether to abort the script
abort=$2
# run the command and check its return code
$3 
ret=$?

if [[ $ret != 0 ]]; then
  lib_generic_display_msgColourSimple "ERROR-->" "Error: command failed: ${yellow}[ $3 ]${red} with return value: ${yellow}[ $ret ]${red} tag: ${yellow}[ ${tagMsg} ]${red}" 
  exit $ret
fi
}

# ---------------------------------------

function lib_generic_checks_fileExists(){

## check for the existence of a file - option to abort script if failure

# a helpful tag message outputted to screen 
tagMsg=$1
# if unsuccessfull choose whether to abort the script
abort=$2
# file to check for
file="${3}"

if [[ ! -f ${file} ]]; then
  lib_generic_display_msgColourSimple "ERROR" "Error: file not found: ${yellow}[ ${file} ]${red} tag: ${yellow}[ ${tagMsg} ]${red}" 
  if [[ ${abort}  == "true" ]]; then
    exit 1;
  fi 
fi
}

# ---------------------------------------

function lib_generic_checks_folderExists(){

## check for the existence of a file - option to abort script if failure

# a helpful tag message outputted to screen 
tagMsg=$1
# if unsuccessfull choose whether to abort the script
abort=$2
# file to check for
file="${3}"

if [[ ! -d ${folder} ]]; then
  lib_generic_display_msgColourSimple "ERROR" "Error: file not found: ${yellow}[ ${folder} ]${red} tag: ${yellow}[ ${tagMsg} ]${red}" 
  if [[ ${abort}  == "true" ]]; then
    exit 1;
  fi 
fi
}
