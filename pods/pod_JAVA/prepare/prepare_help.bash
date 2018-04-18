function prepare_help(){

## help message for this pod - displayed with the help flag (-h --help)
## e.g. pod -p pod_JAVA -h

prepare_generic_display_msgColourSimple "TASK" "Flags: pod_JAVA"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   ".. specify servers .json defintion       | -s  --servers          |  <servers.json>   |   yes"
printf "%s\n"   ".. specify build folder                  | -b  --build            |  <build_folder>   |   yes"
printf "%s\n"   ".. scp POD_SOFTWARE folder to servers    | -ss --sendsoft         |  false [true]     |   no"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
printf "%s\n"   "${b}example:${reset}"
printf "%s\n"   "${yellow}$ pod -p ${WHICH_POD} -s myServers.json -b oracle-jre1.8.152_practice -ss false ${reset}"
printf "%s\n"   "--------------------------------------------------------------------------------------------------"
}

# ------------------------------------------

function pod_JAVA_finalMessage(){

## final helpful message displayed at the end of running this pod

prepare_generic_display_msgColourSimple "TASK==>"   "Finish:"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(1) Source '.bash_profile' (or open new terminal):"
prepare_generic_display_msgColourSimple "INFO"      "$ . ~/.bash_profile"
prepare_generic_display_msgColourSimple "INFO-BOLD" "(2) Check java version"
prepare_generic_display_msgColourSimple "INFO"      "$ java -version"
}
