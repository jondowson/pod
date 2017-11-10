#!/bin/bash

# script_name:  pod_generic_display.sh
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
             
# ---------------------------------------

function pod_generic_display_msgColourSimple(){

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

function pod_generic_display_finalMessage(){

## at the end of each pod - display a message

which_pod="${1}"

case ${which_pod} in

    "pod_dse" )
        if [[ ${os} == "Mac" ]] || [[ ${JAVA_INSTALL_TYPE} != "tar" ]]; then
          pod_generic_display_msgColourSimple "title"     "Final tasks to complete pod"
          pod_generic_display_msgColourSimple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
          pod_generic_display_msgColourSimple "info"      "$ . ~/.bash_profile"
          pod_generic_display_msgColourSimple "info-bold" "(b) Run dse:"
          pod_generic_display_msgColourSimple "info"      "$ dse cassandra            # start dse storage"
          pod_generic_display_msgColourSimple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
        elif [[ "${JAVA_INSTALL_TYPE}" == "tar" ]]; then
          pod_generic_display_msgColourSimple "title"     "Final tasks to complete pod"
          pod_generic_display_msgColourSimple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
          pod_generic_display_msgColourSimple "info"      "$ . ~/.bash_profile"
          pod_generic_display_msgColourSimple "info-bold" "(b) Add java tar to system java alternatives - you may have to alter yellow portion of path:"
          pod_generic_display_msgColourSimple "info"      "$ sudo update-alternatives --install /usr/bin/java java ${yellow}${java_untar_folder}${white}${JAVA_VERSION}/bin/java 100"
          pod_generic_display_msgColourSimple "info-bold" "(c) Select this java tar from list:"
          pod_generic_display_msgColourSimple "info"      "$ sudo update-alternatives --config java"
          pod_generic_display_msgColourSimple "info-bold" "(d) Run dse:"
          pod_generic_display_msgColourSimple "info"      "$ dse cassandra            # start dse storage"
          pod_generic_display_msgColourSimple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
        fi
        printf "%s\n" ;; 
    "pod_security" )
      pod_generic_display_msgColourSimple "title"     "Final tasks to complete pod"
      pod_generic_display_msgColourSimple "info-bold" "Security blah blah blah" ;;
      *)
      printf "%s\n" "" ;;
esac
} 
