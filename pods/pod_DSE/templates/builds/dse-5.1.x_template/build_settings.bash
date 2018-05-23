# ////////////////////////////////////////// BLOCK 1/4
# DO-NOT-EDIT-THIS-BLOCK !!
# user defined settings are all lowercase. leave alone UPPERCASE variables!!

PACKAGE="DATASTAX"                                    # empty if pod does not involve tarball
source ${podHomePath}/misc/.suitcase                  # file used to access server specific variables on remote machines
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"          # the parent folder with all the tarballs and the pod software
PACKAGES="${POD_SOFTWARE}${PACKAGE}/"                 # the relevant tarball folders for this pod
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"        # the parent folder where tarball software is unpacked to
INSTALL_FOLDER_POD="${INSTALL_FOLDER}${WHICH_POD}/"   # the pod specific folder where tarballs are unpacked to
# //////////////////////////////////////////



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BLOCK 2/4
# EDIT-THIS-BLOCK !!

# [1] BASIC CASSANDRA SETTINGS

cluster_name="dse-5.1.x_name"                         # avoid special characters !!
endpoint_snitch="GossipingPropertyFileSnitch"         # 'GossipingPropertyFileSnitch' should be the default !!
vnodes="8"                                            # specify a value (8,16) for vnodes or "false" to pick up assigned token from json definition file

# [2] DSE + AGENT VERSIONS

dse_version="dse-5.1.x"                               # the dse tarball version to unpack
agent_version="datastax-agent-6.x.x"                  # the datastax agent tarball version to unpack

# [3] DATA + LOG + TMP FOLDER LOCATIONS

parent_data_folder="${INSTALL_FOLDER_POD}DATA/${BUILD_FOLDER}/"
parent_log_folder="${INSTALL_FOLDER_POD}LOGS/${BUILD_FOLDER}/"
# temp folder - can be anywhere with suffcient permissions
temp_folder="${INSTALL_FOLDER}TEMP/"

## note:
# cassandra sstable data folders are specified in the <servers.json> definition file
# the 'parent_data_folder' is where the supporting persistence files will go such as commitlogs and hinted-handoffs
# on spinning disks it is recommended to locate these on seperate mount points to sstable data folders
# by default DATA and LOGS folders are created inside the POD_INSTALLS desktop folder
# this seperation means that pod_REMOVE-PODS will NOT by default delete existing data associated with a build
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



# ////////////////////////////////////////// BLOCK 3/4
# DO-NOT-EDIT-THIS-BLOCK !!

# tarballs
DSE_TARBALL="${dse_version}-bin.tar.gz"
AGENT_TARBALL="${agent_version}.tar.gz"
# dse paths
DSE_FOLDER_TAR="${PACKAGES}dse/"
DSE_FILE_TAR="${DSE_FOLDER_TAR}${DSE_TARBALL}"
DSE_FOLDER_UNTAR_CONFIG="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${dse_version}/resources/dse/conf/"
DSE_FOLDER_UNTAR_BIN="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${dse_version}/bin/"
# datastax-agent paths
AGENT_FOLDER_TAR="${PACKAGES}datastax-agent/"
AGENT_FILE_TAR="${AGENT_FOLDER_TAR}${AGENT_TARBALL}"
AGENT_FOLDER_UNTAR="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${agent_version}"
AGENT_FOLDER_UNTAR_CONFIG="${AGENT_FOLDER_UNTAR}/conf/"
AGENT_FOLDER_UNTAR_BIN="${AGENT_FOLDER_UNTAR}/bin/"
AGENT_FOLDER_UNTAR_LOG="${AGENT_FOLDER_UNTAR}/log/"
# cassandra paths
CASSANDRA_FOLDER_LOG="${parent_log_folder}cassandra/"
CASSANDRA_FOLDER_COMMITLOG="${parent_data_folder}commitlog/"
CASSANDRA_FOLDER_CDCRAW="${parent_data_folder}cdc_raw/"
CASSANDRA_FOLDER_SAVEDCACHES="${parent_data_folder}saved_caches/"
CASSANDRA_FOLDER_HINTS="${parent_data_folder}hints/"
# spark data + log folder paths
SPARK_FOLDER_LOCALDATA="${parent_data_folder}spark/rdd/"
SPARK_FOLDER_WORKERDATA="${parent_data_folder}spark/worker/"
SPARK_FOLDER_MASTERLOG="${parent_log_folder}spark/master/"
SPARK_FOLDER_WORKERLOG="${parent_log_folder}spark/worker/"
# dsefs paths
DSEFS_FOLDER_UNTAR="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/${dse_version}/resources/dsefs/"
DSEFS_FOLDER_WORK="${parent_data_folder}dsefs_work/"
# gremlin log path
GREMLIN_FOLDER_LOG="${parent_log_folder}gremlin/"
# tomcat log path
TOMCAT_FOLDER_LOG="${parent_log_folder}tomcat/"
# //////////////////////////////////////////



# ////////////////////////////////////////// BLOCK 4/4
# DO-NOT-EDIT-THIS-BLOCK !!

## folders to be write tested !!

# build_settings paths from this file to write test
BUILDPATHS_WRITETEST="temp_folder;parent_data_folder;parent_log_folder;SPARK_FOLDER_LOCALDATA;SPARK_FOLDER_WORKERDATA;SPARK_FOLDER_MASTERLOG;SPARK_FOLDER_WORKERLOG;DSEFS_FOLDER_WORK"
# json server paths to write test
JSONPATHS_WRITETEST="cass_data;dsefs_data"

# note:
# declare all paths (; seperated) to be write tested for this pod
# supply the variable string and omit the '$' - e.g "data_path;log_path"
# no need to specify target_folder as automatically added by function
# the writetest creates and then deletes a dummy folder in the specified path
# any folders that need to exist prior to running the application should be added here
# //////////////////////////////////////////
