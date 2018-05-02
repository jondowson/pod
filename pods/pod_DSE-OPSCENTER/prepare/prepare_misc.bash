function prepare_misc_checkFileFolderExist(){

## test file and folders used by this pod exist

if [[ ${clusterstateFlag} != "true" ]]; then
  # test POD_SOFTWARE folder and opscenter tar file are available
  if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
    prepare_generic_misc_checkSoftwareExists
    lib_generic_checks_fileExists   "prepare_misc.bash#1" "true" "${TAR_FILE}"
  fi
else
  lib_generic_checks_fileExists   "prepare_misc.bash#3" "true" "${suitcase_file_path}"
  lib_generic_checks_fileExists   "prepare_misc.bash#4" "true" "${tmp_build_settings_file_path}"
fi

}

# ------------------------------------------

function prepare_misc_setDefaults(){

## pod specific default settings

:
}
