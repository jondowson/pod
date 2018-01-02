# author:        jondowson
# about:         help on pod usage and flags

# ------------------------------------------

function lib_generic_help(){

printf "%s%s\n" "${b}description                              | flag(s)                | values[default]   | required?  " "${reset}"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${b}${cyan}==> pod flags:${reset}"
printf "%s\n"     ".. specify pod to run                    | -p  --pod              |  <pod_NAME>       |   yes"
printf "%s\n"     ".. this help                             | -h  --help             |      no           |   n/a"
printf "%s\n"     ".. specific pod help                     | -p  -h                 |  <pod_NAME>       |   n/a"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
printf "%s\n"     "${b}examples:${reset}"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
printf "%s\n"     "${yellow}$ ./launch-pod -h${reset}"
printf "%s\n"     "${yellow}$ ./launch-pod -p pod_NAME -h${reset}"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
}

# ------------------------------------------

function lib_generic_helpFinish(){

if [[ "${podFlag}" != "true" ]]; then

  lib_generic_display_msgColourSimple "TASK==>" "pod list:"
  availablePods=$(ls ${pod_home_path}/pods | grep -vw "pod_")
  printf "%s\n" ${availablePods}

else

  lib_generic_display_msgColourSimple "TASK==>" "builds: ${green}${WHICH_POD}${reset}"
  availableBuilds=$(ls ${pod_home_path}/pods/${WHICH_POD}/builds)
  printf "%s\n" ${availableBuilds}
  
  lib_generic_display_msgColourSimple "TASK==>" "servers: ${green}all pods${reset}"
  availableServers=$(ls ${pod_home_path}/servers)
  printf "%s\n" ${availableServers}

fi
printf "%s\n"
}
