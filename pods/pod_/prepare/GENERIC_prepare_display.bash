## Setup colors and text effects

black=`tput setaf 0`;
red=`tput setaf 1`;
green=`tput setaf 2`;
yellow=`tput setaf 3`;
blue=`tput setaf 4`;
magenta=`tput setaf 5`;
cyan=`tput setaf 6`;
white=`tput setaf 7`;
b=`tput bold`;
u=`tput sgr 0 1`;
ul=`tput smul`;
xl=`tput rmul`;
stou=`tput smso`;
xtou=`tput rmso`;
reverse=`tput rev`;
reset=`tput sgr0`;
italic=$(tput sitm);
tick="${b}${green}$(printf '\xE2\x9C\x94')${reset}";
cross="${b}${red}$(printf '\xE2\x9C\x99')${reset}";
u="_";

# ---------------------------------------

function GENERIC_prepare_display_msgColourSimple(){

## display messages based on a simple colour scheme

messageType="${1}";
message="${2}";

case ${messageType} in
    "STAGECOUNT" )
                    printf "%s\n"      "${b}${white}${message}${reset}" ;;
    "STAGE_REPORT" )
                    printf "\n%s\n"    "${b}${white}${message}${reset}" ;;
    "TASK==>" )
                    printf "\n%s\n\n"  "${b}${cyan}==> ${message}${reset}" ;;
    "REPORT" )
                    printf "\n%s\n\n"  "${b}${yellow}==> ${message}${reset}" ;;
    "ALERT-->" )
                    printf "\n%s\n"    "${b}${yellow}--> ${message} ${yellow}!!${reset}" ;;
    "ERROR-->" )
                    printf "\n%s\n"    "${b}${red}--> ${message} ${red}!!${reset}" ;;
    "SUCCESS" )
                    printf "%s\n"      "${tick}${b}${green} ${message} ${green}!!${reset}" ;;
    "FAILURE" )
                    printf "%s\n"      "${cross}${b}${green} ${message} ${red}!!${reset}" ;;
    "INFO-BOLD-SPACED" )
                    printf "\n%s\n"   "${b}${white}${message} ${reset}" ;;

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
esac;
};

# ---------------------------------------

function GENERIC_prepare_display_stageCount(){

## display which is the currect stage being executed

stageTitle=${1};
stageCount=${2};
stageTotal=${3};

GENERIC_prepare_display_banner;
GENERIC_prepare_display_msgColourSimple "STAGECOUNT" "STAGE: [ ${b}${cyan}${stageCount}${reset} of ${b}${cyan}${stageTotal}${white} ] ${stageTitle}";
};

# ---------------------------------------

function GENERIC_prepare_display_stageTimeCount(){

## display timer and message at end of stage and before next stage

printf "%s\n";
GENERIC_lib_misc_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE...";
};

# ---------------------------------------

function GENERIC_prepare_display_banner(){

## display logo and header

clear;
printf "%s"  "${b}${cyan}";
cat << EOF
                     __    _  _
    ____  ____  ____/ /  _(_)(_)_
   / __ \/ __ \/ __  /  (_)    (_)
  / /_/ / /_/ / /_/ /   (_)_  _(_)
 / .___/\____/\__,_/      (_)(_)
/_/
EOF

printf "%s\n" "----------------------------------";
if [[ "${WHICH_POD}" != "" ]]; then
  printf "%s\n" "${yellow}version: ${reset}${POD_VERSION} | ${green}running: ${reset}${WHICH_POD}";
  printf "%s\n" "${cyan}----------------------------------${reset}";
else
  printf "%s\n" "${yellow}version: ${reset}${POD_VERSION}";
  printf "%s\n" "${cyan}----------------------------------${reset}";
fi
printf "%s\n";
}
