#!/bin/bash

# script_name:  dependencies_mac.sh
# author:       jondowson
# about:        install mac dependencies for the dse-setup application

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
files="$(find ${podSetupFolder}/lib -name "*.sh*" | grep -v  "dependencies_mac.sh")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

#========================================== START!!

brewList=$(brew list)
clear
if [[ $brewList == *"command not found"* ]]; then
  generic_msg_colour_simple "alert" "Installing homebrew"
else
  generic_msg_colour_simple "alert" "Fetching latest homebrew"
fi
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
printf "%s\n"

if [[ $brewList == *"coreutils"* ]]; then
  generic_msg_colour_simple "alert" "Fetching latest core-utils"
  printf "%s\t" "$ brew upgrade coreutils"
  brew upgrade coreutils > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  generic_msg_colour_simple "alert" "Installing core-utils"
  printf "%s\t" "$ brew install coreutils"
  brew install coreutils > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi

# -----------------

if [[ $brewList == *"bash"* ]]; then
  generic_msg_colour_simple "alert" "Fetching latest bash"
  printf "%s\t\t" "$ brew upgrade bash"
  brew upgrade bash > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  generic_msg_colour_simple "alert" "Installing bash"
  printf "%s\t\t" "$ brew install bash"
  brew install bash > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi

# -----------------

if [[ $brewList == *"gnu-sed"* ]]; then
  generic_msg_colour_simple "alert" "Fetching latest gnu-sed"
  printf "%s\t\t" "$ brew upgrade gnu-sed"
  brew upgrade gnu-sed > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  generic_msg_colour_simple "alert" "Installing gnu-sed"
  printf "%s\t\t" "$ brew install gnu-sed"
  brew install gnu-sed > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi

# -----------------

printf "%s\n"
generic_msg_colour_simple "alert" "Homebrew installed packages:"
generic_msg_colour_simple "info"  "$ brew list"
brew list
printf "%s\n"

generic_msg_colour_simple "title"     "Final tasks to complete Mac setup:"
generic_msg_colour_simple "info-bold" "(a) In terminal check bash for mac is version 4 or greater:"
generic_msg_colour_simple "info"      "$ bash --version"
generic_msg_colour_simple "info-bold" "(b) If not, then point to homebrew version of bash:"
generic_msg_colour_simple "info"      "Open Mac settings --> Users&Groups --> right-click --> advanced options"
generic_msg_colour_simple "info"      "Change 'login shell' to use /usr/local/bin/bash"
generic_msg_colour_simple "info-bold" "(c) In new terminal repeat step (a)"
generic_msg_colour_simple "info"      "$ bash --version"

printf "%s\n"
