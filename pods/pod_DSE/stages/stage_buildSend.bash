function task_buildSend(){

## for each server configure a bespoke pod build and send/merge it

# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${serversJsonPath})

# loop through each server defined in the json file
for id in $(seq 1 ${numberOfServers});
do

  # [1] define in order locally run functions array (this array may be empty!)
  # escape any passed function parameters!
  arrayBuildLocalFunctions[0]="lib_doStuff_locally_cassandraEnv"
  arrayBuildLocalFunctions[1]="lib_doStuff_locally_jvmOptions"
  arrayBuildLocalFunctions[2]="lib_doStuff_locally_cassandraYaml_buildSettings"
  arrayBuildLocalFunctions[3]="lib_doStuff_locally_dseSparkEnv"
  arrayBuildLocalFunctions[4]="lib_doStuff_locally_cassandraRackDcProperties"
  arrayBuildLocalFunctions[5]="lib_doStuff_locally_cassandraYaml_json"
  arrayBuildLocalFunctions[6]="GENERIC_lib_build_jqListToArray \"cass_data\""
  arrayBuildLocalFunctions[7]="lib_doStuff_locally_cassandraYaml_cassData"
  arrayBuildLocalFunctions[8]="GENERIC_lib_build_jqListToArray \"dsefs_data\""
  arrayBuildLocalFunctions[9]="lib_doStuff_locally_dseYaml_dsefsData"

  # [2] call the generic buildSend task
  GENERIC_task_buildSend

done
}
