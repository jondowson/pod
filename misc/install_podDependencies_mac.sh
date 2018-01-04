#!/bin/bash

POD_VERSION="1.3.1"
script_name="install_podDependencies_mac.sh"
script_author="jondowson"
script_about="install mac dependencies for the pod application"
script_start=$(date +%s)


# ////////////////////////////////////////// DISCOVER PATHS


## determine this scripts' folder path

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
pod_home_path="$(cd ../; pwd)"


# ////////////////////////////////////////// GENERIC PREPERATION (pod_)


## generic pod_ preparation

# source generic pod_ preperation script
source ${pod_home_path}/pods/pod_/prepare/prepare_generic_misc.bash
# identify local os
prepare_generic_misc_identifyOs
# source all generic pod_ scripts
prepare_generic_misc_sourceGeneric
# set all generic pod_ default settings
prepare_generic_misc_setDefaults
WHICH_POD="pod_MAC-SETUP"

# ////////////////////////////////////////// INSTALL MAC DEPENDENCY MANAGER


lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Prepare Mac dependency manager"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1${white} 2 3 4 ]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Install / update homebrew package manager"

brewList=$(brew list)

if [[ $brewList == *"command not found"* ]]; then
  lib_generic_display_msgColourSimple "alert" "Installing homebrew"
else
  lib_generic_display_msgColourSimple "alert" "Fetching latest homebrew"
fi
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
printf "%s\n"

lib_generic_misc_timecount "5" "Proceeding to next STAGE..."

# ////////////////////////////////////////// INSTALL PACKAGES

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Install Mac dependencies"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2${white} 3 4 ]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Install brew packages"

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
  printf "%s\t" "$ brew upgrade iproute2mac"
  brew upgrade iproute2mac > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  lib_generic_display_msgColourSimple "alert" "Installing iproute2mac"
  printf "%s\t" "$ brew install iproute2mac"
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
  printf "%s\t" "$ brew upgrade ssh-copy-id"
  brew upgrade ssh-copy-id > /dev/null 2>&1
  printf "%s\n" "${tick}"
else
  lib_generic_display_msgColourSimple "alert" "Installing ssh-copy-id"
  printf "%s\t" "$ brew install ssh-copy-id"
  brew install ssh-copy-id > /dev/null 2>&1
  printf "%s\n" "${tick}"
fi
printf "%s\n"
lib_generic_misc_timecount "5" "Proceeding to next STAGE..."

# ////////////////////////////////////////// EXPORT MAC JAVA HOME

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Ensure JAVA_HOME is locatable"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3${white} 4 ]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Export Java Home in bash_profile"

echo "${b}---> delete any existing labelled block from:  ${yellow}~/.bash_profile${reset}"
echo "${b}---> add new labelled block to:                ${yellow}~/.bash_profile${reset}"
printf "%s\n"
echo "#>>>>> BEGIN-ADDED-BY__'pod_MAC-SETUP@define_java_home'"
echo "export JAVA_HOME=\$(/usr/libexec/java_home)"
echo "#>>>>> END-ADDED-BY__'pod_MAC-SETUP@define_java_home'"

file="${HOME}/.bash_profile"
# search for and remove any pre-canned blocks containing this label
label="define_java_home"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" "${file}" "${label}" "dummy"

# remove any empty blank lines at end of file
a=$(<$file); printf "%s\n" "$a" > $file

cat << EOF >> "${file}"

#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
export JAVA_HOME=\$(/usr/libexec/java_home)
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF

printf "%s\n"
lib_generic_misc_timecount "5" "Proceeding to next STAGE..."

# ////////////////////////////////////////// FINISH

lib_generic_display_banner
lib_generic_display_msgColourSimple "STAGE"      "STAGE: Finish"
lib_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 ${white}]${reset}"
lib_generic_display_msgColourSimple "TASK==>"    "TASK: Confirm bash version > 4.0"
bash --version

lib_generic_display_msgColourSimple "TASK==>"    "TASK: Confirm homebrew packages"
brew list

lib_generic_display_msgColourSimple "TASK==>"    "Final tasks to complete Mac setup:"
lib_generic_display_msgColourSimple "INFO-BOLD" "[1] Confirm above bash version is 4 or greater:"
lib_generic_display_msgColourSimple "INFO-BOLD" "[2] If not, then point to homebrew version of bash:"
lib_generic_display_msgColourSimple "INFO"      "Open Mac settings --> Users&Groups --> right-click --> advanced options"
lib_generic_display_msgColourSimple "INFO"      "Change 'login shell' to use /usr/local/bin/bash"
lib_generic_display_msgColourSimple "INFO"      "Check version once more: $ bash --version"
lib_generic_display_msgColourSimple "INFO-BOLD" "[3] Enable ssh connections"
lib_generic_display_msgColourSimple "INFO"      "Open Mac settings --> Sharing"
lib_generic_display_msgColourSimple "INFO"      "Tick-box remote-login"
printf "%s\n"
