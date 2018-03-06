# about:    help on this pod's usage and flags

# ------------------------------------------

function prepare_help(){

prepare_generic_display_msgColourSimple "TASK==>" "${WHICH_POD} flags:"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   ".. remove this pod from POD_INSTALLS     | -rp --removepod        |  <pod_NAME>       |   yes"
printf "%s\n"
printf "%s\n"   "${b}examples:${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${yellow}$ pod -p ${WHICH_POD} -s myServers.json -b remove_pods --rp pod_DSE${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}
