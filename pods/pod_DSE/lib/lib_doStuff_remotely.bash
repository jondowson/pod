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
lib_generic_doStuff_remotely_updatePathBashProfile "CASSANDRA_HOME" "${dse_untar_bin_folder}"
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

stop_cmd="${dse_untar_bin_folder}dse cassandra-stop"
# try twice to stop dse
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "3" ]] || [[ "${status}" == "0" ]]
  do
    dseVersion=$(ssh -q -i ${sshKey} ${user}@${pubIp} "${dse_untar_bin_folder}dse -v")
    prepare_generic_display_msgColourSimple "INFO-->" "stopping dse:     gracefully (version: ${dseVersion})"
    ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && ${stop_cmd}"
    status=${?}
    if [[ "${status}" == "0" ]]; then
      prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${green}${status}"
    else
      prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status} ${white}(retry ${retry}/2)"
      prepare_generic_display_msgColourSimple "INFO-->" "killing dse:     ungracefully"
      ssh -q -i ${sshKey} ${user}@${pubIp} "ps aux | grep cassandra | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
    fi
    stop_dse_error_array["${tag}"]="${status};${pubIp}"
    ((retry++))
  done
  printf "%s\n"
fi
}

# ---------------------------------------

function lib_doStuff_remotely_stopAgent(){

## run a command remotely to stop DSE gracefully and kill datastax-agent pid
## record result of commands in array for later reporting

# try twice to stop agent
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "3" ]] || [[ "${status}" == "0" ]]
  do
    prepare_generic_display_msgColourSimple "INFO-->" "killing agent:    ungracefully"
    ssh -q -i ${sshKey} ${user}@${pubIp} "ps aux | grep datastax-agent | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
    status=${?}
    if [[ "${status}" == "0" ]]; then
      prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${green}${status}"
    else
      prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status} ${white}(retry ${retry}/2)"
      prepare_generic_display_msgColourSimple "INFO-->" "killing agent:     ungracefully"
      ssh -q -i ${sshKey} ${user}@${pubIp} "ps aux | grep datastax-agent | grep -v grep | awk {'print \$2'} | xargs kill -9 &>/dev/null"
    fi
    stop_agent_error_array["${tag}"]="${status};${pubIp}"
    ((retry++))
  done
  printf "%s\n"
fi
}

# ---------------------------------------

function lib_doStuff_remotely_startDse(){

## run a command remotely to start DSE
## record result of commands in array for later reporting

start_dse="${dse_untar_bin_folder}dse cassandra${flags}"

# try twice to start dse + agent
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "3" ]] || [[ "${status}" == "0" ]]
  do
    ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && java -version"
    status=$?
    if [[ "${status}" != "0" ]]; then
      prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status}"
      if [[ "${STRICT_START}" ==  "true" ]]; then
        prepare_generic_display_msgColourSimple "ERROR-->" "Exiting pod: ${yellow}${task_file}${red} with ${yellow}--strict true${red} - java unavailable"
        exit 1;
      fi
      start_dse_error_array["${tag}"]="${status};${pubIp}"
      break;
    else
      output=$(ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && ${start_dse}" | grep 'Wait for nodes completed' )
      status=$?
      if [[ "${status}" != "0" ]] || [[ "${output}" != *"Wait for nodes completed"* ]]; then
        prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status} ${white}"
      else
        prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${green}${status}"
      fi
      start_dse_error_array["${tag}"]="${status};${pubIp}"
      ((retry++))
    fi
  done
  printf "%s\n"
fi
}

# ---------------------------------------

function lib_doStuff_remotely_startAgent(){

## run a command remotely to start datastax-agent
## record result of commands in array for later reporting

prepare_generic_display_msgColourSimple   "INFO-->" "starting:         dse agent"

start_agent="${agent_untar_bin_folder}/datastax-agent"
# try twice to start dse + agent
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "3" ]] || [[ "${status}" == "0" ]]
  do
    ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && java -version"
    status=$?
    if [[ "${status}" != "0" ]]; then
      prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status}"
      if [[ "${STRICT_START}" ==  "true" ]]; then
        prepare_generic_display_msgColourSimple "ERROR-->" "Exiting pod: ${yellow}${task_file}${red} with ${yellow}--strict true${red} - java unavailable"
        exit 1;
      fi
      start_agent_error_array["${tag}"]="${status};${pubIp}"
      break;
    else
      output=$(ssh -q -i ${sshKey} ${user}@${pubIp} "source ~/.bash_profile && ${start_agent}" | grep "Starting JMXComponent" )
      status=$?
      if [[ "${status}" != "0" ]] || [[ "${output}" != *"Starting JMXComponent"* ]]; then
        prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${red}${status} ${white}"
      else
        prepare_generic_display_msgColourSimple "INFO-->" "ssh return code: ${green}${status}"
      fi
      start_agent_error_array["${tag}"]="${status};${pubIp}"
      ((retry++))
    fi
  done
  printf "%s\n"
fi
}
