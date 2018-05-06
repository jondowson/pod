function prepare_misc_checkFileFolderExist(){

## test file and folders used by this pod exist

if [[ ${clusterstateFlag} != "true" ]]; then
  # test POD_SOFTWARE folder and opscenter tar file are available
  if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
    GENERIC_prepare_misc_checkSoftwareExists
    GENERIC_lib_checks_fileExists   "prepare_misc.bash#1" "true" "${TAR_FILE}"
  fi
else
  GENERIC_lib_checks_fileExists   "prepare_misc.bash#3" "true" "${SUITCASE_FILE_PATH}"
  GENERIC_lib_checks_fileExists   "prepare_misc.bash#4" "true" "${TMP_FILE_BUILDSETTINGS}"
fi

}

# ------------------------------------------

function prepare_misc_setDefaults(){

## pod specific default settings

:
}
