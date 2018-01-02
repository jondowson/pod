#!/bin/bash

# author:        jondowson
# about:         help on pod_JAVA usage and flags

# ------------------------------------------

function lib_help(){

lib_generic_display_msgColourSimple "TASK==>" "pod_JAVA flags:"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   ".. scp POD_SOFTWARE folder to servers    | -ss --sendsoft         |  false [true]     |   no"
printf "%s\n"
printf "%s\n"   "${b}example:${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${yellow}$ ./launch-pod -p pod_JAVA -s myServers.json -b oracle-jre1.8.152_practice -ss false ${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}
