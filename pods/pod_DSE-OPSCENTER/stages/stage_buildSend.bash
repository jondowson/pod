function task_buildSend(){

## for each server configure a bespoke pod build and send/merge it

# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${serversJsonPath})

# loop through each server defined in the json file
for id in $(seq 1 ${numberOfServers});
do

  # [1] define in order locally run functions array (this array may be empty!)
  # escape any passed function parameters!
  # build_functions_array[0]=""

  # [2] call the generic buildSend task
  GENERIC_task_buildSend

done
}
