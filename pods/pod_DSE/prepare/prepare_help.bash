# about:    help on pod_DSE usage and flags

# ------------------------------------------

function prepare_help(){

## help message for this pod - displayed with the help flag (-h --help)
## e.g. pod -p pod_DSE -h

prepare_generic_display_msgColourSimple "TASK" "Flags: pod_DSE"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   ".. scp POD_SOFTWARE folder to servers    | -ss --sendsoft         |  false [true]     |   no"
printf "%s\n"   ".. re-generate build resources folder    | -rr --regenresources   | true edit [false] |   no"
printf "%s\n"   ".. rolling stop/start of cluster         | -cs --clusterstate     |  restart stop     |   no"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${b}examples:${reset}"
printf "%s\n"   "${yellow}$ pod -p pod_DSE -s myServers.json -b dse-5.0.5_pre-prod -ss false --rr true${reset}"
printf "%s\n"   "${yellow}$ pod -p pod_DSE -s myServers.json -b dse-5.0.5_pre-prod -rr edit${reset} (automatic exit after -rr stage)"
printf "%s\n"   "${yellow}$ pod -p pod_DSE -s myServers.json --clusterstate restart${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}

# ------------------------------------------

function pod_DSE_finalMessage(){

## final helpful message displayed at the end of running this pod

prepare_generic_display_msgColourSimple "TASK==>"   "Finish:"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(1) Source '.bash_profile' (or open new terminal):"
prepare_generic_display_msgColourSimple "INFO"      "$ . ~/.bash_profile"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(2) Start cluster (DSE workload determined by mode settings in json file)"
prepare_generic_display_msgColourSimple "INFO"      "$ pod --pod pod_DSE --servers ${SERVERS_JSON} --build ${BUILD_FOLDER} --clusterstate restart"
}

# ------------------------------------------

function pod_DSE-rollingStart_finalMessage(){

prepare_generic_display_msgColourSimple "TASK==>"   "Finish:"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(1) To check status of cluster"
prepare_generic_display_msgColourSimple "INFO"      "$ nodetool status"
prepare_generic_display_msgColourSimple "INFO-BOLD" "note:"
prepare_generic_display_msgColourSimple "INFO"      "- running '--clusterstate restart' has just restarted the specified pod_DSE build"
prepare_generic_display_msgColourSimple "INFO"      "- however '--clusterstate restart' does not alter the CASSANDRA_PATH set in bash_profile"
prepare_generic_display_msgColourSimple "INFO"      "- as such you MAY need to prepend the full build path to use its corresponding version of nodetool"
prepare_generic_display_msgColourSimple "INFO"      "- if you want to update the CASSANDRA_PATH to point at a given build, re-run pod_DSE for the desired build"

}
