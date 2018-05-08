function lib_build_suitcase(){

## add pod specific variables to the suitcase

printf "%s\n" "OPSCENTER_FOLDER_UNTAR_CONFIG=${OPSCENTER_FOLDER_UNTAR_CONFIG}"   >> "${TMP_FILE_SUITCASE}"
printf "%s\n" "apply_storage_cluster=${apply_storage_cluster}"                   >> "${TMP_FILE_SUITCASE}"
}
