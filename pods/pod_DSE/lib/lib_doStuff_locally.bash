function lib_doStuff_locally_cassandraYaml_cassData(){

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

# select correct version of command based on OS
IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# remove any previous data path(s)
${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"

# insert the new data paths with yaml friendly spacing
for i in "${build_send_data_array[@]}"
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
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export GREMLIN_LOG_DIR=" "dummy"

# search for and remove any pre-canned pod added blocks containing this label
label="define_dse_log_folders"
lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# select correct version of command based on OS
IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# insert to beginning of file
${dynamic_cmd} "1i#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}" ${file}
${dynamic_cmd} "2iexport CASSANDRA_LOG_DIR=${cassandra_log_folder}" ${file}
${dynamic_cmd} "3iexport TOMCAT_LOGS=${tomcat_log_folder}" ${file}
${dynamic_cmd} "4iexport GREMLIN_LOG_DIR=${gremlin_log_folder}i" ${file}
${dynamic_cmd} "5i#>>>>>END-ADDED-BY__${WHICH_POD}@${label}" ${file}

# this helps cqlsh and nodetool connect
lib_generic_strings_sedStringManipulation "removeHashAndLeadingWhitespace"         ${file} '# JVM_OPTS=\"$JVM_OPTS -Djava.rmi.server.hostname=<public name>\"' "dummy"
lib_generic_strings_sedStringManipulation "editAfterSubstring"                     ${file} 'JVM_OPTS=\"$JVM_OPTS -Djava.rmi.server.hostname=' "${pubIp}\""
}

# ---------------------------------------

function lib_doStuff_locally_jvmOptions(){

## jvm.options - set temp folder that has write permissions

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/jvm.options"

# search for and remove any lines starting with:
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "-Djna.tmpdir=" "dummy"

# search for and remove any pre-canned blocks containing this label
label="define_jvm_options"
lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# append to end of file
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
-Djna.tmpdir=${TEMP_FOLDER}
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}

# ---------------------------------------

function lib_doStuff_locally_cassandraRackDcProperties(){

## cassandra-rackdc.properties - configure the rack and data center for this node

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra-rackdc.properties"

lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "dc="   "${dc}"
lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "rack=" "${rack}"
}


# ---------------------------------------

function lib_doStuff_locally_cassandraYaml_buildSettings(){

## cassandra.yaml - configure the 'main' settings set in the build_settings file

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

# hints_directory
lib_generic_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "hints_directory:" "${hints_directory}"
# commitlog_directory
lib_generic_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "commitlog_directory:" "${commitlog_directory}"
# cdc_raw_directory
lib_generic_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "cdc_raw_directory:" "${cdc_raw_directory}"
# saved_caches_directory
lib_generic_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "saved_caches_directory:" "${saved_caches_directory}"
# endpoint_snitch: (nearly always 'GossipingPropertyFileSnitch')
lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "endpoint_snitch:" "${ENDPOINT_SNITCH}"
}

# ---------------------------------------

function lib_doStuff_locally_cassandraYaml_json(){

## cassandra.yaml - set node specific settings from json

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra.yaml"

# select correct version of command based on OS
IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# seeds
${dynamic_cmd} "s?\(-[[:space:]]seeds:\s*\).*\$?\1\"${seeds}\"?"  "${file}"
# listen_address
lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "listen_address:" "${listen_address}"
# rpc_address
lib_generic_strings_sedStringManipulation "editAfterSubstring" "${file}" "rpc_address:" "${rpc_address}"
}

# ---------------------------------------

function lib_doStuff_locally_dseYaml_dsefsData(){

## dse.yaml - configure for dsefs - required by spark

# file to edit
file="${tmp_build_file_folder}resources/dse/conf/dse.yaml"

# search for and remove any pre-canned blocks containing this label
label="define_dsefs_options"
lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# if spark is turned on, then dsefs must also be turned on
if [[ ${mode_analytics} == "true" ]]; then
  mode_dsefs="true"
fi

# add block to define dsefs settings and data folders
cat << EOF >> $file

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
dsefs_options:
      enabled: ${mode_dsefs}
      keyspace_name: dsefs
      work_dir: ${dsefs_folder}
      public_port: 5598
      private_port: 5599
      data_directories:
EOF
# add data folder(s) for dsefs
for i in "${build_send_data_array[@]}"
do
  lib_generic_strings_expansionDelimiter "$i" ";" "2"
  cat << EOF >> $file
          - dir: ${_D1_}
            storage_weight: ${_D2_}
            min_free_space: ${_D3_}
EOF
done
cat << EOF >> $file
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}

# ---------------------------------------

function lib_doStuff_locally_dseSparkEnv(){

## configure dse-spark-env.sh (sourced at end of spark-env.sh) to set paths for log/data files

# file to edit
file="${tmp_build_file_folder}resources/spark/conf/dse-spark-env.sh"

# search for and remove any pre-canned blocks containing this label:
label="define_spark_folders"
lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# select correct version of command based on OS
IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# part [A]
# insert gap at beginning of file (actually 2nd line to avoid any hash-bang)
${dynamic_cmd} '1G' ${file} # insert after first line

lineNumber=3
# part [B]
# insert block on 3nd line to avoid hash-bang
# using double quotes expands variables but overwrites rather than insert
${dynamic_cmd} "${lineNumber}i#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}"                                                             ${file};((lineNumber++))
if [ -n "$spark_local_data" ];           then ${dynamic_cmd} "${lineNumber}iexport SPARK_LOCAL_DIRS=${spark_local_data}"               ${file};((lineNumber++));fi
if [ -n "$spark_worker_data" ];          then ${dynamic_cmd} "${lineNumber}iexport SPARK_WORKER_DIR=${spark_worker_data}"              ${file};((lineNumber++));fi
if [ -n "$spark_executor_folder" ];      then ${dynamic_cmd} "${lineNumber}iexport SPARK_EXECUTOR_DIRS=${spark_executor_folder}"       ${file};((lineNumber++));fi
if [ -n "$spark_worker_log_folder" ];    then ${dynamic_cmd} "${lineNumber}iexport SPARK_WORKER_LOG_DIR=${spark_worker_log_folder}"    ${file};((lineNumber++));fi
if [ -n "$spark_master_log_folder" ];    then ${dynamic_cmd} "${lineNumber}iexport SPARK_MASTER_LOG_DIR=${spark_master_log_folder}"    ${file};((lineNumber++));fi
if [ -n "$spark_alwayson_sql_log_dir" ]; then ${dynamic_cmd} "${lineNumber}iexport ALWAYSON_SQL_LOG_DIR=${spark_alwayson_sql_log_dir}" ${file};((lineNumber++));fi
${dynamic_cmd} "${lineNumber}i#>>>>>END-ADDED-BY__${WHICH_POD}@${label}"                                                               ${file}
}
