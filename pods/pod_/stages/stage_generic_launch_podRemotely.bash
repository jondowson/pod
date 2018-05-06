# about:         run 'scripts_generic_launch_pod.sh' on each server

# ------------------------------------------

function task_generic_launchPodRemotely(){

for id in $(seq 1 ${numberOfServers});
do

  # [1] handle json
  tag=$(jq            -r '.server_'${id}'.tag'            "${serversJsonPath}")
  user=$(jq           -r '.server_'${id}'.user'           "${serversJsonPath}")
  ssh_key=$(jq         -r '.server_'${id}'.ssh_key'         "${serversJsonPath}")
  target_folder=$(jq  -r '.server_'${id}'.target_folder'  "${serversJsonPath}")
  pub_ip=$(jq          -r '.server_'${id}'.pub_ip'          "${serversJsonPath}")

  # [2] add trailing '/' to path if not present
  target_folder=$(lib_generic_strings_addTrailingSlash "${target_folder}")

  # [3] determine remote server os
  lib_generic_doStuff_remotely_identifyOs

  # [4] display message
  prepare_generic_display_msgColourSimple "INFO"    "${yellow}$tag${white} at ip ${yellow}$pub_ip${white} on os ${yellow}${remote_os}${reset}" #&& printf "\n%s"
  prepare_generic_display_msgColourSimple "INFO-->" "launch pod remotely:      ${target_folder}POD_SOFTWARE/POD/pod/pods/pod_/scripts/scripts_generic_launch_pod.sh"

  # [5] call remote launch script
  ssh -ttq -o "BatchMode yes" -o "ForwardX11=no" ${user}@${pub_ip} "chmod -R 777 ${target_folder}POD_SOFTWARE/POD && ${target_folder}POD_SOFTWARE/POD/pod/pods/pod_/scripts/scripts_generic_launch_pod.sh" > /dev/null 2>&1 &                # run in parallel
  # grab pid and capture owner in array
  pid=$!
  prepare_generic_display_msgColourSimple "INFO-->"  "pid id:                   ${yellow}${pid}${reset}"
  arrayLaunchPodPids["${pid}"]="${tag};${pub_ip}"
  runBuild_pids+=" $pid"

  # [5] display launch pid status
  if [[ "${runBuild_pids_print}" ]]; then
    runBuild_pids_print="${runBuild_pids_print},$pid"
  else
    runBuild_pids_print="$!"
  fi

done

prepare_generic_display_msgColourSimple "INFO-BOLD-SPACED" "awaiting ssh pids:${reset}"
prepare_generic_display_msgColourSimple "INFO" "${yellow}$runBuild_pids${reset}"
printf "\n%s"

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

## report on the status of the remote server launch pod pids

if [[ ! -z $runBuild_pid_failures ]]; then
  prepare_generic_display_msgColourSimple "INFO-->" "${cross} Problems executing pod build on servers"
  printf "%s\n"
  for k in "${!arrayLaunchPodPids[@]}"
  do
    if [[ "${runBuild_pid_failures}" == *"$k"* ]]; then
      lib_generic_strings_expansionDelimiter "${arrayLaunchPodPids[$k]}" ";" "1"
      server="$_D1_"
      ip=$_D2_
      prepare_generic_display_msgColourSimple "ERROR-TIGHT" "pid ${yellow}${k}${red} failed for ${yellow}${server}@${ip}${red}"
    fi
  done
  printf "%s\n"
else
  prepare_generic_display_msgColourSimple "SUCCESS" "Each server:  launched remote pod build"
fi
}
