#!/bin/bash

POD_VERSION="1.5.0"
script_name="pod_dependencies.sh"
script_author="JRD"
script_about="install dependencies for the pod application"
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
WHICH_POD="pod_SETUP"

# ////////////////////////////////////////// INSTALL MAC DEPENDENCY MANAGER

if [[ "${os}" == "Mac" ]]; then

  prepare_generic_display_banner
  prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Prepare Mac dependency manager"
  prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1${white} 2 3 4 5 ]${reset}"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Install / update homebrew package manager"

  brewList=$(brew list)

  if [[ $brewList == *"command not found"* ]]; then
    prepare_generic_display_msgColourSimple "ALERT-->" "Installing homebrew"
  else
    prepare_generic_display_msgColourSimple "ALERT-->" "Fetching latest homebrew"
  fi
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  printf "%s\n"

  lib_generic_misc_timecount "5" "Proceeding to next STAGE..."

  # ////////////////////////////////////////// INSTALL PACKAGES

  prepare_generic_display_banner
  prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Install Mac dependencies"
  prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2${white} 3 4 5 ]${reset}"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Install brew packages"

  if [[ $brewList == *"coreutils"* ]]; then
    prepare_generic_display_msgColourSimple "ALERT-->" "Fetching latest core-utils"
    printf "%s\t" "$ brew upgrade coreutils"
    brew upgrade coreutils > /dev/null 2>&1
    printf "%s\n" "${tick}"
  else
    prepare_generic_display_msgColourSimple "ALERT-->" "Installing core-utils"
    printf "%s\t" "$ brew install coreutils"
    brew install coreutils > /dev/null 2>&1
    printf "%s\n" "${tick}"
  fi

  # -----

  if [[ $brewList == *"bash"* ]]; then
    prepare_generic_display_msgColourSimple "ALERT-->" "Fetching latest bash"
    printf "%s\t\t" "$ brew upgrade bash"
    brew upgrade bash > /dev/null 2>&1
    printf "%s\n" "${tick}"
  else
    prepare_generic_display_msgColourSimple "ALERT-->" "Installing bash"
    printf "%s\t\t" "$ brew install bash"
    brew install bash > /dev/null 2>&1
    printf "%s\n" "${tick}"
  fi

  # -----

  if [[ $brewList == *"gnu-sed"* ]]; then
    prepare_generic_display_msgColourSimple "ALERT-->" "Fetching latest gnu-sed"
    printf "%s\t\t" "$ brew upgrade gnu-sed"
    brew upgrade gnu-sed > /dev/null 2>&1
    printf "%s\n" "${tick}"
  else
    prepare_generic_display_msgColourSimple "ALERT-->" "Installing gnu-sed"
    printf "%s\t\t" "$ brew install gnu-sed"
    brew install gnu-sed > /dev/null 2>&1
    printf "%s\n" "${tick}"
  fi

  # -----

  if [[ $brewList == *"iproute2mac"* ]]; then
    prepare_generic_display_msgColourSimple "ALERT-->" "Fetching latest iproute2mac"
    printf "%s\t" "$ brew upgrade iproute2mac"
    brew upgrade iproute2mac > /dev/null 2>&1
    printf "%s\n" "${tick}"
  else
    prepare_generic_display_msgColourSimple "ALERT-->" "Installing iproute2mac"
    printf "%s\t" "$ brew install iproute2mac"
    brew install iproute2mac > /dev/null 2>&1
    printf "%s\n" "${tick}"
  fi

  # -----

  if [[ $brewList == *"awk"* ]]; then
    prepare_generic_display_msgColourSimple "ALERT-->" "Fetching latest awk"
    printf "%s\t\t" "$ brew upgrade awk"
    brew upgrade awk > /dev/null 2>&1
    printf "%s\n" "${tick}"
  else
    prepare_generic_display_msgColourSimple "ALERT-->" "Installing awk"
    printf "%s\t\t" "$ brew install awk"
    brew install awk > /dev/null 2>&1
    printf "%s\n" "${tick}"
  fi

  # -----

  if [[ $brewList == *"jq"* ]]; then
    prepare_generic_display_msgColourSimple "ALERT-->" "Fetching latest jq"
    printf "%s\t\t" "$ brew upgrade jq"
    brew upgrade jq > /dev/null 2>&1
    printf "%s\n" "${tick}"
  else
    prepare_generic_display_msgColourSimple "ALERT-->" "Installing jq"
    printf "%s\t\t" "$ brew install jq"
    brew install jq > /dev/null 2>&1
    printf "%s\n" "${tick}"
  fi

  # -----

  if [[ $brewList == *"ssh-copy-id"* ]]; then
    prepare_generic_display_msgColourSimple "ALERT-->" "Fetching latest ssh-copy-id"
    printf "%s\t" "$ brew upgrade ssh-copy-id"
    brew upgrade ssh-copy-id > /dev/null 2>&1
    printf "%s\n" "${tick}"
  else
    prepare_generic_display_msgColourSimple "ALERT-->" "Installing ssh-copy-id"
    printf "%s\t" "$ brew install ssh-copy-id"
    brew install ssh-copy-id > /dev/null 2>&1
    printf "%s\n" "${tick}"
  fi
  printf "%s\n"
  lib_generic_misc_timecount "5" "Proceeding to next STAGE..."

  # ////////////////////////////////////////// EXPORT MAC JAVA HOME

  prepare_generic_display_banner
  prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Ensure JAVA_HOME is locatable"
  prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3${white} 4 5 ]${reset}"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Export Java Home in bash_profile"

  echo "${b}---> delete any existing labelled block from:  ${yellow}~/.bash_profile${reset}"
  echo "${b}---> add new labelled block to:                ${yellow}~/.bash_profile${reset}"

  file="${HOME}/.bash_profile"
  label="define_java_home"
  # search for and remove any pre-canned blocks containing this label
  lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

  printf "%s\n"
  echo "#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}"
  echo "export JAVA_HOME=\$(/usr/libexec/java_home)"
  echo "#>>>>>END-ADDED-BY__${WHICH_POD}@${label}"

  # remove any empty blank lines at end of file
  a=$(<$file); printf "%s\n" "$a" > $file

