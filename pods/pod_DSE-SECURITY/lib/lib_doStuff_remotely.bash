# about:         functions executed on remote server

# ---------------------------------------

function lib_doStuff_remotely_dseYamlTDE(){

## configure dse.yaml for at rest TDE encryption

# file to edit
file="${config_folder_dseYaml}dse.yaml"
label="tde_encryption"

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
unset IFS

# find line number of pod_DSE_SECURITY block
matchA=$(${dynamic_cmd} /\#\>\>\>\>\>\ BEGIN-ADDED-BY__\'${WHICH_POD}@${label}\'/= "${file}")
# search for and remove any pod_DSE-SECURITY pre-canned blocks containing this label
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"
# search again for line number of setting
matchB=$(${dynamic_cmd} /system_info_encryption:/= "${file}")

# if there is still a block then it was not added by pod_DSE-SECURITY - so delete it
if [[ "${matchB}" != "" ]]; then
  # define line number range to erase
  start=$(($matchB))
  finish=$(($start+30))
  for i in `seq $start $finish`
  do
    # grab 1st char from this line
    lineContent=$(${dynamic_cmd} ${i}p ${file})
    # search following lines until a blankline or commented-out line is found
    if [ "${lineContent}" == "" ]; then
      lastEntry=$(($i-1))
      break;
    fi
  done
  # remove any previous audit logging options block that was not added by pod_DSE_SECURITY
  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS
  ${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"
  matchC=${matchB}
else
  matchC=${matchA}
fi

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS
# insert block to define encryption settings at correct line number
${dynamic_cmd} "$(($matchC))i #>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'"            ${file}
${dynamic_cmd} "$(($matchC+1))i system_info_encryption:"                                 ${file}
${dynamic_cmd} "$(($matchC+2))i \    enabled: ${tde_system_info_enabled}"                ${file}
${dynamic_cmd} "$(($matchC+3))i \    cipher_algorithm: ${tde_cipher_algorithm}"          ${file}
${dynamic_cmd} "$(($matchC+4))i \    secret_key_strength: ${tde_secret_key_strength}"    ${file}
${dynamic_cmd} "$(($matchC+5))i \    chunk_length_kb: ${tde_chunk_length_kb}"            ${file}
${dynamic_cmd} "$(($matchC+6))i #>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'"            ${file}
}

# ---------------------------------------

function lib_doStuff_remotely_dseYamlSystemKeyDirectory(){

## configure dse.yaml for location of system + application encryption keys

# file to edit
file="${config_folder_dseYaml}dse.yaml"
label="system_key_directory"

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
unset IFS

# find line number of pod_DSE_SECURITY block
matchA=$(${dynamic_cmd} /\#\>\>\>\>\>\ BEGIN-ADDED-BY__\'${WHICH_POD}@${label}\'/= "${file}")
# search for and remove any pod_DSE-SECURITY pre-canned blocks containing this label
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"
# search again for line number of setting
matchB=$(${dynamic_cmd} /system_key_directory:/= "${file}")

# if there is still a block then it was not added by pod_DSE-SECURITY - so delete it
if [[ "${matchB}" != "" ]]; then
  # define line number range to erase
  start=$(($matchB))
  finish=$(($start+30))
  for i in `seq $start $finish`
  do
    # grab 1st char from this line
    lineContent=$(${dynamic_cmd} ${i}p ${file})
    # search following lines until a blankline or commented-out line is found
    if [[ -z $linecontent ]] || [ $lineContent == "" ] || [ $lineContent == "#" ]; then
      lastEntry=$(($i-1))
      break;
    fi
  done
  # remove any previous setitng that was not added by pod_DSE-SECURITY
  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS
  ${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"
  matchC=${matchB}
else
  matchC=${matchA}
fi

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS
# insert block to define encryption settings at correct line number
${dynamic_cmd} "$(($matchC))i #>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'"            ${file}
${dynamic_cmd} "$(($matchC+1))i system_key_directory: ${system_key_directory}"           ${file}
${dynamic_cmd} "$(($matchC+2))i #>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'"            ${file}
}

# ---------------------------------------

function lib_doStuff_remotely_dseYamlAuditLogging(){

## configure dse.yaml for audit logging

# file to edit
file="${config_folder_dseYaml}dse.yaml"
label="audit_logging"

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
unset IFS

# find line number of setting heading
matchA=$(${dynamic_cmd} /\#\>\>\>\>\>\ BEGIN-ADDED-BY__\'${WHICH_POD}@${label}\'/= "${file}")
# search for and remove any pod_DSE-SECURITY pre-canned blocks containing this label
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"
# search again for line number of setting
matchB=$(${dynamic_cmd} /audit_logging_options:/= "${file}")

# if there is still a block then it was not added by pod_DSE-SECURITY - so delete it
if [[ "${matchB}" != "" ]]; then
  # define line number range to erase
  start=$(($matchB))
  finish=$(($start+30))
  for i in `seq $start $finish`
  do
    # grab 1st char from this line
    lineContent=$(${dynamic_cmd} ${i}p ${file})
    # search following lines until a blankline or commented-out line is found
    if [ "${lineContent}" == "" ]; then
      lastEntry=$(($i-1))
      break;
    fi
  done
  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS
  # remove any previous audit logging options block that was NOT added by pod_DSE_SECURITY
  ${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"
  matchC=${matchB}
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

function lib_doStuff_remotely_cassandraYamlServerEncryption(){

## configure cassandra.yaml for server encryption

# file to edit
file="${config_folder_cassandraYaml}cassandra.yaml"
label="server_encryption"

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
unset IFS

# find line number of setting heading
matchA=$(${dynamic_cmd} /\#\>\>\>\>\>\ BEGIN-ADDED-BY__\'${WHICH_POD}@${label}\'/= "${file}")
# search for and remove any pod_DSE-SECURITY pre-canned blocks containing this label
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"
# search again for line number of setting
matchB=$(${dynamic_cmd} /server_encryption_options:/= "${file}")

# if there is still a block then it was not added by pod_DSE-SECURITY - so delete it
if [[ "${matchB}" != "" ]]; then
  # define line number range to erase
  start=$(($matchB))
  finish=$(($start+30))
  for i in `seq $start $finish`
  do
    # grab content of line
    lineContent=$(${dynamic_cmd} ${i}p ${file})
    # search following lines until a blankline or commented-out line is found
    if [ "${lineContent}" == "" ]; then
      lastEntry=$(($i-1))
      break;
    fi
  done
  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS
  # remove any previous audit logging options block that was NOT added by pod_DSE_SECURITY
  ${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"
  matchC=${matchB}
else
  matchC=${matchA}
fi

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# insert block to define encryption settings at correct line number
${dynamic_cmd} "$(($matchC))i #>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'"             ${file}
${dynamic_cmd} "$(($matchC+1))i server_encryption_options:"                               ${file}
${dynamic_cmd} "$(($matchC+2))i \    internode_encryption: ${se_internode_encryption}"    ${file}
${dynamic_cmd} "$(($matchC+3))i \    keystore: ${se_keystore}"                            ${file}
${dynamic_cmd} "$(($matchC+4))i \    keystore_password: ${se_keystore_password}"          ${file}
${dynamic_cmd} "$(($matchC+5))i \    truststore: ${se_truststore}"                        ${file}
${dynamic_cmd} "$(($matchC+6))i \    truststore_password: ${se_truststore_password}"      ${file}
nextLine="7"
# optional adnaced options - check if set
if [ ${se_protocol} ];            then ${dynamic_cmd} "$(($matchC+$nextLine))i \    protocol: ${se_protocol}"                         ${file} && nextLine="$(($nextLine+1))"; fi
if [ ${se_algorithm} ];           then ${dynamic_cmd} "$(($matchC+$nextLine))i \    algorithm: ${se_algorithm}"                       ${file} && nextLine="$(($nextLine+1))"; fi
if [ ${se_store_type} ];          then ${dynamic_cmd} "$(($matchC+$nextLine))i \    store_type: ${se_store_type}"                     ${file} && nextLine="$(($nextLine+1))"; fi
if [ ${se_cipher_suites} ];       then ${dynamic_cmd} "$(($matchC+$nextLine))i \    cipher_suites: ${se_cipher_suites}"               ${file} && nextLine="$(($nextLine+1))"; fi
if [ ${se_require_client_auth} ]; then ${dynamic_cmd} "$(($matchC+$nextLine))i \    require_client_auth: ${se_require_client_auth}"   ${file} && nextLine="$(($nextLine+1))"; fi
if [ ${se_require_endpoint_verification} ]; then ${dynamic_cmd} "$(($matchC+$nextLine))i \    require_endpoint_verification: ${se_require_endpoint_verification}" ${file} && nextLine="$(($nextLine+1))"; fi
${dynamic_cmd} "$(($matchC+$nextLine))i #>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'"     ${file}
}

# ---------------------------------------

function lib_doStuff_remotely_cassandraYamlClientEncryption(){

## configure cassandra.yaml for server encryption

# file to edit
file="${config_folder_cassandraYaml}cassandra.yaml"
label="client_encryption"

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
unset IFS

# find line number of setting heading
matchA=$(${dynamic_cmd} /\#\>\>\>\>\>\ BEGIN-ADDED-BY__\'${WHICH_POD}@${label}\'/= "${file}")
# search for and remove any pod_DSE-SECURITY pre-canned blocks containing this label
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"
# search again for line number of setting
matchB=$(${dynamic_cmd} /client_encryption_options:/= "${file}")

# if there is still a block then it was not added by pod_DSE-SECURITY - so delete it
if [[ "${matchB}" != "" ]]; then
  # define line number range to erase
  start=$(($matchB))
  finish=$(($start+30))
  for i in `seq $start $finish`
  do
    # grab content of line
    lineContent=$(${dynamic_cmd} ${i}p ${file})
    # search following lines until a blankline or commented-out line is found
    if [ "${lineContent}" == "" ]; then
      lastEntry=$(($i-1))
      break;
    fi
  done
  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS
  # remove any previous audit logging options block that was NOT added by pod_DSE_SECURITY
  ${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"
  matchC=${matchB}
else
  matchC=${matchA}
fi

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# insert block to define encryption settings at correct line number
${dynamic_cmd} "$(($matchC))i #>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'"             ${file}
${dynamic_cmd} "$(($matchC+1))i client_encryption_options:"                               ${file}
${dynamic_cmd} "$(($matchC+2))i \    enabled:  ${ce_enabled}"                             ${file}
${dynamic_cmd} "$(($matchC+3))i \    optional: ${ce_optional}"                            ${file}
${dynamic_cmd} "$(($matchC+4))i \    keystore: ${ce_keystore}"                            ${file}
${dynamic_cmd} "$(($matchC+5))i \    keystore_password: ${ce_keystore_password}"          ${file}
${dynamic_cmd} "$(($matchC+6))i \    require_client_auth: ${ce_require_client_auth}"      ${file}
${dynamic_cmd} "$(($matchC+7))i \    truststore: ${ce_truststore}"                        ${file}
${dynamic_cmd} "$(($matchC+8))i \    truststore_password: ${ce_truststore_password}"      ${file}
nextLine="9"
# optional adnaced options - check if set
if [ ${ce_protocol} ];            then ${dynamic_cmd} "$(($matchC+$nextLine))i \    protocol: ${ce_protocol}"                         ${file} && nextLine="$(($nextLine+1))"; fi
if [ ${ce_algorithm} ];           then ${dynamic_cmd} "$(($matchC+$nextLine))i \    algorithm: ${ce_algorithm}"                       ${file} && nextLine="$(($nextLine+1))"; fi
if [ ${ce_store_type} ];          then ${dynamic_cmd} "$(($matchC+$nextLine))i \    store_type: ${ce_store_type}"                     ${file} && nextLine="$(($nextLine+1))"; fi
if [ ${ce_cipher_suites} ];       then ${dynamic_cmd} "$(($matchC+$nextLine))i \    cipher_suites: ${ce_cipher_suites}"               ${file} && nextLine="$(($nextLine+1))"; fi
${dynamic_cmd} "$(($matchC+$nextLine))i #>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'"     ${file}
}

# ---------------------------------------

function lib_doStuff_remotely_dsetoolCreateSystemKey(){

key_name="${1}"

# add trailing '/' to path if not present
system_key_directory="$(lib_generic_strings_addTrailingSlash ${system_key_directory})"

# move any existing key with this name to a backup file
if [[ -f ${system_key_directory}${key_name} ]]; then
  timestamp=$(lib_generic_misc_timestamp)
  mv ${system_key_directory}${key_name} ${system_key_directory}${key_name}_backup_${timestamp}
fi

# source profile so dsetool command is found
source ~/.bash_profile
# generate a key into the system_key_directory (specified in build_settings.bash / dse.yaml)
dsetool createsystemkey AES/ECB/PKCS5Padding 256 ${key_name}       # don't wrap in quotes !!
chmod 600 ${system_key_directory}${key_name}
}
