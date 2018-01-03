# author:        jondowson
# about:         help on pod usage and flags

# ------------------------------------------

function lib_help(){

lib_generic_display_msgColourSimple "TASK==>" "pod_SSH-AUTH flags:"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"
printf "%s\n"   "${b}examples:${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${yellow}$ ./launch-pod -p pod_SSH_AUTH -s myServers.json -b ssh_auth ${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}
