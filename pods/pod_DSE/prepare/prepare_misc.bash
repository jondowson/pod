function prepare_misc_checkFileFolderExist(){

## test specified files exist

if [[ ${clusterstateFlag} != "true" ]]; then
  # test POD_SOFTWARE folder and dse_tar file are available
  if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
    GENERIC_prepare_misc_checkSoftwareExists
    GENERIC_lib_checks_fileExists   "prepare_misc.bash#1" "true" "${DSE_FILE_TAR}"
    GENERIC_lib_checks_fileExists   "prepare_misc.bash#2" "true" "${AGENT_FILE_TAR}"
  fi
else
  GENERIC_lib_checks_fileExists   "prepare_misc.bash#3" "true" "${SUITCASE_FILE_PATH}"
  GENERIC_lib_checks_fileExists   "prepare_misc.bash#4" "true" "${TMP_FILE_BUILDSETTINGS}"
fi
}
