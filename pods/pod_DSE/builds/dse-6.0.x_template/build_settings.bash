# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
PACKAGE="DATASTAX"                                    # empty if pod does not involve tarball
source ${pod_home_path}/misc/.suitcase                # file used to access server specific variables on remote machines
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"          # the parent folder with all the tarballs and the pod software
PACKAGES="${POD_SOFTWARE}${PACKAGE}/"                 # the relevant tarball folders for this pod
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"        # the parent folder where tarball software is unpacked to
INSTALL_FOLDER_POD="${INSTALL_FOLDER}${WHICH_POD}/"   # the pod specific folder where tarballs are unpacked to
# //////////////////////////////////////////


# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

## [1] BASIC CASSANDRA SETTINGS

CLUSTER_NAME="Cluster1"                               # avoid special characters !!
ENDPOINT_SNITCH="GossipingPropertyFileSnitch"         # 'GossipingPropertyFileSnitch' should be the default !!
VNODES="8"                                            # specify a value (8,16) for vnodes or "false" to pick up assigned token from json definition file

## [2] DSE + AGENT VERSIONS

DSE_VERSION="dse-6.0.0"                               # the dse tarball version to unpack
AGENT_VERSION="datastax-agent-6.5.0"                  # the datastax agent tarball version to unpack

# [3] DATA + LOG + TMP FOLDER LOCATIONS

## note:
# + cassandra sstable data folders are specified in the <servers.json> definition file
# + this data folder is where the supporting persistence files will go such as commitlogs and hinted-handoffs
# + on spinning disks it is recommended to locate these on seperate mount points to sstable data folders
# + by default DATA and LOGS folders are created inside the POD_INSTALLS desktop folder
# ++  this seperation means that by default if pod_DSE is rerun or removed using pod_REMOVE-PODS, existing data will be retained
PARENT_DATA_FOLDER="${INSTALL_FOLDER_POD}DATA/${BUILD_FOLDER}/"
PARENT_LOG_FOLDER="${INSTALL_FOLDER_POD}LOGS/${BUILD_FOLDER}/"
# temp folder - can be anywhere with suffcient permissions
TEMP_FOLDER="${INSTALL_FOLDER}TEMP/"
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
# tarballs
DSE_TARBALL="${DSE_VERSION}-bin.tar.gz"
AGENT_TARBALL="${AGENT_VERSION}.tar.gz"
# dse
dse_tar_folder="${PACKAGES}dse/"
dse_tar_file="${dse_tar_folder}${DSE_TARBALL}"
dse_untar_config_folder="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${DSE_VERSION}/resources/dse/conf/"
dse_untar_bin_folder="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${DSE_VERSION}/bin/"
# datastax-agent
agent_tar_folder="${PACKAGES}datastax-agent/"
agent_tar_file="${agent_tar_folder}${AGENT_TARBALL}"
agent_untar_folder="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${AGENT_VERSION}"
agent_untar_config_folder="${agent_untar_folder}/conf/"
agent_untar_bin_folder="${agent_untar_folder}/bin/"
agent_untar_log_folder="${agent_untar_folder}/log/"
# cassandra
cassandra_log_folder="${PARENT_LOG_FOLDER}cassandra/"
commitlog_directory="${PARENT_DATA_FOLDER}commitlog/"
cdc_raw_directory="${PARENT_DATA_FOLDER}cdc_raw/"
saved_caches_directory="${PARENT_DATA_FOLDER}saved_caches/"
hints_directory="${PARENT_DATA_FOLDER}hints/"
# spark data and log folders
spark_local_data="${PARENT_DATA_FOLDER}spark/rdd/"
spark_executor_folder="${PARENT_DATA_FOLDER}spark/rdd/"
spark_worker_data="${PARENT_DATA_FOLDER}spark/worker/"
spark_master_log_folder="${PARENT_LOG_FOLDER}spark/master/"
spark_worker_log_folder="${PARENT_LOG_FOLDER}spark/worker/"
spark_alwayson_sql_log_dir="${PARENT_LOG_FOLDER}spark/alwayson_sql/"
# dsefs
dsefs_untar_folder="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${DSE_VERSION}/resources/dsefs/"
# gremlin logs
gremlin_log_folder="${PARENT_LOG_FOLDER}gremlin/"
# tomcat logs
tomcat_log_folder="${PARENT_LOG_FOLDER}tomcat/"

## folders to be write tested !!
# declare all paths (; seperated) to be write tested for this pod
# supply the variable string and omit the '$' - e.g "data_path;log_path"
# no need to specify target_folder as automatically added by function
# the writetest creates and then deletes a dummy folder in the specified path
# any folders that need to exist prior to running the application should be added here

# build_settings paths to write test
buildPathsWriteTest="TEMP_FOLDER;PARENT_DATA_FOLDER;PARENT_LOG_FOLDER;spark_local_data;spark_worker_data;spark_executor_folder;spark_alwayson_sql_log_dir;spark_master_log_folder;spark_worker_log_folder"
# json server paths to write test
jsonPathsWriteTest="cass_data;dsefs_data"
# //////////////////////////////////////////
