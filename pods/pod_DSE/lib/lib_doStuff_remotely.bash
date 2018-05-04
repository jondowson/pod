function lib_doStuff_remotely_pod_DSE(){

## this function is run on the remote machine and calls other remote functions in order

# [1] delete any previous pod build folder with the same name
rm -rf ${INSTALL_FOLDER_POD}${BUILD_FOLDER}

# [2] make folders
lib_generic_doStuff_remotely_createFolders "${INSTALL_FOLDER_POD}${BUILD_FOLDER}"

# [3] un-compress software
lib_generic_doStuff_remotely_unpackTar "${dse_tar_file}" "${INSTALL_FOLDER_POD}${BUILD_FOLDER}"
lib_generic_doStuff_remotely_unpackTar "${agent_tar_file}" "${INSTALL_FOLDER_POD}${BUILD_FOLDER}"

# [4] merge the copied over 'resources' folder to the untarred one
cp -R "${build_folder_path}resources" "${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${DSE_VERSION}"

# [5] update the datastax-agent address.yaml to point to opscenter
lib_doStuff_remotely_agentAddressYaml

# [6] rename this redundant and meddlesome file !!
lib_doStuff_remotely_cassandraTopologyProperties

# [7] configure local environment
lib_generic_doStuff_remotely_updateAppBashProfile "CASSANDRA_HOME" "${dse_untar_bin_folder}"
lib_generic_doStuff_remotely_updatePodBashProfile "POD_HOME" "${bash_path_string}"
}

# ---------------------------------------

function lib_doStuff_remotely_cassandraTopologyProperties(){

## rename the deprecated cassandra-topology.properties to stop it interfering !!

# rename files and suppress error messages if file does not exist
topology_file_path="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${DSE_VERSION}/resources/cassandra/conf/cassandra-topology.properties"
mv "${topology_file_path}" "${topology_file_path}_old" 2>/dev/null
}

# ---------------------------------------

function lib_doStuff_remotely_agentAddressYaml(){

## configure agent address.yaml to use ssl and point to the opscenter ip

# file to edit
file="${agent_untar_config_folder}address.yaml"
touch ${file}

lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "stomp_interface:" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "use_ssl:" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="set_stomp_opscenter"
lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# get stomp_interface value for this server
STOMP_INTERFACE=$(jq -r '.server_'${server_id}'.stomp_interface' "${servers_json_path}")

# add block with space to end of file
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
stomp_interface: ${STOMP_INTERFACE}
use_ssl: 0
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}

# ---------------------------------------

function lib_doStuff_remotely_stopDse(){

## run a command remotely to stop DSE gracefully and kill datastax-agent pid
## record result of commands in array for later reporting

stop_cmd="dse cassandra-stop"

# try twice to stop dse
retry=1
until [[ "${retry}" == "3" ]]
do
  prepare_generic_display_msgColourSimple "INFO-->"   "stopping dse:          gracefully"
  ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && ${stop_cmd} &>~/.cmdOutput"
  output=$(ssh -q -i ${sshKey} ${user}@${pubIp} "cat ~/.cmdOutput && rm -rf ~/.cmdOutput" )
  if [[ -z "${output}" ]]; then
    prepare_generic_display_msgColourSimple "INFO-->" "dse return code:       ${green}0${white}"
    retry=2
  elif [[ "${output}" == *"Unable to find DSE process"* ]]; then
    prepare_generic_display_msgColourSimple "INFO-->" "dse return code:       ${green}n/a${white}"
    retry=2
  else
    prepare_generic_display_msgColourSimple "INFO-->" "dse-stop fail:         ${white}(retry ${retry}/2)"
    prepare_generic_display_msgColourSimple "INFO-->" "killing dse:           ungracefully"
    ssh -q -i ${sshKey} ${user}@${pubIp} "ps aux | grep cassandra | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
  fi
  stop_dse_error_array["${tag}"]="${status};${pubIp}"
  ((retry++))
done
}

# ---------------------------------------

