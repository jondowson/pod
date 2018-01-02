# author:        jondowson
# about:         help on pod usage and flags

# ------------------------------------------

function lib_help(){

lib_generic_display_msgColourSimple "TASK==>" "pod_REMOVE-PODS flags:"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   ".. remove this pod from POD_INSTALLS     | -rp --removepod        |  <pod_NAME>       |   yes"
printf "%s\n"
printf "%s\n"   "${b}examples:${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${yellow}$ ./launch-pod -p pod_REMOVE-POD -s myServers.json -b remove_pods --rp pod_DSE${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}
