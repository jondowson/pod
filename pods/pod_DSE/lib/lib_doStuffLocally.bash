function lib_doStuffLocally_cassandraYaml_cassData(){

## replace existing data directory/directories with new paths

# file to edit
file="${TMP_FOLDER_BUILDFILE}resources/cassandra/conf/cassandra.yaml"

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
dynamic_cmd="$(GENERIC_lib_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# remove any previous data path(s)
${dynamic_cmd} "${file}" -re "${start},${lastEntry}d"

# insert the new data paths with yaml friendly spacing
for i in "${arrayBuildSendData[@]}"
do
	${dynamic_cmd} "${start}i\    \-\ \ ${i}" "${file}"
	start=$(($start+1))
done
}

# ---------------------------------------

function lib_doStuffLocally_cassandraEnv(){

## utilise if default logging folder does not have access permissions !!

# file to edit
file="${TMP_FOLDER_BUILDFILE}resources/cassandra/conf/cassandra-env.sh"
# search for and remove any lines starting with:
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export CASSANDRA_LOG_DIR=" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export TOMCAT_LOGS=" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export GREMLIN_LOG_DIR=" "dummy"

# search for and remove any pre-canned pod added blocks containing this label
label="define_dse_log_folders"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# select correct version of command based on OS
IFS='%'
dynamic_cmd="$(GENERIC_lib_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# insert to beginning of file
${dynamic_cmd} "1i#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}" ${file}
${dynamic_cmd} "2iexport CASSANDRA_LOG_DIR=${CASSANDRA_FOLDER_LOG}" ${file}
${dynamic_cmd} "3iexport TOMCAT_LOGS=${TOMCAT_FOLDER_LOG}" ${file}
${dynamic_cmd} "4iexport GREMLIN_LOG_DIR=${GREMLIN_FOLDER_LOG}i" ${file}
${dynamic_cmd} "5i#>>>>>END-ADDED-BY__${WHICH_POD}@${label}" ${file}

# this helps cqlsh and nodetool connect
GENERIC_lib_strings_sedStringManipulation "removeHashAndLeadingWhitespace"         ${file} '# JVM_OPTS=\"$JVM_OPTS -Djava.rmi.server.hostname=<public name>\"' "dummy"
GENERIC_lib_strings_sedStringManipulation "editAfterSubstring"                     ${file} 'JVM_OPTS=\"$JVM_OPTS -Djava.rmi.server.hostname=' "${pub_ip}\""
}

# ---------------------------------------

function lib_doStuffLocally_jvmOptions(){

## jvm.options - set temp folder that has write permissions

# file to edit
file="${TMP_FOLDER_BUILDFILE}resources/cassandra/conf/jvm.options"

# search for and remove any lines starting with:
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "-Djna.tmpdir=" "dummy"

# search for and remove any pre-canned blocks containing this label
label="define_jvm_options"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# append to end of file
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
-Djna.tmpdir=${temp_folder}
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}

# ---------------------------------------

function lib_doStuffLocally_cassandraRackDcProperties(){

## cassandra-rackdc.properties - configure the rack and data center for this node

# file to edit
file="${TMP_FOLDER_BUILDFILE}resources/cassandra/conf/cassandra-rackdc.properties"

GENERIC_lib_strings_sedStringManipulation "editAfterSubstring" "${file}" "dc="   "${dc}"
GENERIC_lib_strings_sedStringManipulation "editAfterSubstring" "${file}" "rack=" "${rack}"
}


# ---------------------------------------

