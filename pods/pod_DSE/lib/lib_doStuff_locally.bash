# about:     functions executed on local server on files destined for remote servers

# ---------------------------------------

function lib_doStuff_locally_cassandraYamlData(){

## replace existing data directory/directories with new paths

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra.yaml"

# find line number of setting
match=$(sed -n /data_file_directories:/= "${file}")

# define line number range to search for data paths to erase
start=$(($match+1))
finish=$(($start+100)) # unlikely to be close to 100 data paths but increase number if necessary !!
for i in `seq $start $finish`
do
  # search following lines until a '-' is not found as first char
  if [[ ! $(head -$i "${file}" | tail -1 | grep '-') ]]; then
    lastEntry=$(($i-1))
    break;
  fi
done

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# remove previous data path(s)
${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"

# insert the new data paths with yaml friendly spacing
for i in "${data_file_directories_array[@]}"
do
	${dynamic_cmd} "${start}i\    \-\ \ ${i}" "${file}"
	start=$(($start+1))
done
}

# ---------------------------------------

function lib_doStuff_locally_cassandraEnv(){

## utilise if default logging folder does not have access permissions !!

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra-env.sh"
# search for and remove any lines starting with:
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export CASSANDRA_LOG_DIR=" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export TOMCAT_LOGS=" "dummy"

# search for and remove any pre-canned blocks containing this label
label="define_dse_log_folders"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# remove any empty blank lines at end of file
a=$(<$file); printf "%s\n" "$a" > $file

# append to end of file
cat << EOF >> ${file}

#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
export CASSANDRA_LOG_DIR=${cassandra_log_folder}
export TOMCAT_LOGS=${tomcat_log_folder}
export GREMLIN_LOG_DIR=${gremlin_log_folder}
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF

# helps cqlsh and nodetool connect
lib_generic_strings_sedStringManipulation "removeHashAndLeadingWhitespace"         ${file} '# JVM_OPTS=\"$JVM_OPTS -Djava.rmi.server.hostname=<public name>\"' "dummy"
lib_generic_strings_sedStringManipulation "editAfterSubstring"                     ${file} 'JVM_OPTS=\"$JVM_OPTS -Djava.rmi.server.hostname=' "${pubIp}\""
}

# ---------------------------------------

function lib_doStuff_locally_jvmOptions(){

## utilise if default tmpdir does not have access permissions !!

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/jvm.options"

# search for and remove any lines starting with:
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "-Djna.tmpdir=" "dummy"

# search for and remove any pre-canned blocks containing this label
label="define_jvm_options"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# remove any empty blank lines at end of file
a=$(<$file); printf "%s\n" "$a" > $file

# append to end of file
cat << EOF >> ${file}

#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
-Djna.tmpdir=${TEMP_FOLDER}
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF
}

# ---------------------------------------

function lib_doStuff_locally_cassandraRackDcProperties(){

## configure the rack and data center for this node

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra-rackdc.properties"

lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "dc="   "${dc}"
lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "rack=" "${rack}"
}


# ---------------------------------------

function lib_doStuff_locally_cassandraYaml(){

## configure the 'main' settings for the cassandra config file

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra.yaml"

# cluster_name:
lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "cluster_name:" "'${CLUSTER_NAME}'"

# num_tokens:
# allocate_tokens_for_local_replication_factor: 3 (uncomment for vnodes)
if [[ "${VNODES}" == "false" ]]; then
  lib_generic_strings_sedStringManipulation "removeHashAndLeadingWhitespace" "${file}" "initial_token:" "dummy"
  lib_generic_strings_sedStringManipulation "editAfterSubstring"             "${file}" "initial_token:" "${token}"
  lib_generic_strings_sedStringManipulation "hashCommentOutMatchingLine"     "${file}" "num_tokens:" "dummy"
  lib_generic_strings_sedStringManipulation "hashCommentOutMatchingLine"     "${file}" "allocate_tokens_for_local_replication_factor:" "dummy"
 else
  lib_generic_strings_sedStringManipulation "removeHashAndLeadingWhitespace" "${file}" "num_tokens:" "dummy"
  lib_generic_strings_sedStringManipulation "editAfterSubstring"             "${file}" "num_tokens:" "${VNODES}"
  lib_generic_strings_sedStringManipulation "removeHashAndLeadingWhitespace" "${file}" "allocate_tokens_for_local_replication_factor:" "dummy"
  lib_generic_strings_sedStringManipulation "hashCommentOutMatchingLine"     "${file}" "initial_token:" "dummy"
fi

# hints_directory:
lib_generic_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "hints_directory:" "${hints_directory}"

# commitlog_directory:
lib_generic_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "commitlog_directory:" "${commitlog_directory}"

# cdc_raw_directory:
lib_generic_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "cdc_raw_directory:" "${cdc_raw_directory}"

# saved_caches_directory:
lib_generic_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "saved_caches_directory:" "${saved_caches_directory}"

# endpoint_snitch: (nearly always 'GossipingPropertyFileSnitch')
lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "endpoint_snitch:" "${ENDPOINT_SNITCH}"
}

# ---------------------------------------

function lib_doStuff_locally_cassandraYamlNodeSpecific(){

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra.yaml"

# seeds:
IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS
${dynamic_cmd} "s?\(-[[:space:]]seeds:\s*\).*\$?\1\"${seeds}\"?"  "${file}"

# listen_address:
lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "listen_address:" "${listen_address}"

# rpc_address:
lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "rpc_address:" "${rpc_address}"
}

# ---------------------------------------

function lib_doStuff_locally_dseYamlDsefs(){

## configure dse.yaml for dsefs - required by spark

# file to edit
file="${tmp_build_file_folder}resources/dse/conf/dse.yaml"

# search for and remove any pre-canned blocks containing this label
label="define_dsefs_options"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# remove any empty blank lines at end of file
a=$(<$file); printf "%s\n" "$a" > $file

# add block to define dsefs settings and data folders
cat << EOF >> $file

#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
dsefs_options:
      enabled: false
      keyspace_name: dsefs
      work_dir: ${dsefs_folder}
      public_port: 5598
      private_port: 5599
      data_directories:
EOF
# add data folder(s) for dsefs
for i in "${dsefs_data_file_directories_array[@]}"
do
  lib_generic_strings_expansionDelimiter "$i" ";" "2"
  cat << EOF >> $file
          - dir: ${_D1_}
            storage_weight: ${_D2_}
            min_free_space: ${_D3_}
EOF
done
cat << EOF >> $file
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF
}

# ---------------------------------------

function lib_doStuff_locally_dseSparkEnv(){

## configure dse-spark-env.sh (sourced at end of spark-env.sh) to set paths for log/data files

# file to edit
file="${tmp_build_file_folder}resources/spark/conf/dse-spark-env.sh"

# search for and remove any pre-canned blocks containing this label:
label="define_spark_folders"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# search for and remove any lines starting with:
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_WORKER_LOG_DIR=" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_MASTER_LOG_DIR=" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_WORKER_DIR=" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_LOCAL_DIRS=" "dummy"

# remove any empty blank lines at end of file
a=$(<$file); printf "%s\n" "$a" > $file

cat << EOF >> ${file}

#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
export SPARK_WORKER_LOG_DIR="${spark_worker_log_folder}"
export SPARK_MASTER_LOG_DIR="${spark_master_log_folder}"
export SPARK_WORKER_DIR=${spark_worker_data}
export SPARK_LOCAL_DIRS=${spark_local_data}
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF
}
