# author:        jondowson
# about:         functions executed on remote server

# ---------------------------------------

function lib_doStuff_remotely_createDseFolders(){

## create required folders

# assume here that the mount has been pre-created and assigned to 'the user'

# create log folders
mkdir -p ${cassandra_log_folder}
mkdir -p ${gremlin_log_folder}
mkdir -p ${tomcat_log_folder}
mkdir -p ${spark_master_log_folder}
mkdir -p ${spark_worker_log_folder}

# create cassandra sstable folder(s)
for i in "${data_file_directories_array[@]}"
do
  mkdir -p $i
done
mkdir -p ${commitlog_directory}
mkdir -p ${cdc_raw_directory}
mkdir -p ${saved_caches_directory}
mkdir -p ${hints_directory}

# create dsefs folders
mkdir -p ${dsefs_untar_folder}
for i in "${dsefs_data_file_directories_array[@]}"
do
  lib_generic_strings_expansionDelimiter "$i" ";" "2"
  mkdir -p $_D1_
done

# dse spark
mkdir -p ${spark_local_data}
mkdir -p ${spark_worker_data}
}

# ---------------------------------------

function lib_doStuff_remotely_installDseTar(){

## uncompress tar on remote machine and rename it to name of build folder

tar -xf "${dse_tar_file}" -C "${INSTALL_FOLDER_POD}"
mv "${INSTALL_FOLDER_POD}${DSE_VERSION}" "${INSTALL_FOLDER_POD}${BUILD_FOLDER}"
}

# ---------------------------------------

function lib_doStuff_remotely_installAgentTar(){

## uncompress tar on remote machine

tar -xf "${agent_tar_file}" -C "${INSTALL_FOLDER_POD}"
}

# ---------------------------------------

function lib_doStuff_remotely_dseBashProfile(){

## configure bash_profile to set paths in an idempotent 'manner'

# file to edit
file="${HOME}/.bash_profile"
touch ${file}

# search for and remove any lines starting with:
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export OPSC_JVM_OPTS=" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export CASSANDRA_HOME=" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export PATH=\$PATH:\$CASSANDRA_HOME" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="dse_bash_profile"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

cat << EOF >> ${file}
#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
export OPSC_JVM_OPTS="-Djava.io.tmpdir=${Djava_tmp_folder}"
export CASSANDRA_HOME="${dse_untar_bin_folder}"
export PATH=\$PATH:\$CASSANDRA_HOME
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF
}

# ---------------------------------------

function lib_doStuff_remotely_bashrc(){

## configure bashrc to source bash_profile everytime a new terminal is started (on ubuntu/centos)

# file to edit
file="${HOME}/.bashrc"
touch ${file}

# search for and remove any pre-canned blocks containing a label:
label="source_bash_profile"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# add line sourcing .bashrc - no need on a Mac
cat << EOF >> ${file}
#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
if [ -r ~/.bash_profile ]; then source ~/.bash_profile; fi
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF
}

# ---------------------------------------

function lib_doStuff_remotely_agentAddressYaml(){

## configure bashrc to source bash_profile everytime a new terminal is started (on ubuntu/centos)

# file to edit
file="${agent_untar_config_folder}address.yaml"
touch ${file}

lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "stomp_interface:" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "use_ssl:" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="set_stomp_opscenter"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# add line sourcing .bashrc - no need on a Mac
cat << EOF >> ${file}
#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
stomp_interface: ${STOMP_INTERFACE}
use_ssl: 0
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF
}
