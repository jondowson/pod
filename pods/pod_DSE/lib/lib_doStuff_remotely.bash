# about:    non-generic functions executed on remote server

# if at all possible make generic functions and put them in
# 'pod_/lib/lib_generic_doStuff_remotely.bash'
# otherwise pod specific functions run remotely go here.

# ---------------------------------------

function lib_doStuff_remotely_cassandraTopologyProperties(){

## rename the deprecated cassandra-topology.properties to stop it interfering !!

# rename files and suppress error messages if file does not exist
topology_file_path="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${DSE_VERSION}/resources/cassandra/conf/cassandra-topology.properties"
mv "${topology_file_path}" "${topology_file_path}_old" 2>/dev/null
}

# ---------------------------------------

function lib_doStuff_remotely_agentAddressYaml(){

## configure bashrc to source bash_profile everytime a new terminal is started (on ubuntu/centos)

# file to edit
file="${agent_untar_config_folder}address.yaml"
touch ${file}

lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "stomp_interface:" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "use_ssl:" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="set_stomp_opscenter"
lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# add line sourcing .bashrc - no need on a Mac
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
stomp_interface: ${STOMP_INTERFACE}
use_ssl: 0
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}

# ---------------------------------------

function lib_doStuff_remotely_agentEnvironment(){

## configure JAVA_HOME for datastax-agent-env.sh - this function is not called on a Mac !!

# file to edit
file="${agent_untar_config_folder}datastax-agent-env.sh"
touch ${file}

# search for and remove any pre-canned blocks containing a label:
label="set_java_agent"
lib_generic_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# add line sourcing .bashrc
source ~/.bash_profile &>/dev/null
agent_java_home=$(echo ${JAVA_HOME})
if [[ "${agent_java_home}" == "" ]]; then
  prepare_generic_display_msgColourSimple "ERROR-->" "No JAVA_HOME found on this server !!"
fi
agent_java_home=$(echo ${agent_java_home} | sed 's/bin.*//')

cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
export JAVA_HOME="${agent_java_home}"
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}
