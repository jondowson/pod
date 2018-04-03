# about:    generic functions executed on remote server

# ---------------------------------------

function lib_generic_doStuff_remotely_bashrc(){

## configure bashrc to source bash_profile everytime a new terminal is started (on ubuntu)

# file to edit
file="${HOME}/.bashrc"
touch ${file}

# search for and remove any pre-canned blocks containing a label:
label="source_bash_rc"
lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# add line sourcing .bashrc
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
if [ -r ~/.bash_profile ]; then source ~/.bash_profile; fi
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}

# ---------------------------------------

function lib_generic_doStuff_remotely_updatePathBashProfile(){

## configure bash_profile to set paths in an idempotent 'manner'

program_home=$(tr [:lower:] [:upper:] <<< "${1}")
soft_exec_path="${2}"

# file to edit
file="${HOME}/.bash_profile"
touch "${file}"

# search for and remove any lines starting with:
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export ${program_home}=" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$${program_home}:\$PATH" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$PATH:\$${program_home}" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="${program_home}_bash_profile"
lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# append to end of files
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
export ${program_home}="${soft_exec_path}"
export PATH=\$${program_home}:\$PATH
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF

## allow pod to be run on this server from any folder and create an alias too

label="POD_HOME_bash_profile"
# search for and remove any pre-canned blocks containing this label
lib_generic_strings_removePodBlockAndEmptyLines ${file} "pod_SETUP@${label}"

cat << EOF >> "${file}"

#>>>>>BEGIN-ADDED-BY__pod_SETUP@${label}
export POD_HOME=${pod_home_path}/
export PATH=\$POD_HOME:\$PATH
alias fpod='cd ${pod_home_path}'
#>>>>>END-ADDED-BY__pod_SETUP@${label}
EOF
}

# ---------------------------------------

function lib_generic_doStuff_remotely_createFolders(){

## create required folders

foldersToMake="${1}"

lib_generic_strings_ifsStringDelimeter ";" "${foldersToMake}"

for i in "${!array[@]}"
do
  value="${array[$i]}"
  mkdir -p "${value}"
done
}

# ---------------------------------------

function lib_generic_doStuff_remotely_unpackTar(){

## unpack tar to the designated folder

file="${1}"
folder="${2}"

tar -xvf "${file}" -C "${folder}"
}
