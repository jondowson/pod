function lib_doStuffRemotely_pod_DSE(){

## this function is run on the remote machine and calls other remote functions in order

# [1] delete any previous pod build folder with the same name
rm -rf ${INSTALL_FOLDER_POD}${BUILD_FOLDER}

# [2] make folders
GENERIC_lib_doStuffRemotely_createFolders "${INSTALL_FOLDER_POD}${BUILD_FOLDER}"

# [3] un-compress software
GENERIC_lib_doStuffRemotely_unpackTar     "${DSE_FILE_TAR}"   "${INSTALL_FOLDER_POD}${BUILD_FOLDER}"
GENERIC_lib_doStuffRemotely_unpackTar     "${AGENT_FILE_TAR}" "${INSTALL_FOLDER_POD}${BUILD_FOLDER}"

# [4] merge the copied over 'resources' folder to the untarred one
cp -R "${build_folder_path}resources" "${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${dse_version}"

# [5] update the datastax-agent address.yaml to point to opscenter
lib_doStuffRemotely_agentAddressYaml

# [6] rename this redundant and meddlesome file!!
lib_doStuffRemotely_cassandraTopologyProperties

# [7] configure local environment
GENERIC_lib_doStuffRemotely_updateAppBashProfile "CASSANDRA_HOME" "${DSE_FOLDER_UNTAR_BIN}"
GENERIC_lib_doStuffRemotely_updatePodBashProfile "POD_HOME"       "${bash_path_string}"
}

# ---------------------------------------

function lib_doStuffRemotely_cassandraTopologyProperties(){

## rename the deprecated cassandra-topology.properties to stop it interfering !!

# rename files and suppress error messages if file does not exist
topology_file_path="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${dse_version}/resources/cassandra/conf/cassandra-topology.properties"
mv "${topology_file_path}" "${topology_file_path}_old" 2>/dev/null
}

# ---------------------------------------

function lib_doStuffRemotely_agentAddressYaml(){

## configure agent address.yaml to use ssl and point to the opscenter ip

# file to edit
file="${AGENT_FOLDER_UNTAR_CONFIG}address.yaml"
touch ${file}

GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "stomp_interface:" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "use_ssl:" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="set_stomp_opscenter"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# get stomp_interface value for this server
STOMP_INTERFACE=$(jq -r '.server_'${server_id}'.stomp_interface' "${serversJsonPath}")

# add block with space to end of file
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
stomp_interface: ${STOMP_INTERFACE}
use_ssl: 0
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}

# ---------------------------------------

function lib_doStuffRemotely_stopDse(){

## run a command remotely to stop DSE gracefully and kill datastax-agent pid
## record result of commands in array for later reporting

stop_cmd="dse cassandra-stop"

# try twice to stop dse
retry=1
until [[ "${retry}" == "3" ]]
do
  GENERIC_prepare_display_msgColourSimple "INFO-->"   "stopping dse:          gracefully"
  ssh -q -i ${ssh_key} ${user}@${pub_ip} "source ~/.bash_profile && ${stop_cmd}"
  if [[ -z "${output}" ]]; then
    GENERIC_prepare_display_msgColourSimple "INFO-->" "dse return code:       ${green}0${white}"
    retry=2
  elif [[ "${output}" == *"Unable to find DSE process"* ]]; then
    GENERIC_prepare_display_msgColourSimple "INFO-->" "dse return code:       ${green}n/a${white}"
    retry=2
  else
    GENERIC_prepare_display_msgColourSimple "INFO-->" "dse-stop fail:         ${white}(retry ${retry}/2)"
    GENERIC_prepare_display_msgColourSimple "INFO-->" "killing dse:           ungracefully"
    ssh -q -i ${ssh_key} ${user}@${pub_ip} "ps aux | grep cassandra | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
  fi
  arrayStopDse["${tag}"]="${status};${pub_ip}"
  ((retry++))
done
}

# ---------------------------------------

function lib_doStuffRemotely_stopAgent(){

## run a command remotely to stop DSE gracefully and kill datastax-agent pid
## record result of commands in array for later reporting

# try twice to stop agent
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  GENERIC_prepare_display_msgColourSimple "INFO-->" "stopping agent:        ungracefully"
  ssh -q -i ${ssh_key} ${user}@${pub_ip} "ps aux | grep datastax-agent | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
  status=${?}
  until [[ "${retry}" == "3" ]]
  do
    if [[ "${status}" == "0" ]]; then
      GENERIC_prepare_display_msgColourSimple "INFO-->" "agent return code:     ${green}${status}"
      retry=2
    else
      GENERIC_prepare_display_msgColourSimple "INFO-->" "stopping agent:        ${red}${status} ${white}(retry ${retry}/2)"
      ssh -q -i ${ssh_key} ${user}@${pub_ip} "ps aux | grep datastax-agent | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
      status=${?}
    fi
    arrayStopAgent["${tag}"]="${status};${pub_ip}"
    ((retry++))
  done
fi
}

# ---------------------------------------

function lib_doStuffRemotely_checkJava(){

## run a command remotely to check Java is installed

# try once to check java is installed
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "2" ]] || [[ "${status}" == "0" ]]
  do
    # display java output in different color
    printf "%s" "${yellow}"
    output=$(ssh -q -i ${ssh_key} ${user}@${pub_ip} "source ~/.bash_profile && java -version" )
    status=$?
    printf "%s" "${reset}"
    if [[ "${status}" != "0" ]]; then
      GENERIC_prepare_display_msgColourSimple "INFO-->"    "java return code:      ${red}${status}"
      if [[ "${STRICT_START}" ==  "true" ]]; then
        GENERIC_prepare_display_msgColourSimple "ERROR-->" "Exiting pod: ${yellow}${task_file}${red} with ${yellow}--strict true${red} - java unavailable"
        exit 1;
      fi
      break;
    else
      GENERIC_prepare_display_msgColourSimple "INFO-->"    "java return code:      ${green}${status}"
      ((retry++))
    fi
  done
