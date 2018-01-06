# about:         functions executed on remote server

# ---------------------------------------

function lib_doStuff_remotely_dseYamlTDE(){

## configure dse.yaml for at rest TDE encryption

# file to edit
file="${config_folder_dseYaml}dse.yaml"

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
unset IFS

# find line number of setting heading
matchA=$(${dynamic_cmd} /\#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'/= "${file}")

# search for and remove any pod_DSE-SECURITY pre-canned blocks containing this label
label="tde_encryption"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# search again for line number of setting
matchB=$(${dynamic_cmd} /system_info_encryption:/= "${file}")

# if there is still a block then it was not added by pod_DSE-SECURITY - so delete it
if [[ "${matchB}" != "" ]]; then
  # define line number range to erase
  start=$(($matchB))
  finish=$(($start+10))
  matchC=${matchB}
  for i in `seq $start $finish`
  do
    compare=$(${dynamic_cmd} ${i}p ${file})
    # search following lines until a blankline or commented-out line is found
    if [ "$compare" == "" ] || [[ "$compare" == *"#"* ]]; then
      lastEntry=$(($i-1))
      break;
    fi
  done
  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS
  # remove any previous audit logging options block that was not added by pod_DSE_SECURITY
  ${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"
else
  matchC=${matchA}
fi

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS
# insert block to define encryption settings at correct line number
${dynamic_cmd} "$(($matchC))i #>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'"                       ${file}
${dynamic_cmd} "$(($matchC+1))i system_info_encryption:"                                            ${file}
${dynamic_cmd} "$(($matchC+2))i \    enabled: ${tde_encryption_system_info_enabled}"                ${file}
${dynamic_cmd} "$(($matchC+3))i \    cipher_algorithm: ${tde_encryption_cipher_algorithm}"          ${file}
${dynamic_cmd} "$(($matchC+4))i \    secret_key_strength: ${tde_encryption_secret_key_strength}"    ${file}
${dynamic_cmd} "$(($matchC+5))i \    chunk_length_kb: ${tde_encryption_chunk_length_kb}"            ${file}
${dynamic_cmd} "$(($matchC+6))i #>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'"                       ${file}
}

# ---------------------------------------

function lib_doStuff_remotely_dseYamlAuditLogging(){

## configure dse.yaml for audit logging

# file to edit
file="${config_folder_dseYaml}dse.yaml"

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
unset IFS

# find line number of setting heading
matchA=$(${dynamic_cmd} /\#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'/= "${file}")

# search for and remove any pod_DSE-SECURITY pre-canned blocks containing this label
label="audit_logging"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# search again for line number of setting
matchB=$(${dynamic_cmd} /audit_logging_options:/= "${file}")

# if there is still a block then it was not added by pod_DSE-SECURITY - so delete it
if [[ "${matchB}" != "" ]]; then
  # define line number range to erase
  start=$(($matchB))
  finish=$(($start+10))
  matchC=${matchB}
  for i in `seq $start $finish`
  do
    compare=$(${dynamic_cmd} ${i}p ${file})
    # search following lines until a blankline or commented-out line is found
    if [ "$compare" == "" ] || [[ "$compare" == *"#"* ]]; then
      lastEntry=$(($i-1))
      break;
    fi
  done
  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS
  # remove any previous audit logging options block that was not added by pod_DSE_SECURITY
  ${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"
else
  matchC=${matchA}
fi

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS
# insert block to define encryption settings at correct line number
${dynamic_cmd} "$(($matchC))i #>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'"                     ${file}
${dynamic_cmd} "$(($matchC+1))i audit_logging_options:"                                           ${file}
${dynamic_cmd} "$(($matchC+2))i \    enabled: ${audit_logging_enabled}"                           ${file}
${dynamic_cmd} "$(($matchC+3))i \    included_categories: ${audit_logging_included_categories}"   ${file}
${dynamic_cmd} "$(($matchC+4))i \    included_keyspaces: ${audit_logging_included_keyspaces}"     ${file}
${dynamic_cmd} "$(($matchC+5))i #>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'"                     ${file}
}

# ---------------------------------------
