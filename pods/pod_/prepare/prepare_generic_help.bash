# about:         help on pod usage and flags

# ------------------------------------------

function prepare_generic_help(){

printf "%s%s\n" "${b}description                              | flag(s)                | values[default]   | required?" "${reset}"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
prepare_generic_display_msgColourSimple "TASK" "Flags: pod_"
printf "%s\n"     ".. specify pod to run                    | -p  --pod              |  <pod_NAME>       |   yes"
printf "%s\n"     ".. this help                             | -h  --help             |      no           |   no"
printf "%s\n"     ".. specific pod help                     | -p  -h                 |  <pod_NAME>       |   no"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
printf "%s\n"     "${b}examples:${reset}"
printf "%s\n"     "${yellow}$ pod -h${reset}"
printf "%s\n"     "${yellow}$ pod -p pod_NAME -h${reset}"
printf "%s\n"     "--------------------------------------------------------------------------------------------------"
}

# ------------------------------------------

function prepare_generic_helpFinish(){

if [[ "${podFlag}" != "true" ]]; then

  prepare_generic_display_msgColourSimple "TASK" "Available pods:"
  availablePods=$(ls ${pod_home_path}/pods | grep -vw "pod_")
  printf "%s\n" ${availablePods}

else

  prepare_generic_display_msgColourSimple "TASK" "Available server definitions:         ${green}all pods${reset}"
  availableServers=$(ls ${pod_home_path}/servers)
  printf "%s\n" ${availableServers}

  prepare_generic_display_msgColourSimple "TASK" "Available build definitions for pod:  ${green}${WHICH_POD}${reset}"
  availableBuilds=$(ls ${pod_home_path}/pods/${WHICH_POD}/builds)
  printf "%s\n" ${availableBuilds}

fi
printf "%s\n"
}
