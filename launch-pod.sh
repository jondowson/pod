#!/bin/bash

# script_name:   launch-pod.sh
# author:        jondowson
# about:         configure dse software and distribute to all servers in cluster

# ------------------------------------------

# uncomment to see full bash trace (debug)
#set -x

# timer for script duration
pod_start=$(date +%s)

# ------------------------------------------

BUILD_FOLDER="dse-5.1.5_template"
SERVERS_JSON="test.json"

# ------------------------------------------

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
pod_home_path="$(pwd)"

source lib/pod_generic/pod_generic_functions_get_ready.sh
pod_generic_functions_get_ready_identifyOs

# ------------------------------------------

# the path to the jq folder (pod dependency) 
jq_folder="${pod_home_path}/third_party/jq-linux64/"
# the path of the jq executable
jq_file_path="${jq_folder}jq"

# ------------------------------------------

## handle flags
which_pod="pod_dse"
source pods/${which_pod}.sh

# ------------------------------------------

pod_generic_functions_get_ready_sourceFiles

# ------------------------------------------

## assign servers_json_path

# the path of the /servers/<json> file to be used
pod_generic_functions_get_ready_serversJson
numberOfServers=$(${jq_folder}jq [.] ${servers_json_path} | tr '"' '\n' | grep 'server_' | wc -l)

## start the pod
$which_pod

# -----------------Final message

#generic_msg_final_message "${which_pod}"