function lib_doStuffLocally_cassandraYaml_buildSettings(){

## cassandra.yaml - configure the 'main' settings set in the build_settings file

# file to edit
file="${TMP_FOLDER_BUILDFILE}resources/cassandra/conf/cassandra.yaml"

# cluster_name:
GENERIC_lib_strings_sedStringManipulation "editAfterSubstring" "${file}" "cluster_name:" "'${cluster_name}'"

# num_tokens:
# allocate_tokens_for_local_replication_factor: 3 (uncomment for vnodes)
if [[ "${vnodes}" == "false" ]]; then
  GENERIC_lib_strings_sedStringManipulation "removeHashAndLeadingWhitespace" "${file}" "initial_token:" "dummy"
  GENERIC_lib_strings_sedStringManipulation "editAfterSubstring"             "${file}" "initial_token:" "${token}"
  GENERIC_lib_strings_sedStringManipulation "hashCommentOutMatchingLine"     "${file}" "num_tokens:" "dummy"
  GENERIC_lib_strings_sedStringManipulation "hashCommentOutMatchingLine"     "${file}" "allocate_tokens_for_local_replication_factor:" "dummy"
 else
  GENERIC_lib_strings_sedStringManipulation "removeHashAndLeadingWhitespace" "${file}" "num_tokens:" "dummy"
  GENERIC_lib_strings_sedStringManipulation "editAfterSubstring"             "${file}" "num_tokens:" "${vnodes}"
  GENERIC_lib_strings_sedStringManipulation "removeHashAndLeadingWhitespace" "${file}" "allocate_tokens_for_local_replication_factor:" "dummy"
  GENERIC_lib_strings_sedStringManipulation "hashCommentOutMatchingLine"     "${file}" "initial_token:" "dummy"
fi

# CASSANDRA_FOLDER_HINTS
GENERIC_lib_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "hints_directory:"        "${CASSANDRA_FOLDER_HINTS}"
# CASSANDRA_FOLDER_COMMITLOG
GENERIC_lib_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "commitlog_directory:"    "${CASSANDRA_FOLDER_COMMITLOG}"
# CASSANDRA_FOLDER_CDCRAW
GENERIC_lib_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "cdc_raw_directory:"       "${CASSANDRA_FOLDER_CDCRAW}"
# CASSANDRA_FOLDER_SAVEDCACHES
GENERIC_lib_strings_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "saved_caches_directory:"  "${CASSANDRA_FOLDER_SAVEDCACHES}"
# endpoint_snitch: (nearly always 'GossipingPropertyFileSnitch')
GENERIC_lib_strings_sedStringManipulation "editAfterSubstring" "${file}" "endpoint_snitch:" "${endpoint_snitch}"
}

# ---------------------------------------

function lib_doStuffLocally_cassandraYaml_json(){

## cassandra.yaml - set node specific settings from json

# file to edit
file="${TMP_FOLDER_BUILDFILE}resources/cassandra/conf/cassandra.yaml"

# select correct version of command based on OS
IFS='%'
dynamic_cmd="$(GENERIC_lib_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# seeds
${dynamic_cmd} "s?\(-[[:space:]]seeds:\s*\).*\$?\1\"${seeds}\"?"  "${file}"
# listen_address
GENERIC_lib_strings_sedStringManipulation "editAfterSubstring" "${file}" "listen_address:" "${listen_address}"
# rpc_address
GENERIC_lib_strings_sedStringManipulation "editAfterSubstring" "${file}" "rpc_address:" "${rpc_address}"
# for version dse-6.0 onwards
GENERIC_lib_strings_sedStringManipulation "editAfterSubstring" "${file}" "native_transport_address:" "${rpc_address}"
}

# ---------------------------------------