fi
}

# ---------------------------------------

function lib_doStuffRemotely_startDse(){

## run a command remotely to start DSE
## record result of commands in array for later reporting

# source bash_profile to ensure correct java version is used
start_dse="source ~/.bash_profile && ${DSE_FOLDER_UNTAR_BIN}dse cassandra${flags}"

# try twice to start dse
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "3" ]] || [[ "${status}" == "0" ]]
  do
    # leave space before last closing brace )
    output=$(ssh -i ${ssh_key} ${user}@${pub_ip} "${start_dse}" | grep 'Wait for nodes completed' )
    status=$?
    if [[ "${status}" != "0" ]] || [[ "${output}" != *"Wait for nodes completed"* ]]; then
      GENERIC_prepare_display_msgColourSimple "INFO-->" "dse return code:       ${red}${status}${white}"
    else
      GENERIC_prepare_display_msgColourSimple "INFO-->" "dse return code:       ${green}${status}"
    fi
    arrayStartDse["${tag}"]="${status};${pub_ip}"
    ((retry++))
  done
fi
}

# ---------------------------------------

function lib_doStuffRemotely_startAgent(){

## run a command remotely to start datastax-agent
## record result of commands in array for later reporting

GENERIC_prepare_display_msgColourSimple "INFO-->" "starting agent:        ~15s"
cmd="source ~/.bash_profile && ${AGENT_FOLDER_UNTAR_BIN}datastax-agent"                         # start command + source bash_profile to ensure correct java version is used
log_to_check="${AGENT_FOLDER_UNTAR_LOG}agent.log"                                               # log folder to check for keyphrase
keyphrase="Starting StompComponent"                                                             # if this appears in logs - then assume success!
response_label="agent return code:"                                                             # label for response codes
retryTimes="11"                                                                                 # try x times to inspect logs for success
pauseTime="2"                                                                                   # pause between log look ups
tailCount="30"                                                                                  # how many lines to grab from end of log - relationship with pause time + speed logs are written


ssh -q -i ${ssh_key} ${user}@${pub_ip} "${cmd} &>~/.cmdOutput"                                  # run opscenter for the specified build
sleep 5                                                                                         # give the chance for script to run + logs to fill up
cmdOutput=$(ssh -q -i ${ssh_key} ${user}@${pub_ip} "cat ~/.cmdOutput && rm -rf ~/.cmdOutput" )  # grab any command output - could be a clue to a failure

retry=1
until [[ "${retry}" == "${retryTimes}" ]]                                                       # try x times with a sleep pause between attempts
do
  sleep ${pauseTime}                                                                            # take a break - have a kitkat
  output=$(ssh -q -i ${ssh_key} ${user}@${pub_ip}  "tail -n ${tailCount} ${log_to_check} | tr '\0' '\n'")   # grab opscenter log and handle null point warning
  if [[ "${output}" == *"${keyphrase}"* ]]; then
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${response_label}     ${green}0${white}"
    retry=10
    success="true"
  fi
  if [[ "${retry}" == "10" ]] && [[ "${success}" != "true" ]]; then                             # failure messages
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${response_label} ${red}1 - You may ned to kill any existing agent process as root !!${reset}"
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${response_label} ${red}1 - Is the right Java version installed [ ${cmdOutput} ] !!${reset}"
  fi
  arrayStartOpscenter["${tag}"]="${status};${pub_ip}"
  ((retry++))
done
}

# ---------------------------------------

function lib_doStuffRemotely_getAgentVersion(){

## try 2 approaches to identify running agent version

# [1] use agent api to discover version (first check curl is available)
ssh -q -i ~/.ssh/id_rsa jd@127.0.0.1 "curl &>/dev/null"
if [[ $? == "0" ]]; then
  url=http://${pub_ip}:61621/v1/connection-status
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
  runningAgentVersion=$(ssh -q -i ${ssh_key} ${user}@${pub_ip} "ps -ef | grep -v grep")
  runningAgentVersion=$(echo $runningAgentVersion | grep -o 'datastax-agent-[^ ]*' | sed 's/^\(datastax-agent\-\)*//' | sed -e 's/\(-standalone.jar\)*$//g' )
  if [[ -z ${runningAgentVersion} ]]; then
    GENERIC_prepare_display_msgColourSimple "INFO-->" "agent version:         n/a"
  else
    GENERIC_prepare_display_msgColourSimple "INFO-->" "agent jar version:     ${runningAgentVersion}"
  fi
else
  GENERIC_prepare_display_msgColourSimple "INFO-->" "agent version:         ${runningAgentVersion}"
fi
}

# ---------------------------------------

function lib_doStuffRemotely_getDseVersion(){

## try to identify opscenter version from running pid

runningDseVersion=$(ssh -q -i ${ssh_key} ${user}@${pub_ip} "ps -ef | grep -v grep | grep -v -e '--pod pod_DSE' | grep -v -e '-p pod_DSE' | grep dse")
runningDseVersion=$(echo $runningDseVersion | grep -Po '(?<=dse-core-)[^/lib/]+' | head -n1 )
runningDseVersion=$(echo ${runningDseVersion%\.jar:})

if [[ -z ${runningDseVersion} ]]; then
  runningDseVersion="n/a"
fi
GENERIC_prepare_display_msgColourSimple "INFO-->" "dse version:           ${runningDseVersion}"
}
