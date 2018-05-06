function lib_build_suitcase(){

## add pod specific variables to the suitcase

localServer="false"
localServer=$(lib_generic_checks_localIpMatch "${pub_ip}")

# to handle installing pod to a different folder locally (to support short paths for dse 5.0.x)
# point POD_HOME in bash_profile to the original pod location (rather than the replicated pod software folder)
# all this does is ensure that the location of pod that the user runs locally is the original one - avoids confusion!
if [[ "${localServer}" == "true" ]] && [[ "${LOCAL_TARGET_FOLDER}" != "${target_folder}" ]]; then
  printf "%s\n" "bash_path_string=${LOCAL_TARGET_FOLDER}POD_SOFTWARE/POD/pod" >> "${TMP_FILE_SUITCASE}"
else
  printf "%s\n" "bash_path_string=${target_folder}POD_SOFTWARE/POD/pod" >> "${TMP_FILE_SUITCASE}"
fi
}
