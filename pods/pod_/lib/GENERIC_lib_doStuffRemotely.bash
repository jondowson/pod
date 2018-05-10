function GENERIC_lib_doStuffRemotely_identifyOs(){

## determine remote os by running a pod script on the remote server

remote_os=$(ssh -q -o Forwardx11=no ${user}@${pub_ip} 'bash -s'  < ${podHomePath}/pods/pod_/scripts/GENERIC_scripts_identifyOs.sh)
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_bashrc(){

## configure bashrc to source bash_profile everytime a new terminal is started (on ubuntu)

# file to edit
file="${HOME}/.bashrc"
touch ${file}

# search for and remove any pre-canned blocks containing a label:
label="source_bash_rc"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "pod_SETUP@${label}"

# add line sourcing .bashrc
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__pod_SETUP@${label}
if [ -r ~/.bash_profile ]; then source ~/.bash_profile; fi
#>>>>>END-ADDED-BY__pod_SETUP@${label}
EOF
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_updateAppBashProfile(){

## configure bash_profile to set paths in an idempotent 'manner'

program_home=$(tr [:lower:] [:upper:] <<< "${1}")
soft_exec_path="${2}"

# file to edit
file="${HOME}/.bash_profile"
touch "${file}"

# search for and remove any lines starting with:
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export ${program_home}=" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$${program_home}:\$PATH" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$PATH:\$${program_home}" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="${program_home}_bash_profile"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# append to end of files
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
export ${program_home}="${soft_exec_path}"
export PATH=\$${program_home}:\$PATH
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_updatePodBashProfile(){

## configure bash_profile to set paths in an idempotent 'manner'

program_home=$(tr [:lower:] [:upper:] <<< "${1}")
pod_exec_path="${2}"

# file to edit
file="${HOME}/.bash_profile"
touch "${file}"

# search for and remove any lines starting with:
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export ${program_home}=" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$${program_home}:\$PATH" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$PATH:\$${program_home}" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="${program_home}_bash_profile"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "pod_SETUP@${label}"

## allow pod to be run on this server from any folder and create an alias too
cat << EOF >> "${file}"

#>>>>>BEGIN-ADDED-BY__pod_SETUP@${label}
export POD_HOME=${pod_exec_path}/
export PATH=\$POD_HOME:\$PATH
alias fpod='cd ${pod_exec_path}'
#>>>>>END-ADDED-BY__pod_SETUP@${label}
EOF
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_createFolders(){

## create required folders

foldersToMake="${1}"

GENERIC_lib_strings_ifsStringDelimeter ";" "${foldersToMake}"

for i in "${!array[@]}"
do
  value="${array[$i]}"
  mkdir -p "${value}"
done
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_unpackTar(){

## unpack tar to the designated folder

file="${1}"
folder="${2}"

tar -xvf "${file}" -C "${folder}"
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_getVersionFromPid(){

## try to identify version of running software from its pid

grepString=${1}                 # examples: 'dse-' or 'datastax-agent-' or ...
grepDeleteAfter=${2}            # examples: '-' or '_' or ...

runningVersion=$(ssh -q -i ${ssh_key} ${user}@${pub_ip} 'ps -ef | grep -v grep')
runningVersion=$(echo $runningVersion | grep -o "${grepString}[^ ]*" | sed "s/^\(${grepString}\)*//" | sed "s/${grepDeleteAfter}.*//" | head -1 )

if [[ -z ${runningVersion} ]]; then
  runningVersion="n/a"
fi
printf "%s\n" "${runningVersion}"
}

# ---------------------------------------

function GENERIC_lib_doStuffRemotely_checkSoftwareAvailability(){

## run remotely to check if a given software is available

retries=${1}
retries=$((retries+1))        # number of times to retry (1 is added as count starts from 1)
sourceBashProfile=${2}        # whether or not to source bash_profile before running test command ('true' or 'false')
testCommand=${3}              # the command to run to test availability - e.g. 'java -version' or 'curl --help' or ...
errMsg=${4}                   # error message to diplay on failure - e.g. 'java unavailable'
displayMsg=${5}               # screen message to accompany return code / message
displayStatus=${6}            # whether or not to handle screen messages as well - 'full' or 'code' ('0' or other)

# [1] build test command to run
if [[ ${sourceBashProfile} == "true" ]]; then
  testCommand="source ~/.bash_profile && ${testCommand}"
fi

# [2] attempt test x times
status="999"
if [[ "${status}" != "0" ]]; then
  retry=1
  until [[ "${retry}" == "${retries}" ]] || [[ "${status}" == "0" ]]
  do
    # display any output in different color
    output=$(ssh -q -i ${ssh_key} ${user}@${pub_ip} "${testCommand}" &>/dev/null)
    status=$?
    if [[ "${status}" == "0" ]]; then
      result="${status}"
      break;
    elif [[ "${STRICT_START}" ==  "true" ]] && [[ "${retry}" == $((retries-1)) ]]; then
        result="[${errMsg}]"
        break;
    else
        result="[${status}]"
        ((retry++))
    fi
  done
fi

# [3] handle result in specified manner
# 'full' detailed screen messages
if [[ "${displayStatus}" == "full" ]]; then
  if [[ "${result}" != "0" ]]; then
    if [[ "${STRICT_START}" ==  "true" ]]; then
      GENERIC_prepare_display_msgColourSimple   "ERROR-->"   "Exiting pod:       ${yellow}${taskFile}${red} with ${yellow}--strict true"
      GENERIC_prepare_display_msgColourSimple   "ERROR-->"   "error message:     ${red}${result}${reset}"
      exit 1;
    else
      GENERIC_prepare_display_msgColourSimple   "INFO-->"    "${displayMsg}${red}${status}"
    fi
  else
    GENERIC_prepare_display_msgColourSimple     "INFO-->"    "${displayMsg}${green}${status}"
  fi
# return just the error 'code'
else
  printf "%s\n" "${result}"
fi
}
