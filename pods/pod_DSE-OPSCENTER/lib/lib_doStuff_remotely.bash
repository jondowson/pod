# about:    non-generic functions executed on remote server

# ---------------------------------------

function lib_doStuff_remotely_pod_DSE-OPSCENTER(){

# [1] delete any previous install folder with the same version
rm -rf ${UNTAR_FOLDER}

# [2] make folders
lib_generic_doStuff_remotely_createFolders "${UNTAR_FOLDER}${SOFTWARE_VERSION}"

# [3] un-compress software
lib_generic_doStuff_remotely_unpackTar "${TAR_FILE}" "${UNTAR_FOLDER}"

# [4] configure local environment
lib_generic_doStuff_remotely_updatePathBashProfile "OPSC_HOME" "${UNTAR_EXEC_FOLDER}"

# [5] configure cluster_config file
if [[ "${apply_storage_cluster}" == "true" ]]; then
  lib_doStuff_remotely_clusterConfigFile
fi
}

# ---------------------------------------

function lib_doStuff_remotely_stopOpscenter(){

## kill opscenter pid

status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "4" ]] || [[ "${status}" == "0" ]]
  do
    ssh -q -i ${sshKey} ${user}@${pubIp} "ps aux | grep start_opscenter.py | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
    status=${?}
    stop_opscenter_error_array["${tag}"]="${status};${pubIp}"
    ((retry++))
  done
  printf "%s\n"
fi
}

# ---------------------------------------

function lib_doStuff_remotely_clusterConf(){

## configure the cluster config file for this cluster to use opscenter to store its metric data (rather than storing in its own cluster)

file="${1}"
label="${2}"

# file to edit + if it does not exist make it
#file="${opscenter_untar_config_folder}clusters/${clustername}.yaml" && touch ${file}
#label="[storage_cassandra]"

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
unset IFS

# find line number of any existing pod block with this label
matchA=$(${dynamic_cmd} /\#\>\>\>\>\>BEGIN-ADDED-BY__${WHICH_POD}@${label}/= "${file}")
# search for and remove any pod_DSE-SECURITY pre-canned blocks containing this label
#lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"
lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"
# search again for line number of setting
label=$(printf %q ${label})
matchB=$(${dynamic_cmd} '/${label}/=' "${file}")

# if there is still a block then it was not added by this pod - so delete it
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
  # remove any previous block with this combination of pod and label
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

numberOfClusters=$(jq -r '.server_1.cluster_conf' ${servers_json_path} | grep 'cluster_' | wc -l)

# process the opscenter cluster config entries for the [storage_cassandra] block (specified in the jsonfile) - handle ${BUILD_FOLDER} variable if present in path
#storage_cassandra=$(jq -r '.server_'${id}'.cluster_conf.cluster_'${COUNTER} "${servers_json_path}")
declare -a storage_cassandra_array
for count in $(seq 1 ${numberOfClusters});
do
  sc_clustername=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.clustername'                      "${servers_json_path}")
  sc_username=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.username'                            "${servers_json_path}")
  sc_password=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.password'                            "${servers_json_path}")
  sc_api_port=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.apiport'                             "${servers_json_path}")
  sc_cql_port=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.cqlport'                             "${servers_json_path}")
  sc_keyspace=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.keyspace'                            "${servers_json_path}")
  sc_ssl_keystore=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_keystore'                    "${servers_json_path}")
  sc_ssl_keystore_password=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_keystore_password'  "${servers_json_path}")
  sc_truststore=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_truststore'                    "${servers_json_path}")
  sc_truststore_password=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_truststore_password'  "${servers_json_path}")
  #storage_cassandra_array[${COUNTER}]=${path}
  #(( COUNTER++ ))

  # insert block to define encryption settings at correct line number
  ${dynamic_cmd} "$(($matchC))i #>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}"       ${file}
  ${dynamic_cmd} "$(($matchC+1))i ${label}"                                        ${file}
  ${dynamic_cmd} "$(($matchC+2))i username = ${sc_username}"                       ${file}
  ${dynamic_cmd} "$(($matchC+3))i password = ${sc_password}"                       ${file}
  ${dynamic_cmd} "$(($matchC+4))i seed_hosts = ${sc_seedHosts}"                    ${file}
  ${dynamic_cmd} "$(($matchC+5))i api_port = ${sc_apiPort}"                        ${file}
  ${dynamic_cmd} "$(($matchC+6))i cql_port = ${sc_cqlPort}"                        ${file}
  ${dynamic_cmd} "$(($matchC+7))i keyspace = ${sc_keyspace}"                       ${file}
  ${dynamic_cmd} "$(($matchC+8))i #>>>>>END-ADDED-BY__${WHICH_POD}@${label}"       ${file}

done



}
