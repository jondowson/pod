function prepare_misc_checkFileFolderExist(){

## test file and folders used by this pod exist

# if software tarball is used - then check it exists
if [[ "${SOFTWARE_TARBALL}" != "" ]]; then
  prepare_generic_misc_checkSoftwareExists
fi

# add below any other pod specific file and folder checks
}

# ------------------------------------------

function prepare_misc_setDefaults(){

## pod specific default settings

:
}
