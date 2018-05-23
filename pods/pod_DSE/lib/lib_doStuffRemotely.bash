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

# [7] create stop and start scripts that can be called from opscenter gui
lib_doStuffRemotely_agentStopCassandra
lib_doStuffRemotely_agentStartCassandra

# [8] configure local environment
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
tmpStatusFile=${podHomePath}.cmdOutput

# try twice to stop dse
retry=1
until [[ "${retry}" == "3" ]]
do
  GENERIC_prepare_display_msgColourSimple   "INFO-->"  "stopping dse:              gracefully"
  command=$(ssh -q -i ${ssh_key} ${user}@${pub_ip} "source ~/.bash_profile && ${stop_cmd}" &> ${tmpStatusFile})
  status=$?
  output=$(cat ${tmpStatusFile} && rm -rf ${tmpStatusFile})
  if [[ "${status}" == "0" ]] && [[ "${output}" == "" ]]; then
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${green}0${white}"
    retry=2
  elif [[ "${output}" == *"Unable to find DSE process"* ]]; then
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${green}n/a${white}"
    retry=2
  else
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${white}(retry ${retry}/2)"
    GENERIC_prepare_display_msgColourSimple "INFO-->" "killing dse:                ungracefully"
    ssh -q -i ${ssh_key} ${user}@${pub_ip} "ps aux | grep -v grep | grep -v '\-p\ pod_DSE' | grep -v '\--pod\ pod_DSE' | grep cassandra | awk {'print \$2'} | xargs kill -9 &>/dev/null"
  fi
  arrayStopDse["stop_dse_at_${tag}"]="${status};${pub_ip}"
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
  GENERIC_prepare_display_msgColourSimple     "INFO-->" "stopping agent:            ungracefully"
  ssh -q -i ${ssh_key} ${user}@${pub_ip} "ps aux | grep -v grep | grep -v '\-p\ pod_DSE' | grep -v '\--pod\ pod_DSE' | grep datastax-agent | awk {'print \$2'} | xargs kill -9 &>/dev/null"
  status=${?}
  until [[ "${retry}" == "3" ]]
  do
    if [[ "${status}" == "0" ]]; then
      GENERIC_prepare_display_msgColourSimple "INFO-->" "${green}${status}"
      retry=2
    else
      GENERIC_prepare_display_msgColourSimple "INFO-->" "${red}${status} ${white}(retry ${retry}/2)"
      ssh -q -i ${ssh_key} ${user}@${pub_ip} "ps aux | grep -v grep | grep -v '\-p\ pod_DSE' | grep -v '\--pod\ pod_DSE' | grep datastax-agent | awk {'print \$2'} | xargs kill -9 &>/dev/null"
      status=${?}
    fi
    arrayStopAgent["stop_agent_at_${tag}"]="${status};${pub_ip}"
    ((retry++))
  done
fi
}

# ---------------------------------------

function lib_doStuffRemotely_startDse(){

## run a command remotely to start DSE
## record result of commands in array for later reporting

# source bash_profile to ensure correct java version is used
start_dse="source ~/.bash_profile && ${DSE_FOLDER_UNTAR_BIN}dse cassandra ${dseFlags}"

# try twice to start dse
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "3" ]] || [[ "${status}" == "0" ]]
  do
    # leave space before last closing brace )
    output=$(ssh -x -i ${ssh_key} ${user}@${pub_ip} "${start_dse}" | grep 'Wait for nodes completed' )
    status=$?
    if [[ "${status}" != "0" ]] || [[ "${output}" != *"Wait for nodes completed"* ]]; then
      GENERIC_prepare_display_msgColourSimple "INFO-->" "${red}${status}${white}"
    else
      GENERIC_prepare_display_msgColourSimple "INFO-->" "${green}${status}"
    fi
    arrayStartDse["start_dse_at_${tag}"]="${status};${pub_ip}"
    ((retry++))
  done
fi
}

# ---------------------------------------

