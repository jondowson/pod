function lib_doStuffRemotely_pod_DSE-OPSCENTER(){

# [1] delete any previous build folder with the same version
rm -rf ${UNTAR_FOLDER}

# [2] make folders
GENERIC_lib_doStuffRemotely_createFolders "${UNTAR_FOLDER}${software_version}"

# [3] un-compress software
GENERIC_lib_doStuffRemotely_unpackTar     "${TAR_FILE}" "${UNTAR_FOLDER}"

# [4] configure local environment

GENERIC_lib_doStuffRemotely_updateAppBashProfile "OPSC_HOME" "${UNTAR_EXEC_FOLDER}"

# [5] configure cluster_config file
if [[ "${apply_storage_cluster}" == "true" ]]; then
  lib_doStuffRemotely_clusterConf
fi
}

# ---------------------------------------

function lib_doStuffRemotely_clusterConf(){

## configure the cluster config file for this cluster to use opscenter to store its metric data (rather than storing in its own cluster)
## adds a [storage_cassandra] block (specified in the jsonfile) to a cluster config file of the same name as the cluster to manage

# the server_id  for this server from the json file - i.e. server_1
id="${server_id}"
# the number of clusters this opscenter cluster will store metrics for
numberOfClusters=$(jq -r '.server_'${id}'.cluster_conf' ${serversJsonPath} | grep 'cluster_' | wc -l)

# add [storage_cluster] block for each managed cluster
for count in $(seq 1 ${numberOfClusters});
do

  ## [1] assign json values to bash variables

  clustername=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.clustername'                    "${serversJsonPath}")
  username=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.username'                          "${serversJsonPath}")
  password=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.password'                          "${serversJsonPath}")
  api_port=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.apiport'                           "${serversJsonPath}")
  cql_port=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.cqlport'                           "${serversJsonPath}")
  keyspace=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.keyspace'                          "${serversJsonPath}")
  keystore=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.keystore'                          "${serversJsonPath}")
  keystore_password=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.keystore_password'        "${serversJsonPath}")
  truststore=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.truststore'                      "${serversJsonPath}")
  truststore_password=$(jq -r '.server_'${id}'.cluster_conf.cluster_'$count'.truststore_password'    "${serversJsonPath}")

  # -----

  ## [2] edit/create conf file for this cluster

  file="${OPSCENTER_FOLDER_UNTAR_CONFIG}clusters/${clustername}.conf"
  mkdir -p "${OPSCENTER_FOLDER_UNTAR_CONFIG}clusters/" && touch ${file}

  # -----

  ## [3] assign labels use in config file and by pod block labels

  cassandraLabel=$(printf "%q" "[cassandra]")
  cassandraLabelSafe=$(printf ${cassandraLabel} | sed 's/[][]//g' | sed 's/\\//g')

  storageLabel=$(printf "%q" "[storage_cassandra]")
  storageLabelSafe=$(printf ${storageLabel} | sed 's/[][]//g' | sed 's/\\//g')

# -----

  ## [4] for list of [cassandra] seed_hosts, make a comma seperated string from a json list

  seed_hosts=""
  seed_hosts=$(jq -r '.server_'${id}'.cluster_conf.cluster_'${count}'.seedhosts_cassandra[]' "${serversJsonPath}" |
  while read -r seed
  do
    seed_hosts="${seed_hosts}, ${seed}"
    echo "$seed_hosts"
  done;)
  # some bash-kung-fu required to get variable out of the pipe created sub-shell
  # remove first comma from comma seperated list of seed nodes ips
  seedhosts_cassandra=$(echo "$seed_hosts" | sed '$!d' | cut -c 2-) # sed '/./,$!d'

# -----

  ## [5] for list of [storage_cassandra] seed_hosts, make a comma seperated string from a json list

  seed_hosts=""
  seed_hosts=$(jq -r '.server_'${id}'.cluster_conf.cluster_'${count}'.seedhosts_storage_cassandra[]' "${serversJsonPath}" |
  while read -r seed
  do
    seed_hosts="${seed_hosts}, ${seed}"
    echo "$seed_hosts"
  done;)
  # some bash-kung-fu required to get variable out of the pipe created sub-shell
  # remove first comma from comma seperated list of seed nodes ips
  seedhosts_storage_cassandra=$(echo "$seed_hosts" | sed '$!d' | cut -c 2-) # sed '/./,$!d'

  # -----

  ## [6] remove any pre-exisiting pod added blocks with the same block label

  # not required - this is added to force the file to be saved down before inserting blocks !!!

  # [a] select right command for os
  IFS='%'
  dynamic_cmd="$(GENERIC_lib_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
  unset IFS
  # [b] find line number of any existing pod block with this label
  matchA=$(${dynamic_cmd} /\#\>\>\>\>\>BEGIN-ADDED-BY__${WHICH_POD}@${cassandraLabelSafe}/= "${file}")
  # [c] remove any existing block
  GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${cassandraLabelSafe}"
  # [d] search again for line number of setting - this time for setting not added by pod
  matchB=$(${dynamic_cmd} '/${label}/=' "${file}")

# -----

  ## [7] add in the new '[cassandra]' labelled block to the file

  # select right command for os
  IFS='%'
  dynamic_cmd="$(GENERIC_lib_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS

  matchC=1

  # insert block to define settings at correct line number
  ${dynamic_cmd} "$(($matchC))i #>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${cassandraLabelSafe}"   ${file}
  ${dynamic_cmd} "$(($matchC+1))i ${cassandraLabel}"                                        ${file}
  ${dynamic_cmd} "$(($matchC+2))i seed_hosts = ${seedhosts_cassandra}"                      ${file}
  ${dynamic_cmd} "$(($matchC+3))i #>>>>>END-ADDED-BY__${WHICH_POD}@${cassandraLabelSafe}"   ${file}

  # -----

  ## [8] add in the new '[storage_cassandra]' labelled block to the file

  # select right command for os
  IFS='%'
  dynamic_cmd="$(GENERIC_lib_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
  unset IFS

  matchC=5

  # only apply truststore/keystore paths if none are empty in the json
  if [[ "${keystore}" == "" ]] || [[ "${keystore_password}" == "" ]] || [[ "${truststore}" == "" ]] || [[ "${truststore_password}" == "" ]]; then

    # insert block to define settings at correct line number
    ${dynamic_cmd} "$(($matchC))i #>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${storageLabelSafe}"  ${file}
    ${dynamic_cmd} "$(($matchC+1))i ${storageLabel}"                                       ${file}
    ${dynamic_cmd} "$(($matchC+2))i username = ${username}"                                ${file}
    ${dynamic_cmd} "$(($matchC+3))i password = ${password}"                                ${file}
    ${dynamic_cmd} "$(($matchC+4))i seed_hosts = ${seedhosts_storage_cassandra}"           ${file}
    ${dynamic_cmd} "$(($matchC+5))i api_port = ${api_port}"                                ${file}
    ${dynamic_cmd} "$(($matchC+6))i cql_port = ${cql_port}"                                ${file}
    ${dynamic_cmd} "$(($matchC+7))i keyspace = ${keyspace}"                                ${file}
    ${dynamic_cmd} "$(($matchC+8))i #>>>>>END-ADDED-BY__${WHICH_POD}@${storageLabelSafe}"  ${file}
  else
    # insert block to define settings + encryption settings at correct line number
    ${dynamic_cmd} "$(($matchC))i #>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${storageLabelSafe}"  ${file}
    ${dynamic_cmd} "$(($matchC+1))i ${storageLabel}"                                       ${file}
    ${dynamic_cmd} "$(($matchC+2))i username = ${username}"                                ${file}
    ${dynamic_cmd} "$(($matchC+3))i password = ${password}"                                ${file}
    ${dynamic_cmd} "$(($matchC+4))i seed_hosts = ${seedhosts_storage_cassandra}"           ${file}
    ${dynamic_cmd} "$(($matchC+5))i api_port = ${api_port}"                                ${file}
    ${dynamic_cmd} "$(($matchC+6))i cql_port = ${cql_port}"                                ${file}
    ${dynamic_cmd} "$(($matchC+7))i keyspace = ${keyspace}"                                ${file}
    ${dynamic_cmd} "$(($matchC+8))i ssl_keystore = ${keystore}"                            ${file}
    ${dynamic_cmd} "$(($matchC+9))i ssl_keystore_password = ${keystore_password}"          ${file}
    ${dynamic_cmd} "$(($matchC+10))i ssl_trustore = ${truststore}"                         ${file}
    ${dynamic_cmd} "$(($matchC+11))i ssl_truststore_password = ${truststore_password}"     ${file}
    ${dynamic_cmd} "$(($matchC+12))i #>>>>>END-ADDED-BY__${WHICH_POD}@${storageLabelSafe}" ${file}
  fi

done
}

# ---------------------------------------

function lib_doStuffRemotely_startOpscenter(){

## run a command remotely to start opscenter
## record result of commands in array for later reporting

GENERIC_prepare_display_msgColourSimple "INFO-->" "starting opscenter:              ~30s"
cmd="source ~/.bash_profile && ${OPSCENTER_FOLDER_UNTAR_BIN}opscenter"                          # start command + source bash_profile to ensure correct java version is used
log_to_check="${OPSCENTER_FOLDER_UNTAR_LOG}opscenterd.log"                                      # log folder to check for keyphrase
keyphrase="StompFactory starting"                                                               # if this appears in logs - then assume success!
response_label=""                                                                               # label for response codes
retryTimes="11"                                                                                 # try x times to inspect logs for success
pauseTime="3"                                                                                   # pause between log look ups
tailCount="50"                                                                                  # how many lines to grab from end of log - relationship with pause time + speed logs are written

ssh -q -i ${ssh_key} ${user}@${pub_ip} "${cmd} &>~/.cmdOutput"                                  # run opscenter for the specified build
sleep 5                                                                                         # give the chance for script to run + logs to fill up
cmdOutput=$(ssh -q -i ${ssh_key} ${user}@${pub_ip} "cat ~/.cmdOutput && rm -rf ~/.cmdOutput" )  # grab any command output - could be a clue to a failure

retry=1
until [[ "${retry}" == "${retryTimes}" ]]                                                       # try x times with a sleep pause between attempts
do
  sleep ${pauseTime}                                                                            # take a break - have a kitkat
  output=$(ssh -q -i ${ssh_key} ${user}@${pub_ip}  "tail -n ${tailCount} ${log_to_check} | tr '\0' '\n'")   # grab opscenter log and handle null point warning
  if [[ "${output}" == *"${keyphrase}"* ]]; then
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${response_label}${green}0${white}"
    retry=10
    success="true"
  fi
  if [[ "${retry}" == "10" ]] && [[ "${success}" != "true" ]]; then                             # failure messages
  GENERIC_prepare_display_msgColourSimple "INFO-->" "${response_label} ${red}1 - You may ned to kill any existing opscenter process as root !!${reset}"
  GENERIC_prepare_display_msgColourSimple "INFO-->" "${response_label} ${red}1 - Is the right Java version installed [ ${cmdOutput} ] !!${reset}"
  fi
  arrayStartOpscenter["start_opscenter_at_${tag}"]="${status};${pub_ip}"
  ((retry++))
done
}

# ---------------------------------------

function lib_doStuffRemotely_stopOpscenter(){

## run a command remotely to stop DSE gracefully and kill datastax-agent pid
## record result of commands in array for later reporting

# try twice to stop opscenter
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  GENERIC_prepare_display_msgColourSimple     "INFO-->" "stopping opscenter:              ungracefully"
  ssh -q -i ${ssh_key} ${user}@${pub_ip} "ps aux | grep -v grep | grep -v '\-p\ pod_DSE-OPSCENTER' | grep -v '\--pod\ pod_DSE-OPSCENTER' | grep opscenter | awk {'print \$2'} | xargs kill -9 &>/dev/null"
  status=${?}
  until [[ "${retry}" == "3" ]]
  do
    if [[ "${status}" == "0" ]]; then
      GENERIC_prepare_display_msgColourSimple "INFO-->" "${green}${status}"
      retry=2
    else
      GENERIC_prepare_display_msgColourSimple "INFO-->" "${red}${status} ${white}(retry ${retry}/2)"
      ssh -q -i ${ssh_key} ${user}@${pub_ip} "ps aux | grep -v grep | grep -v '\-p\ pod_DSE-OPSCENTER' | grep -v '\--pod\ pod_DSE-OPSCENTER' | grep opscenter | awk {'print \$2'} | xargs kill -9 &>/dev/null"
      status=${?}
    fi
    arrayStopOpscenter["stop_opscenter_at_${tag}"]="${status};${pub_ip}"
    ((retry++))
  done
fi
}

# ---------------------------------------

function lib_doStuffRemotely_getAgentVersion(){

## try 2 approaches to identify running agent version

# [1] first use agent api to discover version (first check curl is available)
output=$(ssh -x -q -i ${ssh_key} ${user}@${pub_ip} "source ~/.bash_profile && curl --help &>/dev/null")
if [[ $? == "0" ]]; then
  runningVersion=$(ssh -x -q -i ${ssh_key} ${user}@${pub_ip} "chmod -R 777 ${target_folder}POD_SOFTWARE/POD && ${target_folder}POD_SOFTWARE/POD/pod/pods/pod_DSE/scripts/scripts_curlAgent.sh ${pub_ip}") > /dev/null 2>&1 &
fi

# [2] if first approach failed - find .jar version from its pid - this should be the same branch if not exact version number
if [[ -z $runningVersion ]]; then
  runningVersion=$(GENERIC_lib_doStuffRemotely_getVersionFromPid "datastax-agent-" "-")
fi

# [3] return version
printf "%s\n" "${runningVersion}"
}