function lib_doStuffLocally_dseYaml_dsefsData(){

## dse.yaml - configure for dsefs - required by spark

# file to edit
file="${TMP_FOLDER_BUILDFILE}resources/dse/conf/dse.yaml"

# search for and remove any pre-canned blocks containing this label
label="define_dsefs_options"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

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
      work_dir: ${DSEFS_FOLDER_WORK}
      public_port: 5598
      private_port: 5599
      data_directories:
EOF
# add data folder(s) for dsefs
for i in "${arrayBuildSendData[@]}"
do
  GENERIC_lib_strings_expansionDelimiter "$i" ";" "2"
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

function lib_doStuffLocally_dseSparkEnv(){

## configure dse-spark-env.sh (sourced at end of spark-env.sh) to set paths for log/data files

# file to edit
file="${TMP_FOLDER_BUILDFILE}resources/spark/conf/dse-spark-env.sh"

# search for and remove any pre-canned blocks containing this label:
label="define_spark_folders"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# select correct version of command based on OS
IFS='%'
dynamic_cmd="$(GENERIC_lib_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS

# part [A]
# insert gap at beginning of file (actually 2nd line to avoid any hash-bang)
${dynamic_cmd} '1G' ${file} # insert after first line

lineNumber=3
# part [B]
# insert block on 3nd line to avoid hash-bang
# using double quotes expands variables but overwrites rather than insert
${dynamic_cmd} "${lineNumber}i#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}"                                                               ${file};((lineNumber++))
if [ -n "$SPARK_FOLDER_LOCALDATA" ];      then ${dynamic_cmd} "${lineNumber}iexport SPARK_LOCAL_DIRS=${SPARK_FOLDER_LOCALDATA}"          ${file};((lineNumber++));fi
if [ -n "$SPARK_FOLDER_WORKERDATA" ];     then ${dynamic_cmd} "${lineNumber}iexport SPARK_WORKER_DIR=${SPARK_FOLDER_WORKERDATA}"         ${file};((lineNumber++));fi
if [ -n "$SPARK_FOLDER_EXECUTOR" ];       then ${dynamic_cmd} "${lineNumber}iexport SPARK_EXECUTOR_DIRS=${SPARK_FOLDER_EXECUTOR}"        ${file};((lineNumber++));fi
if [ -n "$SPARK_FOLDER_WORKERLOG" ];      then ${dynamic_cmd} "${lineNumber}iexport SPARK_WORKER_LOG_DIR=${SPARK_FOLDER_WORKERLOG}"      ${file};((lineNumber++));fi
if [ -n "$SPARK_FOLDER_MASTERLOG" ];      then ${dynamic_cmd} "${lineNumber}iexport SPARK_MASTER_LOG_DIR=${SPARK_FOLDER_MASTERLOG}"      ${file};((lineNumber++));fi
if [ -n "$SPARK_FOLDER_ALWAYSONSQLLOG" ]; then ${dynamic_cmd} "${lineNumber}iexport ALWAYSON_SQL_LOG_DIR=${SPARK_FOLDER_ALWAYSONSQLLOG}" ${file};((lineNumber++));fi
${dynamic_cmd} "${lineNumber}i#>>>>>END-ADDED-BY__${WHICH_POD}@${label}"                                                                 ${file}
}

# ---------------------------------------

function lib_doStuffLocally_dseGremlinRemoteYaml(){

## add graph ips to remote.yaml to allow gremlin-console to connect

# for each server that has 'true' for graph in json - add its pub_ip to a list 
graphNodesList=""
for id in $(seq 1 ${numberOfServers});
do
  serverModeGraph=$(jq -r '.server_'${id}'.'mode.graph ${serversJsonPath})
  serverPubIp=$(jq -r '.server_'${id}'.'pub_ip ${serversJsonPath})
  if [[ "${serverModeGraph}" == "true" ]]; then
    if [[ "${graphNodesList}" == "" ]]; then
      graphNodesList=${serverPubIp}
    else
      graphNodesList=${graphNodesList},${serverPubIp}
    fi
  fi
done

if [[ "${graphNodesList}" == "" ]]; then 
  graphNodesList="$(printf %q [localhost])"
else
  graphNodesList="$(printf %q [${graphNodesList}])"
fi

# edit the graph config file with the list of graph nodes that can be connected to
file="${TMP_FOLDER_BUILDFILE}resources/graph/gremlin-console/conf/remote.yaml"

# edit hosts entry
GENERIC_lib_strings_sedStringManipulation "editAfterSubstring" "${file}" "hosts:" "${graphNodesList}"
}
