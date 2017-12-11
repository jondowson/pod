#!/bin/bash

# author:        jondowson
# about:         software version and path configurations for a cluster created by 'pod_dse'
#                this file should not be renamed !!

# ========================================= OPTIONS !!

## [1] choose 'basic' cluster-wide cassandra settings

CLUSTER_NAME="My Kluster"                       # avoid special characters !!
ENDPOINT_SNITCH="GossipingPropertyFileSnitch"   # 'GossipingPropertyFileSnitch' should be the default !!
VNODES="8"                                      # specify a value (8,16,32) for vnodes or "false" for assigned tokens (picked up from servers' .json definition file)

# -----------------------------------------

## [2] choose dse software version

DSE_VERSION="dse-5.1.5"
DSE_TARBALL="${DSE_VERSION}-bin.tar.gz"

# -----------------------------------------

## [3] choose required folder-paths

# note: out of the box - all paths hang off 'TARGET_FOLDER' - specified for each server in the <server.json> defintion file

# this file will contain any server specific settings defined at runtime, including TARGET_FOLDER
source ${pod_home_path}/pods/${WHICH_POD}/builds/dynamic_build_settings

# the location of the POD_SOFTWARE folder
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"
# the PACKAGES folder should always hang-off POD_SOFTWARE
PACKAGES="${POD_SOFTWARE}DATASTAX/"

# -----

# where dse tarball is uncompressed to - can be anywhere with suffcient permissions
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"
INSTALL_FOLDER_POD="${TARGET_FOLDER}POD_INSTALLS/DATASTAX/"

# -----

# location of logs and data folders

# note: cassandra data folders are specified in the specified servers .json definition file
# this data folder is where the supporting persistence files will go such as commitlogs and hinted-handoffs
PARENT_DATA_FOLDER="${INSTALL_FOLDER_POD}${dse_version}data/"
PARENT_LOG_FOLDER="${INSTALL_FOLDER_POD}${dse_version}logs/"

# -----

# temp folder - can be anywhere with suffcient permissions
TEMP_FOLDER="${INSTALL_FOLDER}tmp/"


# ========================================= END !!



## recommended settings - alter with care !!

# dse
dse_tar_folder="${PACKAGES}dse/"
dse_tar_file="${dse_tar_folder}${DSE_TARBALL}"
#dse_untar_config_folder="${INSTALL_FOLDER_POD}${DSE_VERSION}/resources/dse/conf/"
dse_untar_config_folder="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/resources/dse/conf/"
#dse_untar_bin_folder="${INSTALL_FOLDER_POD}${DSE_VERSION}/bin/"
dse_untar_bin_folder="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/bin/"

# -----------------

# required for java
Djava_tmp_folder="${TEMP_FOLDER}"

# -----------------

# cassandra
cassandra_log_folder="${PARENT_LOG_FOLDER}cassandra/"
commitlog_directory="${PARENT_DATA_FOLDER}commitlog/"
cdc_raw_directory="${PARENT_DATA_FOLDER}cdc_raw/"
saved_caches_directory="${PARENT_DATA_FOLDER}saved_caches/"
hints_directory="${PARENT_DATA_FOLDER}hints/"
cassandra_untar_config_folder="${INSTALL_FOLDER_POD}${DSE_VERSION}/resources/cassandra/conf/"

# -----------------

# spark data and log folders
spark_local_data="${PARENT_DATA_FOLDER}spark/rdd/"
spark_worker_data="${PARENT_DATA_FOLDER}spark/worker/"
spark_master_log_folder="${PARENT_LOG_FOLDER}spark/master/"
spark_worker_log_folder="${PARENT_LOG_FOLDER}spark/worker/"
spark_untar_config_folder="${INSTALL_FOLDER_POD}${DSE_VERSION}/resources/spark/conf/"

# -----------------

# dsefs
dsefs_untar_folder="${INSTALL_FOLDER_POD}${DSE_VERSION}/resources/dsefs/"

# -----------------

# gremlin logs
gremlin_log_folder="${PARENT_LOG_FOLDER}gremlin/"

# -----------------

# tomcat logs
tomcat_log_folder="${PARENT_LOG_FOLDER}tomcat/"
