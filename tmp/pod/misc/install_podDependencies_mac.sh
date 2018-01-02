#!/bin/bash

# author:       jondowson
# about:        install mac dependencies for the pod application

# ------------------------------------------

# uncomment to see full bash trace (debug)
# set -x

# ------------------------------------------

## determine this scripts' folder path

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
pod_home_path="$(cd ../; pwd)"

# ------------------------------------------

## source dse-setup lib scripts

# source lib folder scripts
files="$(find ${pod_home_path}/pods/pod_/lib -name "*.bash*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

# source prepare folder scripts
files="$(find ${pod_home_path}/pods/pod_/prepare -name "*.bash*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

#========================================== START!!

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Prepare Mac for pod"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1${white} 2 ]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Install brew packages"

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

# -----

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

# -----

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

# -----

if [[ $brewList == *"iproute2mac"* ]]; then
  lib_generic_display_msgColourSimple "alert" "Fetching latest iproute2mac"
  printf "%s\t\t" "$ brew upgrade iproute2mac"
  brew upgrade iproute2mac > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  lib_generic_display_msgColourSimple "alert" "Installing iproute2mac"
  printf "%s\t\t" "$ brew install iproute2mac"
  brew install iproute2mac > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi

# -----

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

# -----

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

# -----

if [[ $brewList == *"ssh-copy-id"* ]]; then
  lib_generic_display_msgColourSimple "alert" "Fetching latest ssh-copy-id"
  printf "%s\t\t" "$ brew upgrade ssh-copy-id"
  brew upgrade ssh-copy-id > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  lib_generic_display_msgColourSimple "alert" "Installing ssh-copy-id"
  printf "%s\t\t" "$ brew install ssh-copy-id"
  brew install ssh-copy-id > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi

# ------------------------------------------

file="~/.bash_profile"
# search for and remove any pre-canned blocks containing this label
label="define_java_home"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" "${file}" "${label}" "dummy"

cat << EOF >> "${file}"
#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
echo "export JAVA_HOME=\$(/usr/libexec/java_home)"
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF
done

# ------------------------------------------

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Summary"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 ${white}]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Confirm bash version"
printf "%s\n"
lib_generic_display_msgColourSimple "alert" "Homebrew installed packages:"
lib_generic_display_msgColourSimple "info"  "$ brew list"
brew list
printf "%s\n"
lib_generic_display_msgColourSimple "TASK==>"    "Final tasks to complete Mac setup:"
lib_generic_display_msgColourSimple "INFO-BOLD" "[1] In terminal check bash is version 4 or greater:"
lib_generic_display_msgColourSimple "INFO"      "$ bash --version"
lib_generic_display_msgColourSimple "INFO-BOLD" "[2] If not, then point to homebrew version of bash:"
lib_generic_display_msgColourSimple "INFO"      "Open Mac settings --> Users&Groups --> right-click --> advanced options"
lib_generic_display_msgColourSimple "INFO"      "Change 'login shell' to use /usr/local/bin/bash"
lib_generic_display_msgColourSimple "INFO-BOLD" "[3] In new terminal repeat step [1] to confirm"
lib_generic_display_msgColourSimple "INFO"      "$ bash --version"
lib_generic_display_msgColourSimple "INFO-BOLD" "[4] Enable ssh connections"
lib_generic_display_msgColourSimple "INFO"      "Open Mac settings --> Sharing"
lib_generic_display_msgColourSimple "INFO"      "Tick-box remote-login"
printf "%s\n"