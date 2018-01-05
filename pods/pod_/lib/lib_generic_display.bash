# about:        formatting for screen output

# ---------------------------------------

## Setup colors and text effects

black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
b=`tput bold`
u=`tput sgr 0 1`
ul=`tput smul`
xl=`tput rmul`
stou=`tput smso`
xtou=`tput rmso`
reverse=`tput rev`
reset=`tput sgr0`
italic=$(tput sitm)
tick="${b}${green}$(printf '\xE2\x9C\x94')${reset}"
cross="${b}${red}$(printf '\xE2\x9C\x99')${reset}"

# ---------------------------------------

function lib_generic_display_msgColourSimple(){

## display messages based on a simple colour scheme

messageType="${1}"
message="${2}"

case ${messageType} in
    "STAGECOUNT" )
                    printf "\n%s\n" "${b}${white}${message}${reset}" ;;
    "TASK==>" )
                    printf "%s\n\n" "${b}${cyan}____________________________________${reset}"
                    printf "%s\n\n" "${b}${cyan}==> ${message}${reset}" ;;
    "REPORT" )
                    printf "%s\n\n" "${b}${cyan}____________________________________${reset}"
                    printf "%s\n\n" "${b}${yellow}==> ${message}${reset}" ;;
    "ALERT-->" )
                    printf "\n%s\n" "${b}${yellow}--> ${message} !!${reset}" ;;
    "ERROR-->" )
                    printf "\n%s\n" "${b}${red}--> ${message} !!${reset}" ;;
    "SUCCESS" )
                    printf "%s\n\n" "${tick}${b}${green} ${message} !!${reset}" ;;
    "FAILURE" )
                    printf "%s\n\n" "${cross}${b}${green} ${message} !!${reset}" ;;

# ----- no-spacing

    "STAGE" )
                    printf "%s\n"   "${b}${white}${message}${reset}" ;;
    "INFO" )
                    printf "%s\n"   "${white}${message} ${reset}" ;;
    "INFO-->" )
                    printf "%s\n"   "${white}--> ${message} ${reset}" ;;
    "INFO-BOLD" )
                    printf "%s\n"   "${b}${white}${message} ${reset}" ;;
    "INFO-BOLD-->" )
                    printf "%s\n"   "${b}${white}--> ${message} ${reset}" ;;
    "ERROR-TIGHT-->" )
                    printf "%s\n"   "${b}${red}--> ${message} !!${reset}" ;;
esac
}

# ---------------------------------------

function lib_generic_display_finalMessage(){

## at the end of each pod - display a message

which_pod="${1}"
# now is a good time to remove the temp files created during pod
prepare_generic_misc_clearTheDecks
case ${which_pod} in

    "pod_DSE" )

        if [[ ${os} == "Mac" ]] || [[ ${JAVA_INSTALL_TYPE} != "tar" ]]; then
          lib_generic_display_msgColourSimple "TASK==>"      "To run dse locally:"
          lib_generic_display_msgColourSimple "INFO-BOLD" "(a) Source '.bash_profile' (or open new terminal):"
          lib_generic_display_msgColourSimple "INFO"      "$ . ~/.bash_profile"
          lib_generic_display_msgColourSimple "INFO-BOLD" "(b) Run dse:"
          lib_generic_display_msgColourSimple "INFO"      "$ dse cassandra            # start dse storage"
          lib_generic_display_msgColourSimple "INFO"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
          printf "%s\n"
          lib_generic_display_msgColourSimple "TASK==>"      "To start the entire cluster:"
          lib_generic_display_msgColourSimple "INFO-BOLD" "--> based on mode settings in servers .json defintion file."
          lib_generic_display_msgColourSimple "INFO"      "$ ./launch-pod --pod pod_DSE --servers ${SERVERS_JSON} --build ${BUILD_FOLDER} --clusterstate restart"
        elif [[ "${JAVA_INSTALL_TYPE}" == "tar" ]]; then
          lib_generic_display_msgColourSimple "TASK==>"      "To run dse locally:"
          lib_generic_display_msgColourSimple "INFO-BOLD" "(a) Source '.bash_profile' (or open new terminal):"
          lib_generic_display_msgColourSimple "INFO"      "$ . ~/.bash_profile"
          lib_generic_display_msgColourSimple "INFO-BOLD" "(b) Add java tar to system java alternatives - you may have to alter yellow portion of path:"
          lib_generic_display_msgColourSimple "INFO"      "$ sudo update-alternatives --install /usr/bin/java java ${yellow}${java_untar_folder}${white}${JAVA_VERSION}/bin/java 100"
          lib_generic_display_msgColourSimple "INFO-BOLD" "(c) Select this java tar from list:"
          lib_generic_display_msgColourSimple "INFO"      "$ sudo update-alternatives --config java"
          lib_generic_display_msgColourSimple "INFO-BOLD" "(d) Run dse:"
          lib_generic_display_msgColourSimple "INFO"      "$ dse cassandra            # start dse storage"
          lib_generic_display_msgColourSimple "INFO"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
          printf "%s\n"
          lib_generic_display_msgColourSimple "TASK==>"      "To start the entire cluster:"
          lib_generic_display_msgColourSimple "INFO-BOLD" "--> based on mode settings in servers .json defintion file."
          lib_generic_display_msgColourSimple "INFO"      "$ ./launch-pod --pod pod_DSE --servers ${SERVERS_JSON} --clusterstate start"
        fi
        printf "%s\n" ;;

    "pod_DSE_rollingStartStop" )
          lib_generic_display_msgColourSimple "TASK==>" "To Check Status of Cluster:"
          lib_generic_display_msgColourSimple "INFO" "$ nodetool status"
          printf "%s\n" ;;

    "pod_JAVA" )
          lib_generic_display_msgColourSimple "TASK==>" "Optional Java Security Instructions:"
          lib_generic_display_msgColourSimple "INFO" "$ dsetool createsystemkey 'AES/ECB/PKCS5Padding'256 ob_key"
          lib_generic_display_msgColourSimple "INFO" "$ stat /etc/dse/conf/ob_key     # chmod 700"
          lib_generic_display_msgColourSimple "INFO" "Perform a rolling restart of cluster"
          lib_generic_display_msgColourSimple "INFO" "Upgrade SSTABLES for encryption:"
          lib_generic_display_msgColourSimple "$ nodetool upgradesstables -a system batchlog paxos"
          printf "%s\n" ;;

      *)
      printf "%s\n" "" ;;
esac
}

# ---------------------------------------

function lib_generic_display_banner(){

clear
printf "%s"  "${b}${cyan}"
cat << "EOF"
                     __    _  _
    ____  ____  ____/ /  _(_)(_)_
   / __ \/ __ \/ __  /  (_)    (_)
  / /_/ / /_/ / /_/ /   (_)_  _(_)
 / .___/\____/\__,_/      (_)(_)
/_/
EOF
printf "%s" "${reset}"
printf "%s\n" "${cyan}----------------------------------"
if [[ "${WHICH_POD}" != "" ]]; then
  printf "%s\n" "${yellow}version: ${reset}${POD_VERSION} | ${green}running: ${reset}${WHICH_POD}"
  printf "%s\n" "${cyan}----------------------------------${reset}"
else
  printf "%s\n" "${yellow}version: ${reset}${POD_VERSION}"
  printf "%s\n" "${cyan}----------------------------------${reset}"
fi
printf "%s\n"
}
