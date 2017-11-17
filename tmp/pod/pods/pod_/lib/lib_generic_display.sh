#!/bin/bash

# author:       jondowson
# about:        formatting for screen output

#-------------------------------------------

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
cross="${b}${red}✘${reset}"

# ---------------------------------------

function lib_generic_display_msgColourSimple(){

## display messages based on a simple colour scheme

messageType="${1}"
message="${2}"

case ${messageType} in
    "STAGE" )
        printf "%s\n" "${b}${white}${message}${reset}" ;;
    "STAGECOUNT" )
        printf "\n%s\n" "${b}${white}${message}${reset}" ;;
    "TASK" )
        printf "%s\n\n" "${b}${cyan}____________________________________${reset}"
        printf "%s\n\n" "${b}${cyan}==> ${message}${reset}" ;;
    "REPORT" )
        printf "%s\n\n" "${b}${cyan}____________________________________${reset}"
        printf "%s\n\n" "${b}${yellow}==> ${message}${reset}" ;;
    "alert" )
        printf "%s\n"   "${b}${yellow}--> ${message} !!${reset}" ;;
    "error" )
        printf "%s\n\n" "${b}${red}--> ${message} !!${reset}" ;;
    "error-tight" )
        printf "%s\n"   "${b}${red}--> ${message} !!${reset}" ;;
    "info" )
        printf "%s\n"   "${white}${message} ${reset}" ;;
    "info-bold" )
        printf "%s\n"   "${b}${white}${message} ${reset}" ;;
    "info-indented" )
        printf "%s\n"   "${white}--> ${message} ${reset}" ;;
    "info-bold-indented" )
        printf "%s\n"   "${b}${white}--> ${message} ${reset}" ;;
    "success" )
        printf "%s\n\n" "${tick}${b}${green} ${message} !!${reset}" ;;
esac
}

# ---------------------------------------

function lib_generic_display_finalMessage(){

## at the end of each pod - display a message

which_pod="${1}"
case ${which_pod} in

    "pod_DSE" )

        if [[ ${os} == "Mac" ]] || [[ ${JAVA_INSTALL_TYPE} != "tar" ]]; then
          lib_generic_display_msgColourSimple "TASK"      "To run dse locally:"
          lib_generic_display_msgColourSimple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
          lib_generic_display_msgColourSimple "info"      "$ . ~/.bash_profile"
          lib_generic_display_msgColourSimple "info-bold" "(b) Run dse:"
          lib_generic_display_msgColourSimple "info"      "$ dse cassandra            # start dse storage"
          lib_generic_display_msgColourSimple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
          printf "%s\n"
          lib_generic_display_msgColourSimple "TASK"      "To start the entire cluster:"
          lib_generic_display_msgColourSimple "info-bold" "--> based on mode settings in servers .json defintion file."
          lib_generic_display_msgColourSimple "info"      "$ ./launch-pod --pod pod_DSE --servers ${SERVERS_JSON} --clusterstate start"
        elif [[ "${JAVA_INSTALL_TYPE}" == "tar" ]]; then
          lib_generic_display_msgColourSimple "TASK"      "To run dse locally:"
          lib_generic_display_msgColourSimple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
          lib_generic_display_msgColourSimple "info"      "$ . ~/.bash_profile"
          lib_generic_display_msgColourSimple "info-bold" "(b) Add java tar to system java alternatives - you may have to alter yellow portion of path:"
          lib_generic_display_msgColourSimple "info"      "$ sudo update-alternatives --install /usr/bin/java java ${yellow}${java_untar_folder}${white}${JAVA_VERSION}/bin/java 100"
          lib_generic_display_msgColourSimple "info-bold" "(c) Select this java tar from list:"
          lib_generic_display_msgColourSimple "info"      "$ sudo update-alternatives --config java"
          lib_generic_display_msgColourSimple "info-bold" "(d) Run dse:"
          lib_generic_display_msgColourSimple "info"      "$ dse cassandra            # start dse storage"
          lib_generic_display_msgColourSimple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
          printf "%s\n"
          lib_generic_display_msgColourSimple "TASK"      "To start the entire cluster:"
          lib_generic_display_msgColourSimple "info-bold" "--> based on mode settings in servers .json defintion file."
          lib_generic_display_msgColourSimple "info"      "$ ./launch-pod --pod pod_DSE --servers ${SERVERS_JSON} --clusterstate start"
        fi
        printf "%s\n" ;;
        
    "pod_DSE_rollingStartStop" )
          lib_generic_display_msgColourSimple "TASK" "To Check Status of Cluster:"
          lib_generic_display_msgColourSimple "info" "$ nodetool status"
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
printf "%s\n"  "${reset}"
}
