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

function prepare_generic_display_msgColourSimple(){

## display messages based on a simple colour scheme

messageType="${1}"
message="${2}"

case ${messageType} in
    "STAGECOUNT" )
                    printf "%s\n" "${b}${white}${message}${reset}" ;;
    "TASK==>" )
                    printf "\n%s\n\n" "${b}${cyan}==> ${message}${reset}" ;;
    "REPORT" )
                    printf "\n%s\n\n" "${b}${yellow}==> ${message}${reset}" ;;
    "ALERT-->" )
                    printf "\n%s\n" "${b}${yellow}--> ${message} ${yellow}!!${reset}" ;;
    "ERROR-->" )
                    printf "\n%s\n" "${b}${red}--> ${message} ${red}!!${reset}" ;;
    "SUCCESS" )
                    printf "%s\n" "${tick}${b}${green} ${message} ${green}!!${reset}" ;;
    "FAILURE" )
                    printf "%s\n" "${cross}${b}${green} ${message} ${red}!!${reset}" ;;

# ----- no-spacing

    "STAGE" )
                    printf "%s\n"   "${b}${white}${message}${reset}" ;;
    "TASK" )
                    printf "%s\n"   "${b}${cyan}==> ${message}${reset}" ;;
    "ALERT" )
                    printf "%s\n"   "${b}${yellow}--> ${message} ${yellow}!!${reset}" ;;
    "INFO" )
                    printf "%s\n"   "${white}${message} ${reset}" ;;
    "INFO-->" )
                    printf "%s\n"   "${white}--> ${message} ${reset}" ;;
    "INFO-BOLD" )
                    printf "%s\n"   "${b}${white}${message} ${reset}" ;;
    "INFO-BOLD-->" )
                    printf "%s\n"   "${b}${white}--> ${message} ${reset}" ;;
    "ERROR-TIGHT-->" )
                    printf "%s\n"   "${b}${red}--> ${message} ${red}!!${reset}" ;;
esac
}

# ---------------------------------------

function prepare_generic_display_stageCount(){

stageTitle=${1}
stageCount=${2}
stageTotal=${3}

prepare_generic_display_banner
prepare_generic_display_msgColourSimple "STAGECOUNT" "STAGE: [ ${b}${cyan}${stageCount}${reset} of ${b}${cyan}${stageTotal}${white} ] ${stageTitle}"
}

# ---------------------------------------

function prepare_generic_display_stageTimeCount(){

printf "%s\n"
lib_generic_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."
}

# ---------------------------------------

function prepare_generic_display_finalMessage(){

## at the end of each pod - display a message

which_pod="${1}"
# now is a good time to remove the temp files created during pod
prepare_generic_misc_clearTheDecks
case ${which_pod} in

    "pod_DSE" )

        prepare_helpFinish ;;

    "pod_DSE_rollingStartStop" )
          prepare_generic_display_msgColourSimple "TASK==>" "To Check Status of Cluster:"
          prepare_generic_display_msgColourSimple "INFO" "$ nodetool status"
          printf "%s\n" ;;

    "pod_JAVA" )
          prepare_generic_display_msgColourSimple "TASK==>" "Optional Java Security Instructions:"
          prepare_generic_display_msgColourSimple "INFO" "$ dsetool createsystemkey 'AES/ECB/PKCS5Padding'256 ob_key"
          prepare_generic_display_msgColourSimple "INFO" "$ stat /etc/dse/conf/ob_key     # chmod 700"
          prepare_generic_display_msgColourSimple "INFO" "Perform a rolling restart of cluster"
          prepare_generic_display_msgColourSimple "INFO" "Upgrade SSTABLES for encryption:"
          prepare_generic_display_msgColourSimple "$ nodetool upgradesstables -a system batchlog paxos"
          printf "%s\n" ;;

      *)
      printf "%s\n" "" ;;
esac
}

# ---------------------------------------

function prepare_generic_display_banner(){

clear
printf "%s"  "${b}${cyan}"
cat << EOF
                     __    _  _
    ____  ____  ____/ /  _(_)(_)_
   / __ \/ __ \/ __  /  (_)    (_)
  / /_/ / /_/ / /_/ /   (_)_  _(_)
 / .___/\____/\__,_/      (_)(_)
/_/
EOF

printf "%s\n" "----------------------------------"
if [[ "${WHICH_POD}" != "" ]]; then
  printf "%s\n" "${yellow}version: ${reset}${POD_VERSION} | ${green}running: ${reset}${WHICH_POD}"
  printf "%s\n" "${cyan}----------------------------------${reset}"
else
  printf "%s\n" "${yellow}version: ${reset}${POD_VERSION}"
  printf "%s\n" "${cyan}----------------------------------${reset}"
fi
printf "%s\n"
}
