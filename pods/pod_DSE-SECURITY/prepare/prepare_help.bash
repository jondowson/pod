# about:    help on pod_DSE usage and flags

# ------------------------------------------

function prepare_help(){

prepare_generic_display_msgColourSimple "TASK==>" "pod_DSE-SECURITY flags:"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"
printf "%s\n"   "${b}examples:${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${yellow}$ ./launch-pod -p pod_DSE-SECURITY -s myServers.json -b dse-5.1.5_security${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}
