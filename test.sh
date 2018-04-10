#!/usr/local/bin/bash

#tags=$(jq '.server_1 | keys[]' servers/DSE_multiLinux.json)
#tags=$(sed -e 's/^"//' -e 's/"$//' <<<"$tags")
set -x
servers_json_path="servers/DSE_singleMac.json"
u="_"
keys=$(jq -r '.server_1 | keys[]' ${servers_json_path})
numberOfServers="1"
id=1
set -x
os="Mac"
source pods/pod_/lib/lib_generic_misc.bash

IFS='%'
dynamic_cmd="$(lib_generic_misc_chooseOsCommand 'gsed -r' 'sed -r' 'sed -r' 'sed -r')"
unset IFS
declare -A json_array
# for each level one key

for k in $keys
do
  # declare a variable of the same name and assign its value to it
  #declare "$k=$(jq -r '.server_'${id}'.'$k ${servers_json_path})"
  #echo $k
  json_array[$k]="$(jq -r '.server_'${id}'.'$k ${servers_json_path})"

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
      #declare "$k$u$nk=$(jq -r '.server_'${id}'.'$k'.'$nk ${servers_json_path})"
      json_array[$k$u$nk]="$(jq -r '.server_'${id}'.'$k'.'$nk ${servers_json_path})"

      # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
      nestedCheckTwo=$(jq -r '.server_'${id}'.'$k'.'$nk' | paths' ${servers_json_path})
      if [[ $nestedCheckTwo != *[0]* ]] && [[ $nestedCheckTwo != "" ]]; then

        # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
        nestedKeysTwo=$(echo $nestedCheckTwo |  tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        nestedKeysTwo=$(echo $nestedKeysTwo  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

        # for each level three key
        for nnk in $nestedKeysTwo
        do
          # declare a variable of the same name and assign its value to it - using underscore between nested levels for variable name
          #declare "$k$u$nk$u$nnk=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk ${servers_json_path})"
          json_array[$k$u$nk$u$nnk]="$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk ${servers_json_path})"
          # check if key has nested key value pairs - ignore if it is empty or if it is a list (then it will contain [0])
          nestedCheckThree=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk' | paths' ${servers_json_path})
          if [[ $nestedCheckThree != *[0]* ]] && [[ $nestedCheckThree != "" ]]; then

            # remove brackets, quotes and spaces + then deduplicate in preparation to loop through each nested key
            nestedKeysThree=$(echo $nestedCheckThree |  tr -d '[' | tr -d ']' | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            nestedKeysThree=$(echo $nestedKeysThree  | sed 's/, *.[[:alnum:]]*//g' | ${dynamic_cmd} ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

            # for each level four key
            for nnnk in $nestedKeysThree
            do
              #declare "$k$u$nk$u$nnk$u$nnnk=$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'.'$nnnk ${servers_json_path})"
              json_array[$k$u$nk$u$nnk$u$nnnk]="$(jq -r '.server_'${id}'.'$k'.'$nk'.'$nnk'.'$nnnk ${servers_json_path})"
            done
          fi
        done
      fi
    done
  fi
done

set -x
for key in "${!json_array[@]}"
do
  declare $key=${json_array[$key]}
done

echo $seeds
echo $mode_search
echo $mode_analytics
exit

tag=$(jq             -r '.server_'${id}'.tag'             "${servers_json_path}")
user=$(jq            -r '.server_'${id}'.user'            "${servers_json_path}")
sshKey=$(jq          -r '.server_'${id}'.sshKey'          "${servers_json_path}")
target_folder=$(jq   -r '.server_'${id}'.target_folder'   "${servers_json_path}")
pubIp=$(jq           -r '.server_'${id}'.pubIp'           "${servers_json_path}")
listen_address=$(jq  -r '.server_'${id}'.listen_address'  "${servers_json_path}")
rpc_address=$(jq     -r '.server_'${id}'.rpc_address'     "${servers_json_path}")
stomp_interface=$(jq -r '.server_'${id}'.stomp_interface' "${servers_json_path}")
seeds=$(jq           -r '.server_'${id}'.seeds'           "${servers_json_path}")
token=$(jq           -r '.server_'${id}'.token'           "${servers_json_path}")
dc=$(jq              -r '.server_'${id}'.dc'              "${servers_json_path}")
rack=$(jq            -r '.server_'${id}'.rack'            "${servers_json_path}")
search=$(jq          -r '.server_'${id}'.mode.search'     "${servers_json_path}")
analytics=$(jq       -r '.server_'${id}'.mode.analytics'  "${servers_json_path}")
graph=$(jq           -r '.server_'${id}'.mode.graph'      "${servers_json_path}")
dsefs=$(jq           -r '.server_'${id}'.mode.dsefs'      "${servers_json_path}")
