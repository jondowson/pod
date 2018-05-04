function prepare_help(){

## help message for this pod - displayed with the help flag (-h --help)
## e.g. pod -p pod_DSE -h

prepare_generic_display_msgColourSimple "TASK" "Flags: pod_DSE"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   ".. scp POD_SOFTWARE folder to servers    | -ss --sendsoft         |  false [true]     |   no"
printf "%s\n"   ".. re-generate build resources folder    | -rr --regenresources   | true edit [false] |   no"
printf "%s\n"   ".. rolling stop/start of dse + agent     | -cs --clusterstate     |  restart          |   no"
printf "%s\n"   ".. rolling stop of dse + agent           | -cs --clusterstate     |  stop             |   no"
printf "%s\n"   ".. rolling stop/start of agent           | -cs --clusterstate     |  agent-restart    |   no"
printf "%s\n"   ".. rolling stop of agent                 | -cs --clusterstate     |  agent-stop       |   no"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${b}examples:${reset}"
printf "%s\n"   "${yellow}$ pod -p pod_DSE -s myServers.json -b dse-5.0.5_pre-prod -ss false --rr true${reset}"
printf "%s\n"   "${yellow}$ pod -p pod_DSE -s myServers.json -b dse-5.0.5_pre-prod -rr edit${reset} (automatic exit after -rr stage)"
printf "%s\n"   "${yellow}$ pod -p pod_DSE -s myServers.json --clusterstate restart${reset} (both dse + agent)"
printf "%s\n"   "${yellow}$ pod -p pod_DSE -s myServers.json --clusterstate agent-restart${reset} (just datastax-agent)"
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
printf "%s\n" ""
prepare_generic_display_msgColourSimple "INFO-BOLD" "README=================================================================================="
prepare_generic_display_msgColourSimple "INFO"      "- [A] dse-5.0.x requires using shorter paths to run on a Mac"
prepare_generic_display_msgColourSimple "INFO"      "- + on any Mac in the cluster specify in the json a target_folder of /POD/ and ensure path is writable"
prepare_generic_display_msgColourSimple "INFO"      "- [B] '--clusterstate restart' or '--clusterstate agent-restart' restarts processes for the specified pod_DSE build"
prepare_generic_display_msgColourSimple "INFO"      "- + but it does not alter the CASSANDRA_PATH set in bash_profile"
prepare_generic_display_msgColourSimple "INFO"      "- + running commands such as 'dse nodetool' will utilise the CASSANDRA_PATH specified in bash_profile"
prepare_generic_display_msgColourSimple "INFO"      "- + this may be different to the build you restarted"
prepare_generic_display_msgColourSimple "INFO"      "- + to update the CASSANDRA_PATH in bash_profile, re-run pod_DSE for the desired build"
prepare_generic_display_msgColourSimple "INFO"      "- + this can be done safely against a running cluster"
prepare_generic_display_msgColourSimple "INFO-BOLD" "========================================================================================"
}

# ------------------------------------------

function pod_DSE-rollingStopStart_finalMessage(){

prepare_generic_display_msgColourSimple "TASK==>"   "Finish:"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(1) To check status of cluster"
prepare_generic_display_msgColourSimple "INFO"      "$ dse nodetool status"
prepare_generic_display_msgColourSimple "INFO"      "$ dsetool ring"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(2) To verify agent pid (or use Opscenter)"
prepare_generic_display_msgColourSimple "INFO"      "$ ps -ef | grep datastax-agent | grep -v grep"
if [[ "${CLUSTER_STATE}" == *"restart"* ]];then
  printf "%s\n" ""
  prepare_generic_display_msgColourSimple "INFO-BOLD" "README=================================================================================="
  prepare_generic_display_msgColourSimple "INFO"      "- [A] dse-5.0.x requires using shorter paths to run on a Mac"
  prepare_generic_display_msgColourSimple "INFO"      "- + on any Mac in the cluster specify in the json a target_folder of /POD/ and ensure path is writable"
  prepare_generic_display_msgColourSimple "INFO"      "- [B] '--clusterstate restart' or '--clusterstate agent-restart' restarts processes for the specified pod_DSE build"
  prepare_generic_display_msgColourSimple "INFO"      "- + but it does not alter the CASSANDRA_PATH set in bash_profile"
  prepare_generic_display_msgColourSimple "INFO"      "- + running commands such as 'dse nodetool' will utilise the CASSANDRA_PATH specified in bash_profile"
  prepare_generic_display_msgColourSimple "INFO"      "- + this may be different to the build you restarted"
  prepare_generic_display_msgColourSimple "INFO"      "- + to update the CASSANDRA_PATH in bash_profile, re-run pod_DSE for the desired build"
  prepare_generic_display_msgColourSimple "INFO"      "- + this can be done safely against a running cluster"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "========================================================================================"
else
  printf "%s\n" ""
  prepare_generic_display_msgColourSimple "INFO-BOLD" "README=================================================================================="
  prepare_generic_display_msgColourSimple "INFO"      "- [A] dse-5.0.x requires using shorter paths to run on a Mac"
  prepare_generic_display_msgColourSimple "INFO"      "- + on any Mac in the cluster specify in the json a target_folder of /POD/ and ensure path is writable"
  prepare_generic_display_msgColourSimple "INFO"      "- [B] '--clusterstate stop' or '--clusterstate agent-stop' halts processes for the specified pod_DSE build"
  prepare_generic_display_msgColourSimple "INFO"      "- + but it does not alter the CASSANDRA_PATH set in bash_profile"
  prepare_generic_display_msgColourSimple "INFO"      "- + running commands such as 'dse nodetool' will utilise the CASSANDRA_PATH specified in bash_profile"
  prepare_generic_display_msgColourSimple "INFO"      "- + this may be different to the build you restarted"
  prepare_generic_display_msgColourSimple "INFO"      "- + to update the CASSANDRA_PATH in bash_profile, re-run pod_DSE for the desired build"
  prepare_generic_display_msgColourSimple "INFO"      "- + this can be done safely against a running cluster"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "========================================================================================"
fi
}
