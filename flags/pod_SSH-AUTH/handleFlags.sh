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
