#!/bin/bash

# author:        jondowson
# about:         help on pod usage and flags

# ------------------------------------------

function lib_generic_help(){

lib_generic_display_msgColourSimple "STAGE" "pod_HELP:"
printf "%s\n"
printf "%s%s%s\n" "${b}" "description                              | flag(s)                | values[default]   | required?  " "${reset}"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${b}${cyan}==> pod flags:${reset}"
printf "%s\n"     ".. specify pod to run                    | -p  --pod              |  <pod_NAME>       |   always"
printf "%s\n"     ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   always"
printf "%s\n"     ".. this help                             | -h  --help             |      no           |     n/a"
printf "%s\n"     ".. specific pod help                     | -p  -h                 |  <pod_NAME>       |     no"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
printf "%s\n"     "${b}examples:${reset}"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
printf "%s\n"     "${yellow}$ ./launch-pod -h${reset}"
printf "%s\n"     "${yellow}$ ./launch-pod -p pod_NAME -h${reset}"
printf "%s\n"     "${yellow}$ ./launch-pod -p pod_NAME --servers myServers.json${reset}"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
}

# ------------------------------------------

function lib_generic_helpFinish(){

if [[ "${podFlag}" != "true" ]]; then

  lib_generic_display_msgColourSimple "TASK==>" "Available pods:"
  availablePods=$(ls ${pod_home_path}/pods | cut -f 2 -d '_' | grep -v 'pod_')
  printf "%s\n" ${availablePods}

else

  lib_generic_display_msgColourSimple "TASK==>" "Available ${WHICH_POD} servers:"
  availableServers=$(ls ${pod_home_path}/servers | grep 'DSE_*')
  printf "%s\n" ${availableServers}

fi
printf "%s\n"
}
