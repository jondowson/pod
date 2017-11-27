#!/bin/bash

# author:        jondowson
# about:         help on pod_DSE usage and flags

# ------------------------------------------

function lib_help(){

printf "%s\n"   "${b}${cyan}==> pod_DSE flags:${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   ".. scp POD_SOFTWARE folder to servers    | -ss --sendsoft         |  false [true]     |   no"
printf "%s\n"   ".. re-generate build resources folder    | -rr --regenresources   |  true  [false]    |   no"
printf "%s\n"   ".. rolling stop/start of cluster         | -cs --clusterstate     |  start stop       | on-its-own" 
printf "%s\n"
printf "%s\n"   "${b}examples:${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${yellow}$ ./launch-pod -p pod_DSE -s myServers.json -b dse-5.0.5_pre-prod -ss false --rr true${reset}"
printf "%s\n"   "${yellow}$ ./launch-pod -p pod_DSE -s myServers.json --clusterstate start${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
lib_generic_display_msgColourSimple "TASK" "Available ${WHICH_POD} builds:"
availableServers=$(ls ${pod_home_path}/pods/${WHICH_POD}/builds)
printf "%s\n" ${availableServers}
}
