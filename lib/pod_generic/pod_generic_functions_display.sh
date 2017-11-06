#!/bin/bash

# script_name:  format.sh
# author:       jondowson
# about:        formatting for screen output 

#-------------------------------------------

## Setup colors and text effects

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

tick="${b}${green}✓${reset}"
cross="${b}${red}✘${reset}"

#-------------------------------------------

function banner(){
#source format.sh
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
                     
# ---------------------------------------

function generic_msg_colour_simple(){

## display messages based on a simple colour scheme

messageType="${1}"
message="${2}"

case ${messageType} in
    "STAGE" )
        printf "%s\n" "${b}${cyan}${message}${reset}" ;;
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

function generic_msg_final_message(){

## at the end of each pod - display a message

which_pod="${1}"

case ${which_pod} in

    "pod_dse" )
        if [[ ${os} == "Mac" ]] || [[ ${JAVA_INSTALL_TYPE} != "tar" ]]; then
          generic_msg_colour_simple "title"     "Final tasks to complete pod"
          generic_msg_colour_simple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
          generic_msg_colour_simple "info"      "$ . ~/.bash_profile"
          generic_msg_colour_simple "info-bold" "(b) Run dse:"
          generic_msg_colour_simple "info"      "$ dse cassandra            # start dse storage"
          generic_msg_colour_simple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
        elif [[ "${JAVA_INSTALL_TYPE}" == "tar" ]]; then
          generic_msg_colour_simple "title"     "Final tasks to complete pod"
          generic_msg_colour_simple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
          generic_msg_colour_simple "info"      "$ . ~/.bash_profile"
          generic_msg_colour_simple "info-bold" "(b) Add java tar to system java alternatives - you may have to alter yellow portion of path:"
          generic_msg_colour_simple "info"      "$ sudo update-alternatives --install /usr/bin/java java ${yellow}${java_untar_folder}${white}${JAVA_VERSION}/bin/java 100"
          generic_msg_colour_simple "info-bold" "(c) Select this java tar from list:"
          generic_msg_colour_simple "info"      "$ sudo update-alternatives --config java"
          generic_msg_colour_simple "info-bold" "(d) Run dse:"
          generic_msg_colour_simple "info"      "$ dse cassandra            # start dse storage"
          generic_msg_colour_simple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
        fi
        printf "%s\n" ;; 
    "pod_security" )
      generic_msg_colour_simple "title"     "Final tasks to complete pod"
      generic_msg_colour_simple "info-bold" "Security blah blah blah" ;;

esac

}  
