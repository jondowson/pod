function prepare_help(){

## help message for this pod - displayed with the help flag (-h --help)
## e.g. pod -p pod_REMOVE-PODS -h

GENERIC_prepare_display_msgColourSimple "TASK" "Flags: pod_REMOVE-PODS"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   ".. remove this pod from POD_INSTALLS     | -rp --removepod        |  <pod_NAME>       |   yes"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${b}examples:${reset}"
printf "%s\n"   "${yellow}$ pod -p ${WHICH_POD} -s myServers.json -b remove_pods --rp pod_DSE${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}

# ------------------------------------------

function pod_REMOVE-PODS_finalMessage(){

GENERIC_prepare_display_msgColourSimple "TASK==>"   "Finish:"
GENERIC_prepare_display_msgColourSimple "INFO-BOLD" "(1) Check POD_INSTALLS folder to verify: ${yellow}${REMOVE_POD}${white} has been removed"
GENERIC_prepare_display_msgColourSimple "INFO-BOLD" "(2) Check ~/.bash_profile to verify:     ${yellow}${REMOVE_POD}${white} labelled blocks have been removed"
}
