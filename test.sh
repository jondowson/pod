#!/bin/bash

#tags=$(jq '.server_1 | keys[]' servers/DSE_multiLinux.json)
#tags=$(sed -e 's/^"//' -e 's/"$//' <<<"$tags")
#set -x
servers_json_path="servers/DSE_multiLinux.json"
u="_"
keys=$(jq -r '.server_1 | keys[]' ${servers_json_path})
numberOfServers="1"

#IFS='%'
#dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -i' 'sed -i' 'sed -i' 'sed -i')"
#unset IFS

for id in $(seq 1 ${numberOfServers});
do
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
      nestedKeys=$(echo $nestedKeys  | sed 's/, *.[[:alnum:]]*//g' | gsed -r ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

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
          nestedKeysTwo=$(echo $nestedKeysTwo  | sed 's/, *.[[:alnum:]]*//g' | gsed -r ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

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
              nestedKeysThree=$(echo $nestedKeysThree  | sed 's/, *.[[:alnum:]]*//g' | gsed -r ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

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

done

echo $mode_search_tom
echo $mode_dsefs_tom
echo $mode_dsefs_harry_harry
