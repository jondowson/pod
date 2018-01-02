# author:        jondowson
# about:         functions executed on remote server

# ---------------------------------------

function lib_doStuff_remotely_dseYamlTDE(){

## configure dse.yaml for at rest TDE encryption

# file to edit
file="${INSTALL_FOLDER_POD}${pod_DSE_build_folder}/resources/dse/conf/dse.yaml"

# find line number of setting heading
matchA=$(sed -n /system_info_encryption:/= "${file}")

# search for and remove any pod_DSE-SECURITY pre-canned blocks containing this label
label="system_info_encryption"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# search again for line number of setting
matchB=$(sed -n /system_info_encryption:/= "${file}")

# if there is still a block then it was not added by pod_DSE-SECURITY - so delete it
if [[ "${matchB}" != "" ]]; then
  # define line number range to erase
  start=$(($matchB))
  finish=$(($start+10))
  for i in `seq $start $finish`
  do
    # search following lines until a blankline or commented-oiut line is found
    if [ "$i" == "" ] || [[ "$i" == *"#"* ]]; then
      lastEntry=$(($i-1))
      break;
    fi
  done

  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS

  # remove any previous audit logging options block that was not added by pod_DSE_SECURITY
  ${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"
fi

# insert block to define encryption settings at correct line number
gsed -i "$(($matchA))i #>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'"                  ${file}
gsed -i "$(($matchA+1))i system_info_encryption:"                                       ${file}
gsed -i "$(($matchA+2))i enabled: ${tde_encryption_system_info_enabled}"                ${file}
gsed -i "$(($matchA+3))i cipher_algorithm: ${tde_encryption_cipher_algorithm}"          ${file}
gsed -i "$(($matchA+4))i secret_key_strength: ${tde_encryption_secret_key_strength}"    ${file}
gsed -i "$(($matchA+5))i chunk_length_kb: ${tde_encryption_chunk_length_kb}"            ${file}
gsed -i "$(($matchA+6))i #>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'"                  ${file}
}

# ---------------------------------------

function lib_doStuff_remotely_dseYamlAuditLogging(){

## configure dse.yaml for audit logging

# file to edit
file="${INSTALL_FOLDER_POD}${pod_DSE_build_folder}/resources/dse/conf/dse.yaml"

# find line number of setting heading
matchA=$(sed -n /\#Audit logging options/= "${file}")

# search for and remove any pod_DSE-SECURITY pre-canned blocks containing this label
label="audit_logging_options"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# search again for line number of setting
matchB=$(sed -n /audit_logging_options:/= "${file}")

# if there is still a block then it was not added by pod_DSE-SECURITY - so delete it
if [[ "${matchB}" != "" ]]; then
  # define line number range to erase
  start=$(($matchB))
  finish=$(($start+10))
  for i in `seq $start $finish`
  do
    # search following lines until a blankline is found
    if [ "$i" == "" ] || [[ "$i" == *"#"* ]]; then
      lastEntry=$(($i-1))
      break;
    fi
  done

  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS

  # remove any previous audit logging options block that was not added by pod_DSE_SECURITY
  ${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"
fi

# insert block to define encryption settings at correct line number
gsed -i "$(($matchA+1))i #>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'"               ${file}
gsed -i "$(($matchA+2))i audit_logging_options:"                                       ${file}
gsed -i "$(($matchA+3))i enabled: ${audit_logging_enabled}"                            ${file}
gsed -i "$(($matchA+4))i included_categories: ${audit_logging_included_categories}"    ${file}
gsed -i "$(($matchA+5))i included_keyspaces: ${audit_logging_included_keyspaces}"      ${file}
gsed -i "$(($matchA+6))i #>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'"                 ${file}
}
