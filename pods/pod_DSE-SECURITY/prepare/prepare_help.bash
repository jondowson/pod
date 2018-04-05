# about:    help on pod_DSE usage and flags

# ------------------------------------------

function prepare_help(){

## help message for this pod - displayed with the help flag (-h --help)
## e.g. pod -p pod_<NAME> -h

prepare_generic_display_msgColourSimple "TASK==>" "pod_DSE-SECURITY flags:"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${b}example:${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${yellow}$ pod -p pod_DSE-SECURITY -s myServers.json -b dse-5.1.5_security${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}

# ------------------------------------------

function pod_DSE-SECURITY_finalMessage(){

## final helpful message displayed at the end of running this pod

prepare_generic_display_msgColourSimple "TASK==>"   "Finish:"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(1) Rolling restart of cluster to apply ssl settings"
prepare_generic_display_msgColourSimple "INFO"      "$ pod --pod pod_DSE --servers ${SERVERS_JSON} --build ${BUILD_FOLDER} --clusterstate restart"
}
