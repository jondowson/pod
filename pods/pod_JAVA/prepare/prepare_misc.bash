# about:    preperation functions for this pod

# ------------------------------------------

function prepare_misc_checkFileFolderExist(){

## test file and folders used by this pod exist

# if software tarball is used - then check it exists
if [[ "${SOFTWARE_TARBALL}" != "" ]]; then
  prepare_generic_misc_checkSoftwareExists
  lib_generic_checks_fileExists "${WHICH_POD}_prepare_misc.bash_messageID:1" "true" "${SOFTWARE_TARBALL}"
fi

# add below any other pod specific file and folder checks
}

# ------------------------------------------

function prepare_misc_setDefaults(){

## pod specific default settings

:
}