cat << EOF >> "${file}"

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
export JAVA_HOME=\$(/usr/libexec/java_home)
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF

  printf "%s\n"
  lib_generic_misc_timecount "5" "Proceeding to next STAGE..."

  # ////////////////////////////////////////// SET POD HOME

  prepare_generic_display_banner
  prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Add pod to path"
  prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4${white} 5 ]${reset}"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Add pod to path so can be run from anywhere"

  echo "${b}---> delete any existing labelled block from:  ${yellow}~/.bash_profile${reset}"
  echo "${b}---> add new labelled block to:                ${yellow}~/.bash_profile${reset}"

  file="${HOME}/.bash_profile"
  label="POD_HOME_bash_profile"
  # search for and remove any pre-canned blocks containing this label
  lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

  printf "%s\n"
  echo "#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}"
  echo "export POD_HOME=${pod_home_path}/"
  echo "export PATH=\$POD_HOME:\$PATH"
  echo "alias fpod='cd ${pod_home_path}'"
  echo "#>>>>>END-ADDED-BY__${WHICH_POD}@${label}"

cat << EOF >> "${file}"

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
export POD_HOME=${pod_home_path}/
export PATH=\$POD_HOME:\$PATH
alias fpod='cd ${pod_home_path}'
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF

  printf "%s\n"
  lib_generic_misc_timecount "5" "Proceeding to next STAGE..."

  # ////////////////////////////////////////// FINISH

  prepare_generic_display_banner
  prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Finish"
  prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2 3 4 5 ${white}]${reset}"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Confirm bash version > 4.0"
  bash --version

  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Confirm homebrew packages"
  brew list

  prepare_generic_display_msgColourSimple "TASK==>"    "Final tasks to complete Mac setup:"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "[1] Confirm above bash version is 4 or greater:"
  prepare_generic_display_msgColourSimple "INFO"      "$ bash --version"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "[2] If not, then point to homebrew version of bash:"
  prepare_generic_display_msgColourSimple "INFO"      "Open Mac settings --> Users&Groups --> right-click --> advanced options"
  prepare_generic_display_msgColourSimple "INFO"      "Change 'login shell' to use /usr/local/bin/bash"
  prepare_generic_display_msgColourSimple "INFO"      "Check version once more: $ bash --version"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "[3] Enable ssh connections"
  prepare_generic_display_msgColourSimple "INFO"      "Open Mac settings --> Sharing"
  prepare_generic_display_msgColourSimple "INFO"      "Tick-box remote-login"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "[4] Source ~/.bash_profile so pod can be run from any folder"
  prepare_generic_display_msgColourSimple "INFO"      "$ . ~/.bash_profile"
  printf "%s\n"

else

  # ////////////////////////////////////////// SET POD HOME

  prepare_generic_display_banner
  prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Add pod to path"
  prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 ${white}2 ]${reset}"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Add pod to path so can be run from anywhere"

  echo "${b}---> delete any existing labelled block from:  ${yellow}~/.bash_profile${reset}"
  echo "${b}---> add new labelled block to:                ${yellow}~/.bash_profile${reset}"

  file="${HOME}/.bash_profile"
  label="POD_HOME_bash_profile"
  # search for and remove any pre-canned blocks containing this label
  lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

  printf "%s\n"
  echo "#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}"
  echo "export POD_HOME=${pod_home_path}/"
  echo "export PATH=\$POD_HOME:\$PATH"
  echo "alias fpod='cd ${pod_home_path}'"
  echo "#>>>>>END-ADDED-BY__${WHICH_POD}@${label}"

cat << EOF >> "${file}"

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
export POD_HOME=${pod_home_path}/
export PATH=\$POD_HOME:\$PATH
alias fpod='cd ${pod_home_path}'
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF

  printf "%s\n"
  lib_generic_misc_timecount "5" "Proceeding to next STAGE..."

  # ////////////////////////////////////////// FINISH

  prepare_generic_display_banner
  prepare_generic_display_msgColourSimple "STAGE"      "STAGE: Finish"
  prepare_generic_display_msgColourSimple "STAGECOUNT" "[ ${cyan}${b}1 2${white} ]${reset}"
  prepare_generic_display_msgColourSimple "TASK==>"    "TASK: Confirm bash version > 4.0"
  bash --version

  prepare_generic_display_msgColourSimple "TASK==>"    "Final task to complete pod setup:"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "[1] Source ~/.bash_profile so pod can be run from any folder"
  prepare_generic_display_msgColourSimple "INFO"      "$ . ~/.bash_profile"
  printf "%s\n"

fi
