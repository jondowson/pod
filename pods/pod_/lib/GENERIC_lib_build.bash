function GENERIC_lib_build_sourceTarget(){

## assign build settings per the TARGET_FOLDER specified for this server

# write the target folder for this server to the temp file 'pod/misc/.suitcase'
printf "%s\n" "TARGET_FOLDER=${target_folder}"  > "${SUITCASE_FILE_PATH}"
# source the copied build_settings file in the tmp folder - that file will itself source the above file 'pod/misc/.suitcase'
source "${TMP_FILE_BUILDSETTINGS}"
}

# ------------------------------------------

function GENERIC_lib_build_suitcase(){

## pack the suitcase !!
## append (in order) server specific variables used by remotely run functions

# [1] LOCAL_TARGET_FOLDER - clear any existing values with first entry (i.e. '>')
printf "%s\n" "LOCAL_TARGET_FOLDER=${LOCAL_TARGET_FOLDER}"       > "${TMP_FILE_SUITCASE}"
# [2] TARGET_FOLDER
printf "%s\n" "TARGET_FOLDER=${target_folder}"                  >> "${TMP_FILE_SUITCASE}"
# [3] WHICH_POD
printf "%s\n" "WHICH_POD=${WHICH_POD}"                          >> "${TMP_FILE_SUITCASE}"
# [4] SERVERS_JSON
printf "%s\n" "server_id=${id}"                                 >> "${TMP_FILE_SUITCASE}"
servers_json_path_string="${target_folder}POD_SOFTWARE/POD/pod/servers/${SERVERS_JSON}"
printf "%s\n" "serversJsonPath=${servers_json_path_string}"   >> "${TMP_FILE_SUITCASE}"
# [5] BUILD_FOLDER
printf "%s\n" "BUILD_FOLDER=${BUILD_FOLDER}"                    >> "${TMP_FILE_SUITCASE}"
build_folder_path_string="${target_folder}POD_SOFTWARE/POD/pod/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
printf "%s\n" "build_folder_path=${build_folder_path_string}"   >> "${TMP_FILE_SUITCASE}"
}

# ------------------------------------------

function GENERIC_lib_build_jqListToArray(){

## read the cassandra data path(s) specified in the json into a bash array
## usage:
## GENERIC_lib_build_jqListToArray "cass_data"

# the name of the json key with the path(s)
jqlist="${1}"

## substitute the ${BUILD_FOLDER} variable if it is present in the path
data_path=$(jq -r --arg bf "${BUILD_FOLDER}" '.server_'${id}'.'${jqlist}'[] | sub("\\${BUILD_FOLDER}";$bf)' "${serversJsonPath}")
COUNTER=0
for path in ${data_path};
do
  arrayBuildSendData[${COUNTER}]=${path}
  (( COUNTER++ ))
done
}

# ------------------------------------------

function GENERIC_lib_build_sendPod(){

## send pod build to server

# any text will be error messages - so highlight in red
printf "%s" "${red}"

# check if server is local server
localServer="false"
localServer=$(GENERIC_lib_checks_localIpMatch "${pub_ip}")

# if not local server or installing elsewhere locally - delete any existing pod folder
if [[ "${localServer}" != "true" ]] || [[ "${LOCAL_TARGET_FOLDER}" != "${target_folder}" ]]; then
  ssh -q -o ForwardX11=no -i ${ssh_key} ${user}@${pub_ip} "rm -rf ${target_folder}POD_SOFTWARE/POD/pod" exit
fi

# if local server - copy from the tmp folder the value for target_folder
if [[ "${localServer}" == "true" ]]; then
  # this will subsequently be copied back to the local copy of misc/.suitcase, once all servers have been looped through
  # this will then be referenced when/if the launch remote script is run for the local machine (after it is then deleted)
  # this 'suitcase' file ensures each server gets variables relevant to it (paths,ips etc)
  cp "${TMP_FILE_SUITCASE}" ${podHomePath}/.suitcase.tmp
fi

# (re)create folder and send over updated pod software
# this will be merged locally
ssh -q -i ${ssh_key} ${user}@${pub_ip} "mkdir -p ${target_folder}POD_SOFTWARE/POD/pod/"
scp -q -o LogLevel=QUIET -i ${ssh_key} -r "${tmp_working_folder}" "${user}@${pub_ip}:${target_folder}POD_SOFTWARE/POD/"
status=${?}
arrayBuildSend["${tag}"]="${status};${pub_ip}"
# turn off red error highlighting
printf "%s" "${reset}"
}

# ------------------------------------------

function GENERIC_lib_build_finishUp(){

## tasks to finish up the build stage

# assign the local target_folder value back to the local copy of the misc/.suitcase
mv ${podHomePath}/.suitcase.tmp "${SUITCASE_FILE_PATH}"

# delete the temporary work folder
rm -rf "${tmp_folder}"
}
