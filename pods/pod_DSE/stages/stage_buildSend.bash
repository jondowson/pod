# about:         for each server build and then send a configured version of pod

# ------------------------------------------

function task_buildSend(){

## for each server configure a bespoke pod build and send/merge it

# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${servers_json_path})

# loop through each server defined in the json file
for id in $(seq 1 ${numberOfServers});
do

  ## [1] determine remote server os
  lib_generic_doStuff_remotely_identifyOs


#=============================================================================


  ## [2] for this server, loop through its json block and assign values to bash variables
  ## loop through json server block and create a bash variable (same name as json key) and assign its value to it
  ## this function allows nested json objects to a depth of four - e.g. c1.2.3.x below //TODO make recursive?

  # {
  #  "server_1":{
  #    "a1":  "value",
  #    "b1": "value",
  #    "c1": {
  #      "c1.1": {
  #        "c1.1.1": "value",
  #        "c1.1.2": "value"
  #        "c1.2.3": {
  #          "c1.2.3.1" : "value",
  #          "c1.2.3.2" : "value"
  #       }
  #      }
  #    }
  #  }
  # }

  # -----

  # dynamically select the correct command for the OS
  IFS='%'
  dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -r' 'sed -r' 'sed -r' 'sed -r')"
  unset IFS

  # -----

  # for each level one key
  for k in $keys
  do
    # declare a variable of the same name and assign its value to it
    declare "$k=$(jq -r '.server_'${id}'.'$k ${servers_json_path})"

    # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
    nestedCheck=$(jq -r '.server_'${id}'.'$k' | paths' ${servers_json_path})
    if [[ $nestedCheck != *[0]* ]] && [[ $nestedCheck != "" ]]; then

      # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
      nestedKeys=$(echo $nestedCheck | tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
      nestedKeys=$(echo $nestedKeys  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

      # for each level two key
      for nk in $nestedKeys
      do
        # declare a variable of the same name and assign its value to it - using underscore between nested levels for variable name
        declare "$k$u$nk=$(jq -r '.server_'${id}'.'$k'.'$nk ${servers_json_path})"

        # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
        nestedCheckTwo=$(jq -r '.server_'${id}'.'$k'.'$nk' | paths' ${servers_json_path})
        if [[ $nestedCheckTwo != *[0]* ]] && [[ $nestedCheckTwo != "" ]]; then

          # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
          nestedKeysTwo=$(echo $nestedCheckTwo |  tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
          nestedKeysTwo=$(echo $nestedKeysTwo  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} -r ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

          # for each level three key
          for nnk in $nestedKeysTwo
          do
            # declare a variable of the same name and assign its value to it - using underscore between nested levels for variable name
            declare "$k$u$nk$u$nnk=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk ${servers_json_path})"

            # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
            nestedCheckThree=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk' | paths' ${servers_json_path})
            if [[ $nestedCheckThree != *[0]* ]] && [[ $nestedCheckThree != "" ]]; then

              # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
              nestedKeysThree=$(echo $nestedCheckThree |  tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
              nestedKeysThree=$(echo $nestedKeysThree  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} -r ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

              # for each level four key
              for nnnk in $nestedKeysThree
              do
                declare "$k$u$nk$u$nnk$u$nnnk=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'.'$nnnk ${servers_json_path})"
              done
            fi
          done
        fi
      done
    fi
  done

  ## add trailing '/' to target_folder path if not present
  target_folder="$(lib_generic_strings_addTrailingSlash ${target_folder})"


#=============================================================================


  ## [3] display message
  prepare_generic_display_msgColourSimple "INFO"    "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}" && printf "\n%s"
  prepare_generic_display_msgColourSimple "INFO-->" "detected os: ${green}${remote_os}${reset}"
  prepare_generic_display_msgColourSimple "INFO-->" "making:      bespoke pod build"

  ## [4] source the build_settings file based on this server's target_folder
  lib_generic_build_sourceTarget

  ## [5] build a 'suitcase' of server specific variables - used by remotely run functions
  lib_generic_build_suitcase

  ## [6] locally edit the dse config files in the folder 'tmp/pod/pods/pod_DSE/builds/${BUILD_FOLDER}/resources'
  lib_doStuff_locally_cassandraEnv
  lib_doStuff_locally_jvmOptions
  lib_doStuff_locally_cassandraYaml_buildSettings
  lib_doStuff_locally_dseSparkEnv
  lib_doStuff_locally_cassandraRackDcProperties
  lib_doStuff_locally_cassandraYaml_json
  # handle paths specified in lists in the json
  lib_generic_build_jqListToArray "cass_data"
  lib_doStuff_locally_cassandraYaml_cassData
  lib_generic_build_jqListToArray "dsefs_data"
  lib_doStuff_locally_dseYaml_dsefsData

  ## [7] display message
  prepare_generic_display_msgColourSimple "INFO-->" "sending:     bespoke pod build"
  printf "%s\n" "${red}"

  ## [8] send the bespoke pod build to the server
  lib_generic_build_sendPod

done

# assign the local target_folder value to the suitcase and delete tmp folder
lib_generic_build_finishUp
}

# ------------------------------------------

function task_buildSend_report(){

## generate a status report of all send pids

declare -a build_send_report_array
count=0
for k in "${!build_send_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${build_send_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    build_send_fail="true"
    build_send_report_array["${count}"]="could not transfer: ${yellow}${k} ${white}on server ${yellow}${_D2_}${reset}"
    (( count++ ))
  fi
done

# -----

if [[ "${build_send_fail}" == "true" ]]; then
  printf "%s\n"
  prepare_generic_display_msgColourSimple "INFO-BOLD" "--> ${red}Write build error report:"
  printf "%s\n"

  for k in "${build_send_report_array[@]}"
  do
    prepare_generic_display_msgColourSimple "INFO-BOLD" "${cross} ${k}"
  done
  printf "%s\n"
  prepare_generic_display_msgColourSimple "ERROR-->" "Aborting script as not all paths are writeable"
  prepare_generic_misc_clearTheDecks && exit 1;
else
  prepare_generic_display_msgColourSimple "SUCCESS" "ALL SERVERS:  distributed bespoke pod build"
fi
}
