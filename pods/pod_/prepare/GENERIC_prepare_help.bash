function GENERIC_prepare_help(){

printf "%s%s\n" "${b}                                         | flag(s)                | values[default]   | required?" "${reset}";
printf "%s\n"     "--------------------------------------------------------------------------------------------------";
GENERIC_prepare_display_msgColourSimple "TASK" "Flags: pod_";
printf "%s\n"   "--------------------------------------------------------------------------------------------------";
printf "%s\n"     ".. this help                             | -h  --help             |      no           |   no";
printf "%s\n"     ".. specify pod to run                    | -p  --pod              |  <pod_NAME>       |   no";
printf "%s\n"     ".. specific pod help                     | -p  -h                 |  <pod_NAME>       |   no";
printf "%s\n"     "--------------------------------------------------------------------------------------------------";
printf "%s\n"     "${b}examples:${reset}";
printf "%s\n"     "${yellow}$ pod -h${reset}";
printf "%s\n"     "${yellow}$ pod -p pod_NAME -h${reset}";
printf "%s\n"     "--------------------------------------------------------------------------------------------------";
};

# ------------------------------------------

function GENERIC_prepare_helpLists(){

## list available pods, all server definitions and pod specific build folders

if [[ "${podFlag}" != "true" ]]; then

  GENERIC_prepare_display_msgColourSimple "TASK" "Available pods:";
  availablePods=$(ls ${podHomePath}/pods | grep -vw "pod_");
  printf "%s\n" ${availablePods};

else

  GENERIC_prepare_display_msgColourSimple "TASK" "Available server definitions:         ${green}all pods${reset}";
  availableServers=$(ls ${podHomePath}/servers);
  printf "%s\n" ${availableServers};

  GENERIC_prepare_display_msgColourSimple "TASK" "Available build definitions for pod:  ${green}${WHICH_POD}${reset}";
  availableBuilds=$(ls ${podHomePath}/pods/${WHICH_POD}/builds);
  printf "%s\n" ${availableBuilds};

fi;
printf "%s\n";
};
