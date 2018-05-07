function GENERIC_lib_doStuffRemotely_identifyOs(){

## determine remote os by running a pod script on the remote server

remote_os=$(ssh -q -o Forwardx11=no ${user}@${pub_ip} 'bash -s'  < ${podHomePath}/pods/pod_/scripts/GENERIC_scripts_identifyOs.sh)
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_bashrc(){

## configure bashrc to source bash_profile everytime a new terminal is started (on ubuntu)

# file to edit
file="${HOME}/.bashrc"
touch ${file}

# search for and remove any pre-canned blocks containing a label:
label="source_bash_rc"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "pod_SETUP@${label}"

# add line sourcing .bashrc
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__pod_SETUP@${label}
if [ -r ~/.bash_profile ]; then source ~/.bash_profile; fi
#>>>>>END-ADDED-BY__pod_SETUP@${label}
EOF
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_updateAppBashProfile(){

## configure bash_profile to set paths in an idempotent 'manner'

program_home=$(tr [:lower:] [:upper:] <<< "${1}")
soft_exec_path="${2}"

# file to edit
file="${HOME}/.bash_profile"
touch "${file}"

# search for and remove any lines starting with:
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export ${program_home}=" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$${program_home}:\$PATH" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$PATH:\$${program_home}" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="${program_home}_bash_profile"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# append to end of files
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
export ${program_home}="${soft_exec_path}"
export PATH=\$${program_home}:\$PATH
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_updatePodBashProfile(){

## configure bash_profile to set paths in an idempotent 'manner'

program_home=$(tr [:lower:] [:upper:] <<< "${1}")
pod_exec_path="${2}"

# file to edit
file="${HOME}/.bash_profile"
touch "${file}"

# search for and remove any lines starting with:
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export ${program_home}=" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$${program_home}:\$PATH" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$PATH:\$${program_home}" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="${program_home}_bash_profile"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "pod_SETUP@${label}"

## allow pod to be run on this server from any folder and create an alias too
cat << EOF >> "${file}"

#>>>>>BEGIN-ADDED-BY__pod_SETUP@${label}
export POD_HOME=${pod_exec_path}/
export PATH=\$POD_HOME:\$PATH
alias fpod='cd ${pod_exec_path}'
#>>>>>END-ADDED-BY__pod_SETUP@${label}
EOF
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_createFolders(){

## create required folders

foldersToMake="${1}"

GENERIC_lib_strings_ifsStringDelimeter ";" "${foldersToMake}"

for i in "${!array[@]}"
do
  value="${array[$i]}"
  mkdir -p "${value}"
done
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_unpackTar(){

## unpack tar to the designated folder

file="${1}"
folder="${2}"

tar -xvf "${file}" -C "${folder}"
}
