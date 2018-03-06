# about:    help on pod_JAVA usage and flags

# ------------------------------------------

function prepare_help(){

prepare_generic_display_msgColourSimple "TASK==>" "${WHICH_POD} flags:"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   ".. scp POD_SOFTWARE folder to servers    | -ss --sendsoft         |  false [true]     |   no"
printf "%s\n"
printf "%s\n"   "${b}example:${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${yellow}$ pod -p ${WHICH_POD} -s myServers.json -b oracle-jre1.8.152_practice -ss false ${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}
