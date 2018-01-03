# author:        jondowson
# about:         software version and path configurations for a cluster created by pod_DSE

# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
source ${pod_home_path}/misc/.suitcase
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"
PACKAGES="${POD_SOFTWARE}DATASTAX/"
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"
INSTALL_FOLDER_POD="${INSTALL_FOLDER}${WHICH_POD}/"
# //////////////////////////////////////////




# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

## [1] BASIC CASSANDRA SETTINGS

CLUSTER_NAME="My Kluster"                       # avoid special characters !!
ENDPOINT_SNITCH="GossipingPropertyFileSnitch"   # 'GossipingPropertyFileSnitch' should be the default !!
VNODES="8"                                      # specify a value (8,16,32) for vnodes or "false" for assigned tokens (picked up from servers' .json definition file)

# -----

## [2] DSE VERSIONS

DSE_VERSION="dse-5.1.5"
DSE_TARBALL="${DSE_VERSION}-bin.tar.gz"
AGENT_VERSION="datastax-agent-6.1.5"
AGENT_TARBALL="${AGENT_VERSION}.tar.gz"

# -----

# [3] DATA + LOG + TMP FOLDER LOCATIONS

# note: cassandra sstable data folders are specified in the <servers.json> definition file
# this data folder is where the supporting persistence files will go such as commitlogs and hinted-handoffs
# on spinning disks it is recommended to locate these on seperate mount points to sstable data folders
PARENT_DATA_FOLDER="${INSTALL_FOLDER_POD}${dse_version}data/"
PARENT_LOG_FOLDER="${INSTALL_FOLDER_POD}${dse_version}logs/"

# temp folder - can be anywhere with suffcient permissions
TEMP_FOLDER="${INSTALL_FOLDER}tmp/"
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
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
# required for java
Djava_tmp_folder="${TEMP_FOLDER}"
# cassandra
cassandra_log_folder="${PARENT_LOG_FOLDER}cassandra/"
commitlog_directory="${PARENT_DATA_FOLDER}commitlog/"
cdc_raw_directory="${PARENT_DATA_FOLDER}cdc_raw/"
saved_caches_directory="${PARENT_DATA_FOLDER}saved_caches/"
hints_directory="${PARENT_DATA_FOLDER}hints/"
# spark data and log folders
spark_local_data="${PARENT_DATA_FOLDER}spark/rdd/"
spark_worker_data="${PARENT_DATA_FOLDER}spark/worker/"
spark_master_log_folder="${PARENT_LOG_FOLDER}spark/master/"
spark_worker_log_folder="${PARENT_LOG_FOLDER}spark/worker/"
# dsefs
dsefs_untar_folder="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${DSE_VERSION}/resources/dsefs/"
# gremlin logs
gremlin_log_folder="${PARENT_LOG_FOLDER}gremlin/"
# tomcat logs
tomcat_log_folder="${PARENT_LOG_FOLDER}tomcat/"
# //////////////////////////////////////////
