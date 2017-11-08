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
