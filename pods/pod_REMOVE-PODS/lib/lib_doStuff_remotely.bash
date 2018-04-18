function lib_doStuff_remotely_pod_REMOVE-PODS(){

## remove this pod on remote machine

# [1] delete any previous pod build folder with the same name + any agent folder of the same version

lib_doStuff_remotely_removeThisPod
lib_doStuff_remotely_removeThisPodFromBashProfile
lib_doStuff_remotely_removeThisPodFromBashrc

# [2] this folder is empty so tidy it up
rm -rf ${INSTALL_FOLDER_POD}
}

# ---------------------------------------

function lib_doStuff_remotely_removeThisPod(){

## remove this pod on remote machine

rm -rf ${INSTALL_FOLDER}${REMOVE_POD}
}

# ---------------------------------------

function lib_doStuff_remotely_removeThisPodFromBashProfile(){

## configure bash_profile to set paths in an idempotent 'manner'

# file to edit
file="${HOME}/.bash_profile"
touch ${file}

WHICH_POD_TMP=${WHICH_POD}
WHICH_POD=${REMOVE_POD}
# search for and remove any pre-canned blocks for this pod - leave label blank:
label=""
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock2" ${file} "${label}" "dummy"
WHICH_POD=${WHICH_POD_TMP}
# remove any empty blank lines at end of file
a=$(<$file); printf "%s\n" "$a" > $file
}

# ---------------------------------------

function lib_doStuff_remotely_removeThisPodFromBashrc(){

## configure bashrc to source bash_profile everytime a new terminal is started (on ubuntu/centos)

# file to edit
file="${HOME}/.bashrc"
touch ${file}

WHICH_POD_TMP=${WHICH_POD}
WHICH_POD=${REMOVE_POD}
# search for and remove any pre-canned blocks for this pod - leave label blank:
label=""
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock2" ${file} "${label}" "dummy"
WHICH_POD=${WHICH_POD_TMP}
}
