# about:    functions that create the bespoke pod build for each server

# ------------------------------------------

function lib_build_suitcase(){

## add pod specific variables to the suitcase

printf "%s\n" "REMOVE_POD=${REMOVE_POD}"   >> "${tmp_suitcase_file_path}"
}
