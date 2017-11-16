#!/bin/bash

# author:        jondowson
# about:         flag handling for pod_SSH-AUTH

# ------------------------------------------

function handleFlags(){

flag=${1}
value=${2}

while test $# -gt 0; do
  case "$flag" in
    -s|--servers)
        SERVERS_JSON=$value
        serversFlag="true"
        break
        ;;
    -m|--mode)
        MODE=$value
        modeFlag="true"
        break
        ;;
    *)
      printf "%s\n"
      lib_generic_display_msgColourSimple "error" "Not a recognised flag ${yellow}${1}${red}"
      printf "%s\n"
      exit 1;
        ;;
  esac
done
}


function lib_generic_prepare_flagRules(){

## rules for accepting flags

# pre-canned formatted messages
defaultErrMsg="You must supply the correct combination of flags - please check the help: ${yellow}./launch-pod --help${red}"
servJsonErrMsg="You must supply a server .json definition file - please check the help: ${yellow}./launch-pod --help${red}"

case ${WHICH_POD} in

  "pod_SSH-AUTH" )
      # check flags and values for this mode of operation
      if [[ ${modeFlag} != "true" ]] || [[ ${serversFlag} != "true" ]]; then
        lib_generic_display_msgColourSimple "error" "${defaultErrMsg}" && exit 1;
      elif [[ ${MODE} == "" ]] || [[ ${MODE} != "test" ]] && [[ ${MODE} != "copy" ]]; then
        lib_generic_display_msgColourSimple "error" "You must supply a valid value for ${yellow}--mode${red} - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
      elif [[ ${SERVERS_JSON} == "" ]]; then
        lib_generic_display_msgColourSimple "error" "You must supply a value for ${yellow}--servers${red} - please check the help: ${yellow}./launch-pod --help${red}" && exit 1;
      fi ;;
  *)
      printf "%s\n" "${b}${red}error: You have specified an invalid pod: ${yellow}${WHICH_POD}${red} !! ${reset}" && exit 1 ;;
esac
}
