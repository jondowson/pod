function prepare_help(){

## main help for this pod

prepare_generic_display_msgColourSimple "TASK" "Flags: pod_DSE-OPSCENTER"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   ".. scp POD_SOFTWARE folder to servers    | -ss --sendsoft         |  false [true]     |   no"
printf "%s\n"   ".. rolling stop/start of opscenter       | -cs --clusterstate     |  restart stop     |   no"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${b}examples:${reset}"
printf "%s\n"   "${yellow}$ pod -p ${WHICH_POD} -s myServers.json -b opscenter-6.1.5_practice -ss false ${reset}"
printf "%s\n"   "${yellow}$ pod -p ${WHICH_POD} -s myServers.json -b opscenter-6.1.5_practice -cs restart ${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}

# ------------------------------------------

function pod_DSE-OPSCENTER_finalMessage(){

## final helpful message displayed at the end of running this pod

prepare_generic_display_msgColourSimple "TASK==>"   "Finish:"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(1) Source '.bash_profile' (or open new terminal):"
prepare_generic_display_msgColourSimple "INFO"      "$ . ~/.bash_profile"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(2) Start opscenter"
prepare_generic_display_msgColourSimple "INFO"      "$ pod --pod pod_DSE-OPSCENTER -s ${SERVERS_JSON} -b ${BUILD_FOLDER} -cs restart"
}

# ------------------------------------------

function pod_DSE-OPSCENTER-rollingStart_finalMessage(){

prepare_generic_display_msgColourSimple "TASK==>"   "Finish:"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(1) Check opscenter status here:"
prepare_generic_display_msgColourSimple "INFO"      "http://${pubIp}:8888"
}

# ------------------------------------------

function pod_DSE-OPSCENTER-rollingStop_finalMessage(){

prepare_generic_display_msgColourSimple "TASK==>"   "Finish:"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(1) Opscenter should no longer be up here:"
prepare_generic_display_msgColourSimple "INFO"      "http://${pubIp}:8888"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(2) Verify agent pid is not up"
prepare_generic_display_msgColourSimple "INFO"      "$ ps -ef | grep opscenter | grep -v grep"
}
