#!/bin/bash

# script_name:   functions_pod_local.sh
# author:        jondowson
# about:         functions executed on local server on files destined for remote servers

# ---------------------------------------

function pod_local_configure_cassandraYamlData(){

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
dynamic_cmd="$(generic_dynamic_os_command 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
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

function pod_local_rename_cassandra-topology.properties(){

## rename the deprecated cassandra-topology.properties to stop it interfering !!

# rename files and suppress error messages if file does not exist
mv "${tmp_build_file_folder}resources/cassandra/conf/cassandra-topology.properties" "${tmp_build_file_folder}resources/cassandra/conf/cassandra-topology.properties_old" 2>/dev/null
}

# ---------------------------------------

function pod_local_configure_cassandra-rackdc.properties(){

## utilise if using rack topology approach !!
:
}

# ---------------------------------------

function pod_local_configure_cassandra-env.sh(){

## utilise if default logging folder does not have access permissions !!

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra-env.sh"
# search for and remove any lines starting with:
generic_sed_string_manipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export CASSANDRA_LOG_DIR=" "dummy"
generic_sed_string_manipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export TOMCAT_LOGS=" "dummy"

# append to end of file
cat << EOF >> ${file}
export CASSANDRA_LOG_DIR=${cassandra_log_folder}
export TOMCAT_LOGS=${tomcat_log_folder}
export GREMLIN_LOG_DIR=${gremlin_log_folder}
EOF
}

# ---------------------------------------

function pod_local_configure_jvm.options(){

## utilise if default tmpdir does not have access permissions !!

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/jvm.options"

# search for and remove any lines starting with:
generic_sed_string_manipulation "searchFromLineStartAndRemoveEntireLine" ${file} "-Djna.tmpdir=" "dummy"

# append to end of file
cat << EOF >> ${file}
-Djna.tmpdir=${Djava_tmp_folder}
EOF
}

# ---------------------------------------resources/build_fs

function pod_local_configure_cassandra.yaml(){

## configure the 'main' settings for the cassandra config file

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra.yaml"

# ~10 cluster_name:
generic_sed_string_manipulation "editAfterSubstring" "${file}" "cluster_name:" "'${CLUSTER_NAME}'"

# ~25 num_tokens:
# ~36 allocate_tokens_for_local_replication_factor: 3 (uncomment for vnodes)
if [[ "${VNODES}" == "false" ]]; then
  generic_sed_string_manipulation "removeHashAndLeadingWhitespace" "${file}" "initial_token:" "dummy"
  generic_sed_string_manipulation "editAfterSubstring"             "${file}" "initial_token:" "${token}"
  generic_sed_string_manipulation "hashCommentOutMatchingLine"     "${file}" "num_tokens:" "dummy"
  generic_sed_string_manipulation "hashCommentOutMatchingLine"     "${file}" "allocate_tokens_for_local_replication_factor:" "dummy"
 else
  generic_sed_string_manipulation "removeHashAndLeadingWhitespace" "${file}" "num_tokens:" "dummy"
  generic_sed_string_manipulation "editAfterSubstring"             "${file}" "num_tokens:" "${VNODES}"
  generic_sed_string_manipulation "removeHashAndLeadingWhitespace" "${file}" "allocate_tokens_for_local_replication_factor:" "dummy"
  generic_sed_string_manipulation "hashCommentOutMatchingLine"     "${file}" "initial_token:" "dummy"
fi

# ~73 hints_directory:
generic_sed_string_manipulation "editAfterSubstringPathFriendly" "${file}" "hints_directory:" "${hints_directory}"

# ~197 commitlog_directory:
generic_sed_string_manipulation "editAfterSubstringPathFriendly" "${file}" "commitlog_directory:" "${commitlog_directory}"

# ~208 cdc_raw_directory:
generic_sed_string_manipulation "editAfterSubstringPathFriendly" "${file}" "cdc_raw_directory:" "${cdc_raw_directory}"

# ~369 saved_caches_directory:
generic_sed_string_manipulation "editAfterSubstringPathFriendly" "${file}" "saved_caches_directory:" "${saved_caches_directory}"

# ~963 endpoint_snitch: (nearly always 'GossipingPropertyFileSnitch')
generic_sed_string_manipulation "editAfterSubstring" "${file}" "endpoint_snitch:" "${ENDPOINT_SNITCH}"
}

# ---------------------------------------

function pod_local_node_specific_configure_cassandra.yaml(){

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra.yaml"

# ~425 - seeds:
IFS='%'
dynamic_cmd="$(generic_dynamic_os_command 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS
${dynamic_cmd} "s?\(-[[:space:]]seeds:\s*\).*\$?\1\"${seeds}\"?"  "${file}"

# ~599 listen_address:
generic_sed_string_manipulation "editAfterSubstring" "${file}" "listen_address:" "${listen_address}"
}

# ---------------------------------------

function pod_local_configure_dsefs_dse.yaml(){

## configure dse.yaml for dsefs - required by spark

# file to edit
file="${tmp_build_file_folder}resources/dse/conf/dse.yaml"

# search for and remove any pre-canned blocks containing this label:
label="define_dsefs_options"
generic_sed_string_manipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# add block to define dsefs settings and data folders
cat << EOF >> $file
#BOF CLEAN-${label}
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
  generic_parameter_expansion_delimeter "$i" ";" "2"
  cat << EOF >> $file
          - dir: ${_D1_}
            storage_weight: ${_D2_}
            min_free_space: ${_D3_}
EOF
done
cat << EOF >> $file
#EOF CLEAN-${label}
EOF
}

# ---------------------------------------

function pod_local_configure_dse-spark-env.sh(){

## configure dse-spark-env.sh (sourced at end of spark-env.sh) to set paths for log/data files

# file to edit
file="${tmp_build_file_folder}resources/spark/conf/dse-spark-env.sh"

# search for and remove any lines starting with:
generic_sed_string_manipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_WORKER_LOG_DIR=" "dummy"
generic_sed_string_manipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_MASTER_LOG_DIR=" "dummy"
generic_sed_string_manipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_WORKER_DIR=" "dummy"
generic_sed_string_manipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_LOCAL_DIRS=" "dummy"

cat << EOF >> ${file}
export SPARK_WORKER_LOG_DIR="${spark_worker_log_folder}"
export SPARK_MASTER_LOG_DIR="${spark_master_log_folder}"
export SPARK_WORKER_DIR=${spark_worker_data}
export SPARK_LOCAL_DIRS=${spark_local_data}
EOF
}
