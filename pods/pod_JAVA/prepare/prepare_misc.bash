function prepare_misc_checkFileFolderExist(){

## test file and folders used by this pod exist

# if software tarball is used - then check it exists
if [[ "${software_tarball}" != "" ]]; then
  GENERIC_prepare_misc_checkSoftwareExists
  GENERIC_lib_checks_fileExists "${WHICH_POD}_prepare_misc.bash_messageID:1" "true" "${TAR_FILE}"
fi

# add below any other pod specific file and folder checks
}

# ------------------------------------------

function prepare_misc_setDefaults(){

## pod specific default settings

:
}
