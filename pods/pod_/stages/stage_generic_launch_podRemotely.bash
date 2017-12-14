# author:        jondowson
# about:         run 'pod_launch_remote.sh' on each server in the cluster

# ------------------------------------------

function task_generic_launchPodRemotely(){

for id in $(seq 1 ${numberOfServers});
do

  tag=$(cat ${servers_json_path}           | ${jq_folder}jq '.server_'${id}'.tag'            | tr -d '"')
  user=$(cat ${servers_json_path}          | ${jq_folder}jq '.server_'${id}'.user'           | tr -d '"')
  sshKey=$(cat ${servers_json_path}        | ${jq_folder}jq '.server_'${id}'.sshKey'         | tr -d '"')
  target_folder=$(cat ${servers_json_path} | ${jq_folder}jq '.server_'${id}'.target_folder'  | tr -d '"')
  pubIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.pubIp'          | tr -d '"')
  prvIp=$(cat ${servers_json_path}         | ${jq_folder}jq '.server_'${id}'.prvIp'          | tr -d '"')

# -----

  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

# -----

  lib_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"

  lib_generic_display_msgColourSimple "INFO-->" "launch:      pod remotely"
  ssh -ttq -o "BatchMode yes" -o "ForwardX11=no" ${user}@${pubIp} "chmod -R 700 ${target_folder}POD_SOFTWARE/POD && ${target_folder}POD_SOFTWARE/POD/pod/pods/${WHICH_POD}/scripts/scripts_launchPodRemotely.sh" &                # run in parallel
  # grab pid and capture owner in array
  pid=$!
  lib_generic_display_msgColourSimple "INFO-->" "pid id:      ${yellow}${pid}${reset}"
  pod_build_launch_pid_array["${pid}"]="${tag};${pubIp}"
  runBuild_pids+=" $pid"

# -----

  # print out pids

  if [[ "${runBuild_pids_print}" ]]; then
    runBuild_pids_print="${runBuild_pids_print},$pid"
  else
    runBuild_pids_print="$!"
  fi
  printf "\n%s"

done

# -----

lib_generic_display_msgColourSimple "INFO-BOLD" "awaiting ssh pids:${reset}"
lib_generic_display_msgColourSimple "INFO" "${yellow}$runBuild_pids${reset}"
printf "\n%s"

# -----

# Wait for all processes to finish

runBuild_pid_failures=""
printf "%s" ${red}  # any scp error messages
for p in $runBuild_pids; do
  if wait $p; then
    printf "%s\n" "${green}Process $p success${reset}"
  else
    printf "%s\n" "${red}Process $p fail${reset}"
    runBuild_pid_failures+=" ${p}"
  fi
done
}

# ------------------------------------------

function task_generic_launchPodRemotely_report(){

lib_generic_display_msgColourSimple "REPORT" "STAGE SUMMARY: ${reset}Launch Pod On Each Server"

if [[ ! -z $runBuild_pid_failures ]]; then
  lib_generic_display_msgColourSimple "INFO-->" "${cross} Problems executing 'pod' on servers"
  printf "%s\n"
  for k in "${!pod_build_launch_pid_array[@]}"
  do
    if [[ "${runBuild_pid_failures}" == *"$k"* ]]; then
      lib_generic_strings_expansionDelimiter "${pod_build_launch_pid_array[$k]}" ";" "1"
      server="$_D1_"
      ip=$_D2_
      lib_generic_display_msgColourSimple "ERROR-TIGHT" "pid ${yellow}${k}${red} failed for ${yellow}${server}@${ip}${red}"
    fi
  done
  printf "%s\n"
else
  lib_generic_display_msgColourSimple "SUCCESS" "Executed pod builds on all servers"
fi
}
