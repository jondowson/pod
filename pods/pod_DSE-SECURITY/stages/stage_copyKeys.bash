# about:         for each server build and then send a configured version of pod

# ------------------------------------------

function task_copyKeys(){

## for each server configure a pod build and then send it

for id in $(seq 1 ${numberOfServers});
do

  tag=$(jq            -r '.server_'${id}'.tag'            "${servers_json_path}")
  user=$(jq           -r '.server_'${id}'.user'           "${servers_json_path}")
  sshKey=$(jq         -r '.server_'${id}'.sshKey'         "${servers_json_path}")
  target_folder=$(jq  -r '.server_'${id}'.target_folder'  "${servers_json_path}")
  pubIp=$(jq          -r '.server_'${id}'.pubIp'          "${servers_json_path}")

# -----

  # add trailing '/' to path if not present
  system_key_directory="$(lib_generic_strings_addTrailingSlash ${system_key_directory})"

# -----

  lib_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"
  remote_os=$(ssh -q -o Forwardx11=no ${user}@${pubIp} 'bash -s' < ${pod_home_path}/pods/pod_/scripts/scripts_generic_identifyOs.sh)
  lib_generic_display_msgColourSimple "INFO-->" "detected os: ${green}${remote_os}${reset}"

  if [[ "${generate_keys}" == "true" ]]; then

    lib_generic_display_msgColourSimple "INFO-->" "retrieving encryption keys:     from server 1 to local resources folder"
    if [[ "${id}" == "1" ]]; then
      scp -i ${sshKey} ${user}@${pubIp}:${system_key_directory}* ${resources_folder}
    fi
    lib_generic_display_msgColourSimple "INFO-->" "copying encryption keys:     to remote keys folder"
    scp -i ${sshKey} ${resources_folder}* ${user}@${pubIp}:${system_key_directory}

  else

    lib_generic_display_msgColourSimple "INFO-->" "copying encryption keys:     to remote keys folder"
    scp -i ${sshKey} ${resources_folder}* ${user}@${pubIp}:${system_key_directory}
  fi
  status=${?}
  copy_keys_error_array["${tag}"]="${status};${pubIp}"
done
}

# ------------------------------------------

function task_copyKeys_report(){

## generate a report of all failed sends of pod build

lib_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Create pod for each server"

declare -a copy_keys_report_array
count=0
for k in "${!copy_keys_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${copy_keys_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    copy_keys_fail="true"
    copy_keys_report_array["${count}"]="could not transfer: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# -----

if [[ "${copy_keys_fail}" == "true" ]]; then
  printf "%s\n"
  lib_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}Write build error report:"
  printf "%s\n"

  for k in "${copy_keys_report_array[@]}"
  do
    lib_generic_display_msgColourSimple "INFO-BOLD" "${cross} ${k}"
  done
  printf "%s\n"
  lib_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  prepare_generic_misc_clearTheDecks && exit 1;
else
  lib_generic_display_msgColourSimple "SUCCESS" "Create and send bespoke pod build to all servers"
fi
}
