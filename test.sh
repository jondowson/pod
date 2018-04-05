#!/usr/bin/env bash
set -x
servers_json_path="servers/DSE-OPSCENTER_singleMac.json"
id=1

numberOfClusters=$(jq -r '.server_1.cluster_conf' ${servers_json_path} | grep 'cluster_' | wc -l)

# process the opscenter cluster config entries for the [storage_cassandra] block (specified in the jsonfile) - handle ${BUILD_FOLDER} variable if present in path
#storage_cassandra=$(jq -r '.server_'${id}'.cluster_conf.cluster_'${COUNTER} "${servers_json_path}")
declare -a storage_cassandra_array
for count in $(seq 1 ${numberOfClusters});
do
  jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.clustername'             "${servers_json_path}"
  jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.username'                "${servers_json_path}"
  jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.password'                "${servers_json_path}"
  jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.apiport'                 "${servers_json_path}"
  jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.cqlport'                 "${servers_json_path}"
  jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.keyspace'                "${servers_json_path}"
  jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_keystore'            "${servers_json_path}"
  jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_keystore_password'   "${servers_json_path}"
  jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_truststore'          "${servers_json_path}"
  jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_truststore_password' "${servers_json_path}"
  #storage_cassandra_array[${COUNTER}]=${path}
  #(( COUNTER++ ))
done
