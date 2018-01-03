#!/bin/bash

# author:        jondowson
# about:         flag handling for pod_DSE

# ------------------------------------------

function prepare_handleFlags(){

flag=${1}
value=${2}

while test $# -gt 0; do
  case "$flag" in
    -s|--servers)
        SERVERS_JSON=$value
        serversFlag="true"
        break
        ;;
    -b|--build)
        BUILD_FOLDER=$value
        buildFlag="true"
        break
        ;;
    -rp|--removepod)
        REMOVE_POD=$value
        removepodFlag="true"
        break
        ;;
    *)
      printf "%s\n"
      lib_generic_display_msgColourSimple "ERROR-->" "Not a recognised flag ${yellow}${1}${red}"
      exit 1;
        ;;
  esac
done
}
