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
  lib_doStuff_remotely_clusterConf
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
## adds a [storage_cassandra] block (specified in the jsonfile) to a cluster config file of the same name as the cluster to manage

# the server_id  for this server from the json file - i.e. server_1
id="${server_id}"
# the number of clusters this opscenter cluster will store metrics for
numberOfClusters=$($jqCmd -r '.server_'${id}'.cluster_conf' ${servers_json_path} | grep 'cluster_' | wc -l)

# add [storage_cluster] block for each managed cluster
for count in $(seq 1 ${numberOfClusters});
do

  ## assign json values to bash variables

  sc_clustername=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.clustername'                      "${servers_json_path}")
  sc_username=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.username'                            "${servers_json_path}")
  sc_password=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.password'                            "${servers_json_path}")
  sc_api_port=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.apiport'                             "${servers_json_path}")
  sc_cql_port=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.cqlport'                             "${servers_json_path}")
  sc_keyspace=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.keyspace'                            "${servers_json_path}")
  sc_ssl_keystore=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_keystore'                    "${servers_json_path}")
  sc_ssl_keystore_password=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_keystore_password'  "${servers_json_path}")
  sc_truststore=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_truststore'                    "${servers_json_path}")
  sc_truststore_password=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.ssl_truststore_password'  "${servers_json_path}")

# -----

  ## for list of seed_hosts, make a comma seperated string from a json list

  seed_hosts=""
  seed_hosts=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'${count}'.seed_hosts[]' "${servers_json_path}" |
  while read -r seed
  do
    seed_hosts="${seed_hosts},${seed}"
    echo "$seed_hosts"
  done)
  # some bash-kung-fu required to get variable out of the pipe created sub-shell
  # remove first comma from comma seperated list of seed nodes ips
  sc_seed_hosts=$(echo "$seed_hosts" | sed '$!d' | cut -c 2-) # sed '/./,$!d'

# -----

  ## edit/create conf file for this cluster

  file="${opscenter_untar_config_folder}clusters/${sc_clustername}.conf"
  label=$(printf "%q" "[storage_cassandra]")
  mkdir -p "${opscenter_untar_config_folder}clusters/" && touch ${file}

# -----

  ## remove any pre-exisiting pod added blocks with the same block label

  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
  unset IFS
  # [a] find line number of any existing pod block with this label
  matchA=$(${dynamic_cmd} /\#\>\>\>\>\>BEGIN-ADDED-BY__${WHICH_POD}@${label}/= "${file}")
  # [b] remove any existing block
  lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"
  # [c] search again for line number of setting
  matchB=$(${dynamic_cmd} '/${label}/=' "${file}")

# -----

  ## remove any pre-exisiting blocks - not added by pod

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
  # ensure block is inserted at line 1 if no previous block found
  if [[ "${matchC}" == "" ]] || [[ "${matchC}" == "0" ]]; then matchC="1";fi;

# -----

  ## add in the new labelled block to thge file

  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS
  # insert block to define encryption settings at correct line number
  ${dynamic_cmd} "$(($matchC))i #>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}"             ${file}
  ${dynamic_cmd} "$(($matchC+1))i ${label}"                                              ${file}
  ${dynamic_cmd} "$(($matchC+2))i username = ${sc_username}"                             ${file}
  ${dynamic_cmd} "$(($matchC+3))i password = ${sc_password}"                             ${file}
  ${dynamic_cmd} "$(($matchC+4))i seed_hosts = ${sc_seed_hosts}"                         ${file}
  ${dynamic_cmd} "$(($matchC+5))i api_port = ${sc_api_port}"                             ${file}
  ${dynamic_cmd} "$(($matchC+6))i cql_port = ${sc_cql_port}"                             ${file}
  ${dynamic_cmd} "$(($matchC+7))i keyspace = ${sc_keyspace}"                             ${file}
  ${dynamic_cmd} "$(($matchC+8))i ssl_keystore = ${ssl_keystore}"                        ${file}
  ${dynamic_cmd} "$(($matchC+9))i ssl_keystore_password = ${ssl_keystore_password}"      ${file}
  ${dynamic_cmd} "$(($matchC+10))i ssl_trustore = ${ssl_truststore}"                     ${file}
  ${dynamic_cmd} "$(($matchC+11))i ssl_truststore_password = ${ssl_truststore_password}" ${file}
  ${dynamic_cmd} "$(($matchC+12))i #>>>>>END-ADDED-BY__${WHICH_POD}@${label}"            ${file}

done
}
