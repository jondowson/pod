function lib_build_suitcase(){

## add pod specific variables to the suitcase

printf "%s\n" "opscenter_untar_config_folder=${opscenter_untar_config_folder}"   >> "${TMP_FILE_SUITCASE}"
printf "%s\n" "apply_storage_cluster=${apply_storage_cluster}"                   >> "${TMP_FILE_SUITCASE}"
}
