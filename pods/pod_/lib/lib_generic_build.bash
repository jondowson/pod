# about:    functions that create the bespoke pod build for each server

# ------------------------------------------

function lib_generic_build_sourceTarget(){

## assign build settings per the TARGET_FOLDER specified for this server

# write the target folder for this server to the temp file 'pod/misc/.suitcase'
printf "%s\n" "TARGET_FOLDER=${target_folder}"  > "${suitcase_file_path}"
# source the copied build_settings file in the tmp folder - that file will itself source the above file 'pod/misc/.suitcase'
source "${tmp_build_settings_file_path}"
}

# ------------------------------------------

function lib_generic_build_suitcase(){

## pack the suitcase !!
## append (in order) server specific variables used by remotely run functions

# [1] TARGET_FOLDER - clear any existing values with first entry (i.e. '>')
printf "%s\n" "TARGET_FOLDER=${target_folder}"                  > "${tmp_suitcase_file_path}"
# [2] WHICH_POD
printf "%s\n" "WHICH_POD=${WHICH_POD}"                          >> "${tmp_suitcase_file_path}"
# [3] SERVERS_JSON
printf "%s\n" "which_server=${id}"                              >> "${tmp_suitcase_file_path}"
servers_json_path_string="${target_folder}POD_SOFTWARE/POD/pod/servers/${SERVERS_JSON}"
printf "%s\n" "servers_json_path=${servers_json_path_string}"   >> "${tmp_suitcase_file_path}"
# [4] BUILD_FOLDER
printf "%s\n" "BUILD_FOLDER=${BUILD_FOLDER}"                    >> "${tmp_suitcase_file_path}"
build_folder_path_string="${target_folder}POD_SOFTWARE/POD/pod/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
printf "%s\n" "build_folder_path=${build_folder_path_string}"   >> "${tmp_suitcase_file_path}"
}

# ------------------------------------------

function lib_generic_build_jqListToArray(){

## read the cassandra data path(s) specified in the json into a bash array
## usage:
## lib_generic_build_jqListToArray "cass_data"

# the name of the json key with the path(s)
jqlist="${1}"

## substitute the ${BUILD_FOLDER} variable if it is present in the path
data_path=$(jq -r --arg bf "${BUILD_FOLDER}" '.server_'${id}'.'${jqlist}'[] | sub("\\${BUILD_FOLDER}";$bf)' "${servers_json_path}")
COUNTER=0
for path in ${data_path};
do
  build_send_data_array[${COUNTER}]=${path}
  (( COUNTER++ ))
done
}

# ------------------------------------------

function lib_generic_build_sendPod(){

## send pod build to server

# check if os is mac
if [[ "${remote_os}" == "Mac" ]]; then
  prepare_generic_display_msgColourSimple "INFO-->" "sending:     dummy pod build"
else
  prepare_generic_display_msgColourSimple "INFO-->" "sending:     bespoke pod build"
fi
printf "%s\n" "${red}"

# check if server is local server
localServer="false"
localServer=$(lib_generic_checks_localIpMatch "${pubIp}")

# if not local server - delete any existing pod folder
if [[ "${localServer}" != "true" ]]; then
  ssh -q -o ForwardX11=no -i ${sshKey} ${user}@${pubIp} "rm -rf ${target_folder}POD_SOFTWARE/POD/pod" exit

# if local server - copy from the tmp folder the value for target_folder
# this will subsequently be copied back to the local copy of misc/.suitcase, once all servers have been looped through
else
  cp "${tmp_suitcase_file_path}" ${pod_home_path}/.suitcase.tmp
fi

# (re)create folder and send over updated pod software
# this will be merged locally
ssh -q -i ${sshKey} ${user}@${pubIp} "mkdir -p ${target_folder}POD_SOFTWARE/POD/pod/"
scp -q -o LogLevel=QUIET -i ${sshKey} -r "${tmp_working_folder}" "${user}@${pubIp}:${target_folder}POD_SOFTWARE/POD/"
status=${?}
build_send_error_array["${tag}"]="${status};${pubIp}"
}

# ------------------------------------------

function lib_generic_build_finishUp(){

## tasks to finish up the build stage

# assign the local target_folder value back to the local copy of the misc/.suitcase
mv ${pod_home_path}/.suitcase.tmp "${suitcase_file_path}"
# delete the temporary work folder
rm -rf "${tmp_folder}"
}
