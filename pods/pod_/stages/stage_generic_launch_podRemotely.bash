# about:         run 'scripts_launchPodRemotely.sh' on each server

# ------------------------------------------

function task_generic_launchPodRemotely(){

for id in $(seq 1 ${numberOfServers});
do

  tag=$(jq            -r '.server_'${id}'.tag'            "${servers_json_path}")
  user=$(jq           -r '.server_'${id}'.user'           "${servers_json_path}")
  sshKey=$(jq         -r '.server_'${id}'.sshKey'         "${servers_json_path}")
  target_folder=$(jq  -r '.server_'${id}'.target_folder'  "${servers_json_path}")
  pubIp=$(jq          -r '.server_'${id}'.pubIp'          "${servers_json_path}")

# -----

  # add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

# -----

  prepare_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  printf "\n%s"
  prepare_generic_display_msgColourSimple "INFO-->" "launch:      pod remotely"

  ssh -ttq -o "BatchMode yes" -o "ForwardX11=no" ${user}@${pubIp} "chmod -R 700 ${target_folder}POD_SOFTWARE/POD && ${target_folder}POD_SOFTWARE/POD/pod/pods/${WHICH_POD}/scripts/scripts_launchPodRemotely.sh" > /dev/null 2>&1 &                # run in parallel
  # grab pid and capture owner in array
  pid=$!
  prepare_generic_display_msgColourSimple "INFO-->" "pid id:      ${yellow}${pid}${reset}"
  build_launch_pid_array["${pid}"]="${tag};${pubIp}"
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

prepare_generic_display_msgColourSimple "INFO-BOLD" "awaiting ssh pids:${reset}"
prepare_generic_display_msgColourSimple "INFO" "${yellow}$runBuild_pids${reset}"
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

if [[ ! -z $runBuild_pid_failures ]]; then
  prepare_generic_display_msgColourSimple "INFO-->" "${cross} Problems executing pod build on servers"
  printf "%s\n"
  for k in "${!build_launch_pid_array[@]}"
  do
    if [[ "${runBuild_pid_failures}" == *"$k"* ]]; then
      lib_generic_strings_expansionDelimiter "${build_launch_pid_array[$k]}" ";" "1"
      server="$_D1_"
      ip=$_D2_
      prepare_generic_display_msgColourSimple "ERROR-TIGHT" "pid ${yellow}${k}${red} failed for ${yellow}${server}@${ip}${red}"
    fi
  done
  printf "%s\n"
else
  prepare_generic_display_msgColourSimple "SUCCESS" "ALL SERVERS:  launched remote pod build"
fi
}
