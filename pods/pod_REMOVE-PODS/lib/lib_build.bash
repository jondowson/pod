function lib_build_suitcase(){

## add pod specific variables to the suitcase

printf "%s\n" "REMOVE_POD=${REMOVE_POD}"   >> "${TMP_FILE_SUITCASE}"
}
