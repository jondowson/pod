function lib_doStuff_remotely_pod_DSE-OPSCENTER(){

# [1] delete any previous build folder with the same version
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

  ## [1] assign json values to bash variables

  clustername=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.clustername'                    "${servers_json_path}")
  username=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.username'                          "${servers_json_path}")
  password=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.password'                          "${servers_json_path}")
  api_port=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.apiport'                           "${servers_json_path}")
  cql_port=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.cqlport'                           "${servers_json_path}")
  keyspace=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.keyspace'                          "${servers_json_path}")
  keystore=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.keystore'                          "${servers_json_path}")
  keystore_password=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.keystore_password'        "${servers_json_path}")
  truststore=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.truststore'                      "${servers_json_path}")
  truststore_password=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'$count'.truststore_password'    "${servers_json_path}")

  # -----

  ## [2] edit/create conf file for this cluster

  file="${opscenter_untar_config_folder}clusters/${clustername}.conf"
  mkdir -p "${opscenter_untar_config_folder}clusters/" && touch ${file}

  # -----

  ## [3] assign labels use in config file and by pod block labels

  cassandraLabel=$(printf "%q" "[cassandra]")
  cassandraLabelSafe=$(printf ${cassandraLabel} | sed 's/[][]//g' | sed 's/\\//g')

  storageLabel=$(printf "%q" "[storage_cassandra]")
  storageLabelSafe=$(printf ${storageLabel} | sed 's/[][]//g' | sed 's/\\//g')

# -----

  ## [4] for list of [cassandra] seed_hosts, make a comma seperated string from a json list

  seed_hosts=""
  seed_hosts=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'${count}'.seedhosts_cassandra[]' "${servers_json_path}" |
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
  seed_hosts=$($jqCmd -r '.server_'${id}'.cluster_conf.cluster_'${count}'.seedhosts_storage_cassandra[]' "${servers_json_path}" |
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
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -n' 'sed -n' 'sed -n' 'sed -n')"
  unset IFS
  # [b] find line number of any existing pod block with this label
  matchA=$(${dynamic_cmd} /\#\>\>\>\>\>BEGIN-ADDED-BY__${WHICH_POD}@${cassandraLabelSafe}/= "${file}")
  # [c] remove any existing block
  lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${cassandraLabelSafe}"
  # [d] search again for line number of setting - this time for setting not added by pod
  matchB=$(${dynamic_cmd} '/${label}/=' "${file}")

# -----

  ## [7] add in the new '[cassandra]' labelled block to the file

  # select right command for os
  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
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
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
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

function lib_doStuff_remotely_startOpscenter(){

## run a command remotely to start opscenter
## record result of commands in array for later reporting

prepare_generic_display_msgColourSimple "INFO-->" "starting opscenter:    ~30s"
cmd="source ~/.bash_profile && ${opscenter_untar_bin_folder}opscenter"                          # start command + source bash_profile to ensure correct java version is used
log_to_check="${opscenter_untar_log_folder}opscenterd.log"                                      # log folder to check for keyphrase
keyphrase="StompFactory starting"                                                               # if this appears in logs - then assume success!
response_label="opscenter return code:"                                                         # label for response codes
retryTimes="11"                                                                                 # try x times to inspect logs for success
pauseTime="3"                                                                                   # pause between log look ups
tailCount="40"                                                                                  # how many lines to grab from end of log - relationship with pause time + speed logs are written

ssh -q -i ${sshKey} ${user}@${pubIp} "${cmd} &>~/.cmdOutput"                                    # run opscenter for the specified build
sleep 5                                                                                         # give the chance for script to run + logs to fill up
cmdOutput=$(ssh -q -i ${sshKey} ${user}@${pubIp} "cat ~/.cmdOutput && rm -rf ~/.cmdOutput" )    # grab any command output - could be a clue to a failure

retry=1
until [[ "${retry}" == "${retryTimes}" ]]                                                       # try x times with a sleep pause between attempts
do
  sleep ${pauseTime}                                                                            # take a break - have a kitkat
  output=$(ssh -q -i ${sshKey} ${user}@${pubIp}  "tail -n ${tailCount} ${log_to_check} | tr '\0' '\n'")   # grab opscenter log and handle null point warning
  if [[ "${output}" == *"${keyphrase}"* ]]; then
    prepare_generic_display_msgColourSimple "INFO-->" "${response_label} ${green}0${white}"
    retry=10
    success="true"
  fi
  if [[ "${retry}" == "10" ]] && [[ "${success}" != "true" ]]; then                             # failure messages
  prepare_generic_display_msgColourSimple "INFO-->" "${response_label} ${red}1 - You may ned to kill any existing opscenter process as root !!${reset}"
  prepare_generic_display_msgColourSimple "INFO-->" "${response_label} ${red}1 - Is the right Java version installed [ ${cmdOutput} ] !!${reset}"
  fi
  start_opscenter_error_array["${tag}"]="${status};${pubIp}"
  ((retry++))
done
}

# ---------------------------------------

function lib_doStuff_remotely_stopOpscenter(){

## kill opscenter pid

status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "3" ]] || [[ "${status}" == "0" ]]
  do
    ssh -q -i ${sshKey} ${user}@${pubIp} "ps aux | grep start_opscenter.py | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
    status=${?}
    stop_opscenter_error_array["${tag}"]="${status};${pubIp}"
    ((retry++))
  done
fi
}

# ---------------------------------------

function lib_doStuff_remotely_checkJava(){

## run a command remotely to check Java is installed

# try once to check java is installed
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
  do
    # display java output in different color
    printf "%s" "${yellow}"
    output=$(ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && java -version" )
    status=$?
    printf "%s" "${reset}"
    if [[ "${status}" != "0" ]]; then
      prepare_generic_display_msgColourSimple "INFO-->" "java return code:      ${red}${status}"
      if [[ "${STRICT_START}" ==  "true" ]]; then
        prepare_generic_display_msgColourSimple "ERROR-->" "Exiting pod: ${yellow}${task_file}${red} with ${yellow}--strict true${red} - java unavailable"
        exit 1;
      fi
      break;
    else
      prepare_generic_display_msgColourSimple "INFO-->" "java return code:      ${green}${status}"
      ((retry++))
    fi
  done
fi
}

# ---------------------------------------

function lib_doStuff_remotely_getAgentVersion(){

## try 2 approaches to identify running agent version

# [1] use agent api to discover version (first check curl is available)
ssh -q -i ~/.ssh/id_rsa jd@127.0.0.1 "curl &>/dev/null"
if [[ $? == "0" ]]; then
  url=http://${pubIp}:61621/v1/connection-status
  head=true
  while IFS= read -r line; do
    if $head; then
      if [[ -z $line ]]; then
        head=false
      else
        headers+=("$line")
      fi
    else
      body+=("$line")
    fi
  done < <(curl -sD - "$url" | sed 's/\r$//')
  unset IFS
  runningAgentVersion=$(printf "%s\n" "${headers[@]}" | grep X-Datastax-Agent-Version)
  runningAgentVersion=$(echo "${runningAgentVersion#*:}" | tr -d [:space:])
fi

# [2] find out the jar from running processes (this gets the version branch rather than necessarily the exact version)
if [[ -z $runningAgentVersion ]]; then
  runningAgentVersion=$(ssh -q -i ${sshKey} ${user}@${pubIp} "ps -ef | grep -v grep")
  runningAgentVersion=$(echo $runningAgentVersion | grep -o 'datastax-agent-[^ ]*' | sed 's/^\(datastax-agent\-\)*//' | sed -e 's/\(-standalone.jar\)*$//g' )
  if [[ -z ${runningAgentVersion} ]]; then
    prepare_generic_display_msgColourSimple "INFO-->" "agent version:         n/a"
  else
    prepare_generic_display_msgColourSimple "INFO-->" "agent jar version:     ${runningAgentVersion} (fyi)"
  fi
else
  prepare_generic_display_msgColourSimple "INFO-->" "agent version:         ${runningAgentVersion} (fyi)"
fi
}

# ---------------------------------------

function lib_doStuff_remotely_getOpscenterVersion(){

## try to identify opscenter version from running pid

runningOpsVersion=$(ssh -q -i ${sshKey} ${user}@${pubIp} "ps -ef | grep -v grep | grep -v -e '--pod pod_DSE-OPSCENTER' | grep -v -e '-p pod_DSE-OPSCENTER' | grep opscenter")
runningOpsVersion=$(echo $runningOpsVersion | grep -Po '(?<=opscenter-)[^/lib/]+' | head -n1 )
runningOpsVersion=$(echo ${runningOpsVersion%\_*})

if [[ -z ${runningOpsVersion} ]]; then
  runningOpsVersion="n/a"
fi
prepare_generic_display_msgColourSimple "INFO-->" "opscenter version:     ${runningOpsVersion}"
}
