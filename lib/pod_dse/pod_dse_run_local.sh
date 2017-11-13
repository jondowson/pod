#!/bin/bash

# author:        jondowson
# about:         functions executed on local server on files destined for remote servers

# ---------------------------------------

function pod_dse_run_local_cassandraYamlData(){

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
dynamic_cmd="$(pod_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
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

function pod_dse_run_local_cassandraTopologyProperties(){

## rename the deprecated cassandra-topology.properties to stop it interfering !!

# rename files and suppress error messages if file does not exist
mv "${tmp_build_file_folder}resources/cassandra/conf/cassandra-topology.properties" "${tmp_build_file_folder}resources/cassandra/conf/cassandra-topology.properties_old" 2>/dev/null
}

# ---------------------------------------

function pod_dse_run_local_cassandraRackdcProperties(){

## utilise if using rack topology approach !!
:
}

# ---------------------------------------

function pod_dse_run_local_cassandraEnv(){

## utilise if default logging folder does not have access permissions !!

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra-env.sh"
# search for and remove any lines starting with:
pod_generic_misc_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export CASSANDRA_LOG_DIR=" "dummy"
pod_generic_misc_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export TOMCAT_LOGS=" "dummy"

# append to end of file
cat << EOF >> ${file}
export CASSANDRA_LOG_DIR=${cassandra_log_folder}
export TOMCAT_LOGS=${tomcat_log_folder}
export GREMLIN_LOG_DIR=${gremlin_log_folder}
EOF
}

# ---------------------------------------

function pod_dse_run_local_jvmOptions(){

## utilise if default tmpdir does not have access permissions !!

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/jvm.options"

# search for and remove any lines starting with:
pod_generic_misc_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "-Djna.tmpdir=" "dummy"

# append to end of file
cat << EOF >> ${file}
-Djna.tmpdir=${Djava_tmp_folder}
EOF
}

# ---------------------------------------

function pod_dse_run_local_cassandraRackDcProperties(){

## configure the rack and data center for this node 

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra-rackdc.properties"

pod_generic_misc_sedStringManipulation "editAfterSubstring" "${file}" "dc="   "${dc}"
pod_generic_misc_sedStringManipulation "editAfterSubstring" "${file}" "rack=" "${rack}"
}


# ---------------------------------------

function pod_dse_run_local_cassandraYaml(){

## configure the 'main' settings for the cassandra config file

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra.yaml"

# cluster_name:
pod_generic_misc_sedStringManipulation "editAfterSubstring" "${file}" "cluster_name:" "'${CLUSTER_NAME}'"

# num_tokens:
# allocate_tokens_for_local_replication_factor: 3 (uncomment for vnodes)
if [[ "${VNODES}" == "false" ]]; then
  pod_generic_misc_sedStringManipulation "removeHashAndLeadingWhitespace" "${file}" "initial_token:" "dummy"
  pod_generic_misc_sedStringManipulation "editAfterSubstring"             "${file}" "initial_token:" "${token}"
  pod_generic_misc_sedStringManipulation "hashCommentOutMatchingLine"     "${file}" "num_tokens:" "dummy"
  pod_generic_misc_sedStringManipulation "hashCommentOutMatchingLine"     "${file}" "allocate_tokens_for_local_replication_factor:" "dummy"
 else
  pod_generic_misc_sedStringManipulation "removeHashAndLeadingWhitespace" "${file}" "num_tokens:" "dummy"
  pod_generic_misc_sedStringManipulation "editAfterSubstring"             "${file}" "num_tokens:" "${VNODES}"
  pod_generic_misc_sedStringManipulation "removeHashAndLeadingWhitespace" "${file}" "allocate_tokens_for_local_replication_factor:" "dummy"
  pod_generic_misc_sedStringManipulation "hashCommentOutMatchingLine"     "${file}" "initial_token:" "dummy"
fi

# hints_directory:
pod_generic_misc_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "hints_directory:" "${hints_directory}"

# commitlog_directory:
pod_generic_misc_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "commitlog_directory:" "${commitlog_directory}"

# cdc_raw_directory:
pod_generic_misc_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "cdc_raw_directory:" "${cdc_raw_directory}"

# saved_caches_directory:
pod_generic_misc_sedStringManipulation "editAfterSubstringPathFriendly" "${file}" "saved_caches_directory:" "${saved_caches_directory}"

# endpoint_snitch: (nearly always 'GossipingPropertyFileSnitch')
pod_generic_misc_sedStringManipulation "editAfterSubstring" "${file}" "endpoint_snitch:" "${ENDPOINT_SNITCH}"
}

# ---------------------------------------

function pod_dse_run_local_cassandraYaml_nodeSpecific(){

# file to edit
file="${tmp_build_file_folder}resources/cassandra/conf/cassandra.yaml"

# seeds:
IFS='%'
dynamic_cmd="$(pod_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
unset IFS
${dynamic_cmd} "s?\(-[[:space:]]seeds:\s*\).*\$?\1\"${seeds}\"?"  "${file}"

# listen_address:
pod_generic_misc_sedStringManipulation "editAfterSubstring" "${file}" "listen_address:" "${listen_address}"

# rpc_address:
pod_generic_misc_sedStringManipulation "editAfterSubstring" "${file}" "rpc_address:" "${rpc_address}"
}

# ---------------------------------------

function pod_dse_run_local_dseYaml_dsefs(){

## configure dse.yaml for dsefs - required by spark

# file to edit
file="${tmp_build_file_folder}resources/dse/conf/dse.yaml"

# search for and remove any pre-canned blocks containing this label:
label="define_dsefs_options"
pod_generic_misc_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

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
  pod_generic_misc_expansionDelimiter "$i" ";" "2"
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

function pod_dse_run_local_dseSparkEnv(){

## configure dse-spark-env.sh (sourced at end of spark-env.sh) to set paths for log/data files

# file to edit
file="${tmp_build_file_folder}resources/spark/conf/dse-spark-env.sh"

# search for and remove any lines starting with:
pod_generic_misc_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_WORKER_LOG_DIR=" "dummy"
pod_generic_misc_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_MASTER_LOG_DIR=" "dummy"
pod_generic_misc_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_WORKER_DIR=" "dummy"
pod_generic_misc_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export SPARK_LOCAL_DIRS=" "dummy"

cat << EOF >> ${file}
export SPARK_WORKER_LOG_DIR="${spark_worker_log_folder}"
export SPARK_MASTER_LOG_DIR="${spark_master_log_folder}"
export SPARK_WORKER_DIR=${spark_worker_data}
export SPARK_LOCAL_DIRS=${spark_local_data}
EOF
}

# ---------------------------------------

function pod_dse_run_local_hashBang(){

## ensure bash interpreter is set correctly for pod on remote os

# determine what comes after #!/ at top of remote launch script
if [[ ${remote_os} == *"Mac"* ]]; then
  hashBang="usr/local/bin/bash"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}launch-pod" "bin/bash" "${hashBang}"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/pod_dse/pod_dse_script_launch_remote.sh" "bin/bash" "${hashBang}"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/pod_dse/pod_dse_run_remote.sh" "bin/bash" "${hashBang}"
elif [[ ${remote_os} == "Ubuntu" ]]; then
  hashBang="bin/bash"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}launch-pod" "usr/local/bin/bash" "${hashBang}"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/pod_dse/pod_dse_script_launch_remote.sh" "usr/local/bin/bash" "${hashBang}"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/pod_dse/pod_dse_run_remote.sh" "usr/local/bin/bash" "${hashBang}"
elif [[ ${remote_os} == "Centos" ]]; then
  hashBang="bin/bash"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}launch-pod" "usr/local/bin/bash" "${hashBang}"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/pod_dse/pod_dse_script_launch_remote.sh" "usr/local/bin/bash" "${hashBang}"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/pod_dse/pod_dse_run_remote.sh" "usr/local/bin/bash" "${hashBang}"
elif [[ ${remote_os} == "Redhat" ]]; then
  hashBang="bin/bash"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}launch-pod" "usr/local/bin/bash" "${hashBang}"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/pod_dse/pod_dse_script_launch_remote.sh" "usr/local/bin/bash" "${hashBang}"
  pod_generic_misc_sedStringManipulation "searchAndReplaceStringGlobal" "${tmp_working_folder}lib/pod_dse/pod_dse_run_remote.sh" "usr/local/bin/bash" "${hashBang}"
else
  os="Bad"
  pod_generic_display_msgColourSimple "error" "OS Not Supported"
  exit 1;
fi
}
