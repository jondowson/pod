function prepare_misc_checkFileFolderExist(){

## test specified files exist

if [[ ${clusterstateFlag} != "true" ]]; then
  # test POD_SOFTWARE folder and dse_tar file are available
  if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
    prepare_generic_misc_checkSoftwareExists
    lib_generic_checks_fileExists   "prepare_misc.bash#1" "true" "${dse_tar_file}"
    lib_generic_checks_fileExists   "prepare_misc.bash#2" "true" "${agent_tar_file}"
  fi
else
  lib_generic_checks_fileExists   "prepare_misc.bash#3" "true" "${suitcase_file_path}"
  lib_generic_checks_fileExists   "prepare_misc.bash#4" "true" "${tmp_build_settings_file_path}"
fi
}

# ------------------------------------------

function prepare_misc_setDefaults(){

## pod specific default settings

# generate new /builds/pod_dse/dse-x.x.x_name/resources' folder - this action will remove any existing one from this build folder !!
REGENERATE_RESOURCES="false"
}
