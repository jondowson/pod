# about:         start dse on each server based on its server json defined mode

# -------------------------------------------

function task_rollingStop(){

## for each server stop dse based on its json defined mode

# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${servers_json_path})

for id in $(seq 1 ${numberOfServers});
do

  # [1] determine remote server os
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


  # [3] display message
  prepare_generic_display_msgColourSimple "INFO" "server: ${yellow}$tag${white} at address: ${yellow}$pubIp${reset}"
  prepare_generic_display_msgColourSimple "INFO-->" "stopping dse:      gracefully"
  prepare_generic_display_msgColourSimple "INFO-->" "killing agent:     ungracefully"

  # [4] stop dse + agent running on server
  lib_doStuff_remotely_stopDseAgent

done
}

# -------------------------------------------

function task_rollingStop_report(){

## generate a report of stop pids finish status

declare -a stop_dse_report_array
count=0
for k in "${!stop_dse_error_array[@]}"
do
  lib_generic_strings_expansionDelimiter ${stop_dse_error_array[$k]} ";" "1"
  if [[ "${_D1_}" != "0" ]]; then
    stop_dse_fail="true"
    stop_dse_report_array["${count}"]="${yellow}${k}${white} at address ${yellow}${_D2_}${white} with error code ${red}${_D1_}${reset}"
    (( count++ ))
  fi
done

if [[ "${stop_dse_fail}" == "true" ]]; then
  printf "%s\n"
  for k in "${stop_dse_report_array[@]}"
  do
    prepare_generic_display_msgColourSimple "INFO" "${cross} ${k}"
  done
else
  prepare_generic_display_msgColourSimple "SUCCESS" "ALL SERVERS:  dse + agent stopped"
fi
}
