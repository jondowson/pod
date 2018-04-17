function lib_build_suitcase(){

## add pod specific variables to the suitcase

printf "%s\n" "opscenter_untar_config_folder=${opscenter_untar_config_folder}"   >> "${tmp_suitcase_file_path}"
printf "%s\n" "apply_storage_cluster=${apply_storage_cluster}"                   >> "${tmp_suitcase_file_path}"
}
