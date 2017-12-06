#!/bin/bash

# author:       jondowson
# about:        install mac dependencies for the pod application

#-------------------------------------------

# uncomment to see full bash trace (debug)
# set -x

#-------------------------------------------

## determine this scripts' folder path

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
podSetupFolder="$(cd ../; pwd)"

#-------------------------------------------

## source dse-setup lib scripts

# source lib folder scripts
files="$(find ${podSetupFolder}/pods/pod_/lib -name "*.sh*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

# source prepare folder scripts
files="$(find ${podSetupFolder}/pods/pod_/prepare -name "*.sh*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

#========================================== START!!

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Prepare Mac for pod"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1${white} 2 ]${reset}"
lib_generic_display_msgColourSimple "TASK==>"       "TASK: Install brew packages"

brewList=$(brew list)

if [[ $brewList == *"command not found"* ]]; then
  lib_generic_display_msgColourSimple "alert" "Installing homebrew"
else
  lib_generic_display_msgColourSimple "alert" "Fetching latest homebrew"
fi
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
printf "%s\n"

if [[ $brewList == *"coreutils"* ]]; then
  lib_generic_display_msgColourSimple "alert" "Fetching latest core-utils"
  printf "%s\t" "$ brew upgrade coreutils"
  brew upgrade coreutils > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  lib_generic_display_msgColourSimple "alert" "Installing core-utils"
  printf "%s\t" "$ brew install coreutils"
  brew install coreutils > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi

# -----------------

if [[ $brewList == *"bash"* ]]; then
  lib_generic_display_msgColourSimple "alert" "Fetching latest bash"
  printf "%s\t\t" "$ brew upgrade bash"
  brew upgrade bash > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  lib_generic_display_msgColourSimple "alert" "Installing bash"
  printf "%s\t\t" "$ brew install bash"
  brew install bash > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi

# -----------------

if [[ $brewList == *"gnu-sed"* ]]; then
  lib_generic_display_msgColourSimple "alert" "Fetching latest gnu-sed"
  printf "%s\t\t" "$ brew upgrade gnu-sed"
  brew upgrade gnu-sed > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  lib_generic_display_msgColourSimple "alert" "Installing gnu-sed"
  printf "%s\t\t" "$ brew install gnu-sed"
  brew install gnu-sed > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi

# -----------------

if [[ $brewList == *"awk"* ]]; then
  lib_generic_display_msgColourSimple "alert" "Fetching latest awk"
  printf "%s\t\t" "$ brew upgrade awk"
  brew upgrade awk > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  lib_generic_display_msgColourSimple "alert" "Installing awk"
  printf "%s\t\t" "$ brew install awk"
  brew install awk > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi

# -----------------

if [[ $brewList == *"jq"* ]]; then
  lib_generic_display_msgColourSimple "alert" "Fetching latest jq"
  printf "%s\t\t" "$ brew upgrade jq"
  brew upgrade jq > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  lib_generic_display_msgColourSimple "alert" "Installing jq"
  printf "%s\t\t" "$ brew install jq"
  brew install jq > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi

#-------------------------------------------

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Prepare Mac for pod"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 ${white}]${reset}"
lib_generic_display_msgColourSimple "TASK==>"       "TASK: Configure bash interpreter"

# update hashbang for launch-pod - so it uses brew version of bash
prepare_generic_misc_identifyOs
lib_generic_strings_sedStringManipulation "searchAndReplaceStringGlobal" "${podSetupFolder}/launch-pod" "bin/bash" "usr/local/bin/bash"

printf "%s\n"
lib_generic_display_msgColourSimple "alert" "Homebrew installed packages:"
lib_generic_display_msgColourSimple "info"  "$ brew list"
brew list
printf "%s\n"

lib_generic_display_msgColourSimple "title"     "Final tasks to complete Mac setup:"
lib_generic_display_msgColourSimple "info-bold" "(a) In terminal check bash for mac is version 4 or greater:"
lib_generic_display_msgColourSimple "info"      "$ bash --version"
lib_generic_display_msgColourSimple "info-bold" "(b) If not, then point to homebrew version of bash:"
lib_generic_display_msgColourSimple "info"      "Open Mac settings --> Users&Groups --> right-click --> advanced options"
lib_generic_display_msgColourSimple "info"      "Change 'login shell' to use /usr/local/bin/bash"
lib_generic_display_msgColourSimple "info-bold" "(c) In new terminal repeat step (a)"
lib_generic_display_msgColourSimple "info"      "$ bash --version"

printf "%s\n"
