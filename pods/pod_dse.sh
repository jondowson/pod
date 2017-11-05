#!/bin/bash

# script_name:   pod_dse.sh
# author:        jondowson
# about:         configure dse software and distribute to all servers in cluster

## test specified files exist

# check /servers/<json> file exists
generic_file_exists_check_abort "${servers_json_path}"

# test DSE_SOFTWARE folder is available
if [[ "${SEND_DSE_SOFTWARE}" == "true" ]]; then
  generic_folder_exists_check_abort "${DSE_SOFTWARE}"
  generic_file_exists_check_abort "${dse_tar_file}"
  generic_file_exists_check_abort "${java_tar_file}"
fi

# test java folder is available
if [[ "${JAVA_INSTALL_TYPE}" == ""tar"" ]]; then
  generic_file_exists_check_abort "${java_tar_file}"
fi  

# check jq library is available
generic_file_exists_check_abort "${jq_file_path}"

# -----------------------------------------

numberOfServers=$(${jq_folder}jq [.] ${servers_json_path} | tr '"' '\n' | grep 'server_' | wc -l)

# -----------------------------------------

# STAGE [1] - prepare local 'resources' folder - the basis for the 'build(s)'

if [ "${REGENERATE_RESOURCES}" == true ]; then ${podSetupFolder}misc/prepare_resources_folder.sh "${BUILD_FOLDER}" "${STAGE_PAUSE}"; fi

# -----------------------------------------

## prepare duplicate version of 'pod' project

# this includes the a copy of the local resources folder
# this duplicate folder will be configured locally and then sent to remote server(s)

tmp_build_folder="${podSetupFolder}tmp/pod/"
tmp_build_file_folder="${tmp_build_folder}builds/pod_dse/${BUILD_FOLDER}/"
tmp_build_file_path="${tmp_build_file_folder}cluster_settings.sh"

# delete any existing duplicated 'pod' folder from '/tmp'
tmp_folder="${podSetupFolder}tmp/"
rm -rf "${tmp_folder}"

# duplicate 'pod' folder to working directory '/tmp'
tmp_working_folder="${podSetupFolder}tmp/pod/"
mkdir -p "${tmp_working_folder}"
cp -r "${podSetupFolder}builds" "${tmp_working_folder}"
cp -r "${podSetupFolder}lib" "${tmp_working_folder}"
cp -r "${podSetupFolder}misc" "${tmp_working_folder}"
cp -r "${podSetupFolder}servers" "${tmp_working_folder}"
cp ${podSetupFolder}*.md "${tmp_working_folder}"
cp ${podSetupFolder}*.sh "${tmp_working_folder}"

#-------------------------------------------

## create arrays for capturing errors

declare -A pod_test_connect_error_array
declare -A pod_test_send_error_array_1
declare -A pod_test_send_error_array_2
declare -A pod_test_send_error_array_3
declare -A pod_build_send_error_array
declare -A pod_software_send_pid_array 
declare -A pod_build_run_pid_array
declare -A pod_build_launch_pid_array

#-------------------------------------------

## ( STAGES { TASKS [steps] } )

banner
generic_msg_colour_simple "STAGE" "STAGE: Test Cluster Readiness"
generic_msg_colour_simple "TASK"  "TASK: Testing server connectivity"
task_pod_test_connect
task_pod_test_connect_report
generic_msg_colour_simple "TASK"  "TASK: Testing server write-paths"
task_pod_test_write
task_pod_test_write_report
generic_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..."

# ----------

banner
generic_msg_colour_simple "STAGE" "STAGE: Create Pod For Each Server"
generic_msg_colour_simple "TASK"  "TASK: Configuring and sending pod "
task_pod_build_send
task_pod_build_send_report
rm -rf "${tmp_folder}"
generic_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..." 

# ----------

if [[ "${SEND_DSE_SOFTWARE}" == true ]]; then
  banner
  generic_msg_colour_simple "STAGE" "STAGE: Send DSE_SOFTWARE To Each Server"
  generic_msg_colour_simple "TASK"  "TASK: Sending DSE_SOFTWARE in parallel"
  task_pod_software_send
  task_pod_software_send_report
  generic_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..." 
fi

# ----------

banner
generic_msg_colour_simple "STAGE" "STAGE: Launch Pod On Each Server"
generic_msg_colour_simple "TASK"  "TASK: Running launch script remotely"
task_pod_launch_remote
task_pod_launch_remote_report
generic_timecount "${STAGE_PAUSE}" "Proceeding to next STAGE..." 

#-------------------------------------------

## summary

banner
generic_msg_colour_simple "STAGE" "Finished !!"                                                                        && sleep "${STEP_PAUSE}"
task_pod_build_send_report
task_pod_launch_remote_report
generic_msg_colour_simple "TASK" "Next Steps"                                                                          && sleep "${STEP_PAUSE}"

# -----------------script timings

if   [[ "${REGENERATE_RESOURCES}" == "true" ]]  &&  [[ "${SEND_DSE_SOFTWARE}" == "true" ]]; then
  stage_count=5
elif [[ "${REGENERATE_RESOURCES}" == "false" ]] &&  [[ "${SEND_DSE_SOFTWARE}" == "true" ]] ; then
  stage_count=3
elif [[ "${REGENERATE_RESOURCES}" == "true" ]]  &&  [[ "${SEND_DSE_SOFTWARE}" == "false" ]] ; then
  stage_count=4
else
  stage_count=2
fi

# calculate added pauses
sleep_steps=$(($((STEP_PAUSE * $(grep -c '&& sleep ${STEP_PAUSE}' pod_dse.sh)))-1))
if [[ $sleep_steps -eq -1 ]]; then sleep_steps=0; fi
sleep_stages=$((STAGE_PAUSE * stage_count))
total_sleep=$((sleep_steps + sleep_stages))

# calculate script runtime
script_end=$(date +%s)
diff=$((script_end - script_start))
actual_runtime=$((diff - total_sleep))

generic_msg_colour_simple "info" "script completion time:     ${diff}"
generic_msg_colour_simple "info" "(actual ignoring sleep):    ${actual_runtime}"
printf "%s\n"

# -----------------Final message

if [[ ${os} == "Mac" ]] || [[ ${JAVA_INSTALL_TYPE} != "tar" ]]; then
  generic_msg_colour_simple "title"     "Final tasks to complete pod"
  generic_msg_colour_simple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
  generic_msg_colour_simple "info"      "$ . ~/.bash_profile"
  generic_msg_colour_simple "info-bold" "(b) Run dse:"
  generic_msg_colour_simple "info"      "$ dse cassandra            # start dse storage"
  generic_msg_colour_simple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
elif [[ "${JAVA_INSTALL_TYPE}" == "tar" ]]; then
  generic_msg_colour_simple "title"     "Final tasks to complete pod"
  generic_msg_colour_simple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
  generic_msg_colour_simple "info"      "$ . ~/.bash_profile"
  generic_msg_colour_simple "info-bold" "(b) Add java tar to system java alternatives - you may have to alter yellow portion of path:"
  generic_msg_colour_simple "info"      "$ sudo update-alternatives --install /usr/bin/java java ${yellow}${java_untar_folder}${white}${JAVA_VERSION}/bin/java 100"
  generic_msg_colour_simple "info-bold" "(c) Select this java tar from list:"
  generic_msg_colour_simple "info"      "$ sudo update-alternatives --config java"
  generic_msg_colour_simple "info-bold" "(d) Run dse:"
  generic_msg_colour_simple "info"      "$ dse cassandra            # start dse storage"
  generic_msg_colour_simple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
fi
printf "%s\n"