function lib_doStuffRemotely_startAgent(){

## run a command remotely to start datastax-agent
## record result of commands in array for later reporting

cmd="source ~/.bash_profile && ${AGENT_FOLDER_UNTAR_BIN}datastax-agent"                         # start command + source bash_profile to ensure correct java version is used
log_to_check="${AGENT_FOLDER_UNTAR_LOG}agent.log"                                               # log folder to check for keyphrase
keyphrase="Finished starting system"                                                            # if this appears in logs - then assume success!
response_label="agent:"                                                                         # label for response codes
retries="11"                                                                                    # try x times to inspect logs for success
pauseTime="2"                                                                                   # pause between log look ups
tailCount="30"                                                                                  # how many lines to grab from end of log - relationship with pause time + speed logs are written

ssh -q -i ${ssh_key} ${user}@${pub_ip} "${cmd} &>~/.cmdOutput"                                  # run opscenter for the specified build and capture its output (java)
sleep 10                                                                                        # give the chance for script to run + logs to fill up
cmdOutput=$(ssh -q -i ${ssh_key} ${user}@${pub_ip} "cat ~/.cmdOutput && rm -rf ~/.cmdOutput" )  # grab any command output - could be a clue to a failure

retry=1
until [[ "${retry}" == "${retries}" ]]                                                          # try x times with a sleep pause between attempts
do
  sleep ${pauseTime}                                                                            # take a break - have a kitkat
  # grab agent log and handle null point warning
  output=$(ssh -q -i ${ssh_key} ${user}@${pub_ip} "tail -n ${tailCount} ${log_to_check} | tr '\0' '\n'")
  if [[ "${output}" == *"${keyphrase}"* ]]; then
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${green}0${white}"
    success="true"
    break;
  elif [[ "${retry}" == "$((retries-1))" ]] && [[ "${success}" != "true" ]]; then                             # failure messages
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${response_label}          ${red}You may ned to kill any existing agent process as root !!${reset}"
    GENERIC_prepare_display_msgColourSimple "INFO-->" "${response_label}          ${red}Is the right Java version installed [ ${cmdOutput} ] ??${reset}"
  fi
  arrayStartAgent["start_agent_at_${tag}"]="${status};${pub_ip}"
  ((retry++))
done
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

# ---------------------------------------

function lib_doStuffRemotely_agentStartCassandra(){

## writes a dse start script in agent bin folder that can be used directly from opscenter

file="${AGENT_FOLDER_UNTAR_BIN}start-cassandra"
rm -rf ${file}
touch ${file}
chmod 755 ${file}

# add block with space to end of file
cat << EOF >> ${file}
#!/bin/bash

source ~/.bash_profile
\$CASSANDRA_HOME/dse cassandra \${dseFlags}
ret=\$?
# accept exit status of 0 or 1
if [ "\$ret" -eq "0" -o "\$ret" -eq "1" ]; then
    exit 0
else
    exit \$ret
fi
EOF
}

# ---------------------------------------

function lib_doStuffRemotely_agentStopCassandra(){

## writes a dse start script in agent bin folder that can be used directly from opscenter

file="${AGENT_FOLDER_UNTAR_BIN}stop-cassandra"
rm -rf ${file}
touch ${file}
chmod 755 ${file}

# add block with space to end of file
cat << EOF >> ${file}
#!/bin/bash

source ~/.bash_profile
\$CASSANDRA_HOME/dse cassandra-stop
ret=\$?
# accept exit status of 0 or 1
if [ "\$ret" -eq "0" -o "\$ret" -eq "1" ]; then
    exit 0
else
    ps -ef | grep -v grep | grep cassandra | awk {'print \$2'} | xargs kill -9
    if [ "\$ret" -eq "0" -o "\$ret" -eq "1" ]; then
        exit 0
    else
      exit \$ret
    fi
fi
EOF
}

# ---------------------------------------

function lib_doStuffRemotely_bashProfileAgentStartFlags(){

## write flags to a bash_profile variable for use by opscenter + pod_DSE restart commands

# [1] handle the flags used to start dse in the correct mode
dseFlags=""
if [[ "${mode_search}"    == "true" ]];  then dseFlags="${dseFlags} -s"; fi
if [[ "${mode_analytics}" == "true" ]];  then dseFlags="${dseFlags} -k"; fi
if [[ "${mode_graph}"     == "true" ]];  then dseFlags="${dseFlags} -g"; fi

if [[ ${os} == "Mac" ]]; then
  bashProfilePath="/Users/${user}/.bash_profile"
else
  bashProfilePath="/home/${user}/.bash_profile"
fi

# [2] prepare payload of variables
file="${bashProfilePath}"
label="dseFlags_bash_profile"
block=$(printf %q "export dseFlags=\"${dseFlags}\"")
payload1="${file} ${label} ${block} ${WHICH_POD}"
payload2="${file} ${label} ${block}"

# [3] call launch script
remoteScript="${target_folder}POD_SOFTWARE/POD/pod/pods/pod_/scripts/GENERIC_scripts_fileUpdateBlock.sh"
ssh -ttq -o "BatchMode yes" -o "ForwardX11=no" ${user}@${pub_ip} "chmod 755 ${remoteScript} && ${remoteScript} ${payload1}" > /dev/null 2>&1
}
