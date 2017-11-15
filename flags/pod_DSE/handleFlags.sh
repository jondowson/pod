#!/bin/bash

# author:        jondowson
# about:         flag handling for pod_DSE

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
    -b|--build)
        BUILD_FOLDER=$value
        buildFlag="true"
        break
        ;;
    -ss|--sendsoft)
        SEND_DSE_SOFTWARE=$value
        sendsoftFlag="true"
        break
        ;;
    -rr|--regenresources)
        REGENERATE_RESOURCES=$value
        regenresourcesFlag="true"
        break
        ;;
    -cs|--clusterstate)
        CLUSTER_STATE=$value
        clusterstateFlag="true"
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