function lib_doStuff_remotely_stopAgent(){

## run a command remotely to stop DSE gracefully and kill datastax-agent pid
## record result of commands in array for later reporting

# try twice to stop agent
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  prepare_generic_display_msgColourSimple "INFO-->" "stopping agent:        ungracefully"
  ssh -q -i ${sshKey} ${user}@${pubIp} "ps aux | grep datastax-agent | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
  status=${?}
  until [[ "${retry}" == "3" ]]
  do
    if [[ "${status}" == "0" ]]; then
      prepare_generic_display_msgColourSimple "INFO-->" "agent return code:     ${green}${status}"
      retry=2
    else
      prepare_generic_display_msgColourSimple "INFO-->" "stopping agent:        ${red}${status} ${white}(retry ${retry}/2)"
      ssh -q -i ${sshKey} ${user}@${pubIp} "ps aux | grep datastax-agent | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
      status=${?}
    fi
    stop_agent_error_array["${tag}"]="${status};${pubIp}"
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

function lib_doStuff_remotely_startDse(){

## run a command remotely to start DSE
## record result of commands in array for later reporting

# source bash_profile to ensure correct java version is used
start_dse="source ~/.bash_profile && ${dse_untar_bin_folder}dse cassandra${flags}"

# try twice to start dse
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "3" ]] || [[ "${status}" == "0" ]]
  do
    # leave space before last closing brace )
    output=$(ssh -i ${sshKey} ${user}@${pubIp} "${start_dse}" | grep 'Wait for nodes completed' )
    status=$?
    if [[ "${status}" != "0" ]] || [[ "${output}" != *"Wait for nodes completed"* ]]; then
      prepare_generic_display_msgColourSimple "INFO-->" "dse return code:       ${red}${status}${white}"
    else
      prepare_generic_display_msgColourSimple "INFO-->" "dse return code:       ${green}${status}"
    fi
    start_dse_error_array["${tag}"]="${status};${pubIp}"
    ((retry++))
  done
fi
}

# ---------------------------------------

function lib_doStuff_remotely_startAgent(){

## run a command remotely to start datastax-agent
## record result of commands in array for later reporting

prepare_generic_display_msgColourSimple "INFO-->" "starting agent: ~ 15s"
# source bash_profile to ensure correct java version is used
start_agent="source ~/.bash_profile && ${agent_untar_bin_folder}/datastax-agent"

retry=1
until [[ "${retry}" == "3" ]]                                                                                         # try twice to start agent
do
  ssh -q -i ${sshKey} ${user}@${pubIp} "${start_agent} &>~/.cmdOutput" &                                              # run the agent for the specified build
  sleep 10                                                                                                            # give the logs a chance to fill up
  cmdOutput=$(ssh -q -i ${sshKey} ${user}@${pubIp} "cat ~/.cmdOutput && rm -rf ~/.cmdOutput" )                        # command output is java version - grab it
  output=$(ssh -q -i ${sshKey} ${user}@${pubIp}    "tail -n 50 ${agent_untar_log_folder}agent.log | tr '\0' '\n'" )   # grab agent log and handle null point warning
  lastbit=$(ssh -q -i ${sshKey} ${user}@${pubIp}   "tail -n 1 ${agent_untar_log_folder}agent.log" )                   # grab the last line of log for any error message

  if [[ "${output}" != *"Starting JMXComponent"* ]]; then
    prepare_generic_display_msgColourSimple "INFO-->" "agent return code:     ${red}${cmdOutput}${reset}"
    prepare_generic_display_msgColourSimple "INFO-->" "agent return code:     ${red}${lastbit}${reset}"
  else
    prepare_generic_display_msgColourSimple "INFO-->" "agent return code:     ${green}0${white}"
    retry=2
  fi
  start_agent_error_array["${tag}"]="${status};${pubIp}"
  ((retry++))
done
}

# ---------------------------------------

function lib_doStuff_remotely_getAgentVersion(){

## try 2 approaches to identify running agent version

# [1] use agent api to discover version
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

# [2] find out the jar from running processes (this gets the version branch rather than necessarily the exact version)
if [[ -z $runningAgentVersion ]]; then
  runningAgentVersion=$(ssh -q -i ${sshKey} ${user}@${pubIp} "ps -ef | grep -v grep")
  runningAgentVersion=$(echo $runningAgentVersion | grep -o 'datastax-agent-[^ ]*' | sed 's/^\(datastax-agent\-\)*//' | sed -e 's/\(-standalone.jar\)*$//g' )
  if [[ -z ${runningAgentVersion} ]]; then
    prepare_generic_display_msgColourSimple "INFO-->" "agent version:         n/a"
  else
    prepare_generic_display_msgColourSimple "INFO-->" "agent jar version:     ${runningAgentVersion}"
  fi
else
  prepare_generic_display_msgColourSimple "INFO-->" "agent version:         ${runningAgentVersion}"
fi
}

# ---------------------------------------

function lib_doStuff_remotely_getDseVersion(){

## try to identify opscenter version from running pid

podInput=$(printf "%q" ${podInput})
runningDseVersion=$(ssh -q -i ${sshKey} ${user}@${pubIp} "ps -ef | grep -v grep | grep -v -e '--pod pod_DSE' | grep -v -e '-p pod_DSE' | grep dse")
runningDseVersion=$(echo $runningDseVersion | grep -Po '(?<=dse-core-)[^/lib/]+' | head -n1 )
runningDseVersion=$(echo ${runningDseVersion%\.jar:})

if [[ -z ${runningDseVersion} ]]; then
  runningDseVersion="n/a"
fi
prepare_generic_display_msgColourSimple "INFO-->" "dse version:           ${runningDseVersion}"
}
