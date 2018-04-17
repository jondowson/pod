function task_buildSend(){

## for each server configure a bespoke pod build and send/merge it

# identify all keys for this json file from the first server block
keys=$(jq -r '.server_1 | keys[]' ${servers_json_path})

# loop through each server defined in the json file
for id in $(seq 1 ${numberOfServers});
do

  # [1] define in order locally run functions array (this array may be empty!)
  # escape any passed function parameters!
  build_functions_array[0]="lib_doStuff_locally_cassandraEnv"
  build_functions_array[1]="lib_doStuff_locally_jvmOptions"
  build_functions_array[2]="lib_doStuff_locally_cassandraYaml_buildSettings"
  build_functions_array[3]="lib_doStuff_locally_dseSparkEnv"
  build_functions_array[4]="lib_doStuff_locally_cassandraRackDcProperties"
  build_functions_array[5]="lib_doStuff_locally_cassandraYaml_json"
  build_functions_array[6]="lib_generic_build_jqListToArray \"cass_data\""
  build_functions_array[7]="lib_doStuff_locally_cassandraYaml_cassData"
  build_functions_array[8]="lib_generic_build_jqListToArray \"dsefs_data\""
  build_functions_array[9]="lib_doStuff_locally_dseYaml_dsefsData"

  # [2] call the generic buildSend task
  task_generic_buildSend

done

# assign the local target_folder value to the suitcase and delete tmp folder
lib_generic_build_finishUp
}
