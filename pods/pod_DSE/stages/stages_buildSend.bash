function task_buildSend(){

## for each server configure a bespoke pod build and send/merge it

# loop through each server defined in the json file
for id in $(seq 1 ${numberOfServers});
do

  # [1] define in order locally run functions array (this array may be empty!)
  # escape any passed function parameters!
  arrayBuildLocalFunctions[0]="lib_doStuffLocally_cassandraEnv"
  arrayBuildLocalFunctions[1]="lib_doStuffLocally_jvmOptions"
  arrayBuildLocalFunctions[2]="lib_doStuffLocally_cassandraYaml_buildSettings"
  arrayBuildLocalFunctions[3]="lib_doStuffLocally_dseSparkEnv"
  arrayBuildLocalFunctions[4]="lib_doStuffLocally_cassandraRackDcProperties"
  arrayBuildLocalFunctions[5]="lib_doStuffLocally_cassandraYaml_json"
  arrayBuildLocalFunctions[6]="GENERIC_lib_build_jqListToArray \"cass_data\""
  arrayBuildLocalFunctions[7]="lib_doStuffLocally_cassandraYaml_cassData"
  arrayBuildLocalFunctions[8]="GENERIC_lib_build_jqListToArray \"dsefs_data\""
  arrayBuildLocalFunctions[9]="lib_doStuffLocally_dseYaml_dsefsData"
  arrayBuildLocalFunctions[10]="lib_doStuffLocally_dseGremlinRemoteYaml"
  arrayBuildLocalFunctions[11]="lib_doStuffRemotely_bashProfileAgentStartFlags"

  # [2] call the generic buildSend task
  GENERIC_task_buildSend

done

# [3] assign the local target_folder value to the suitcase and delete tmp folder
GENERIC_lib_build_finishUp
}
