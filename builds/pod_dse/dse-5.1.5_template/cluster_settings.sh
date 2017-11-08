#!/bin/bash

# script_name:   cluster_settings.sh
# author:        jondowson
# about:         software version and path configurations for a cluster created by 'pod_dse'
#                this file should not be renamed !!

# ========================================= OPTIONS !!

## [1] choose java and dse install types

# java: options are 'tar' or 'false'
# note: on a mac, java installs cannot be managed from tars - so always is read as 'false'
JAVA_INSTALL_TYPE="tar"

# dse: options are 'tar' or 'false'
# note: on a mac, dse package installs are not available - so always is read as 'tar'
DSE_INSTALL_TYPE="tar"

# TODO
# add options 'package-internet', 'package-private'
# (hence the above option for dse_install_type)

# -----------------------------------------

## [2] choose 'basic' cluster-wide cassandra settings

CLUSTER_NAME="My Kluster"                       # avoid special characters !!
ENDPOINT_SNITCH="GossipingPropertyFileSnitch"   # 'GossipingPropertyFileSnitch' should be the default !!
VNODES="8"                                      # specify a value (8,16,32) for vnodes or "false" for assigned tokens (picked up from servers/<file>.json)

# -----------------------------------------

## [3] choose software versions

# note: on a Mac, Java installs cannot be managed from tars - so always ignored
JAVA_VERSION="jre1.8.0_152"
JAVA_TARBALL="jre-8u152-linux-x64.tar.gz"
# -----
DSE_VERSION="dse-5.1.5"
DSE_TARBALL="${DSE_VERSION}-bin.tar.gz"

# -----------------------------------------

## [4] choose required folder-paths

# note: leave trailing '/' for all FOLDER paths but NOT file paths !!!!!!
# note: out of the box - all paths hang off 'LOCAL_TARGET_FOLDER'

# -----------------YOU-MAY-WANT-TO-CHANGE-DEFAULTS!!

# the target folder is where the DSE_SOFTWARE and pod folders will be copied to 
# note: the LOCAL_TARGET_FOLDER applies to the machine running pod and will be auto-edited for remote servers
LOCAL_TARGET_FOLDER="/home/jd/Desktop/"

# -----

# where dse tarballs are unpacked to
INSTALL_FOLDER="${LOCAL_TARGET_FOLDER}dse-installations/"
# set parent level folders for data and log folders

# -----

# location of logs and data folders
PARENT_LOG_FOLDER="${INSTALL_FOLDER}${dse_version}data.logs/logs/"
PARENT_DATA_FOLDER="${INSTALL_FOLDER}${dse_version}data.logs/data/"

# -----

# temp folder where java has write permissions
TEMP_FOLDER="${INSTALL_FOLDER}tmp/"

# -----------------CHANGE-WITH-CAUTION!!

DSE_SOFTWARE="${LOCAL_TARGET_FOLDER}DSE_SOFTWARE/"
# the local folder holding the datastax/java binaries
# note: needs to hang off ${DSE_SOFTWARE} and can be same as ${DSE_SOFTWARE} !!!!!
# i.e. you can add sub-folders - don't forget trailing '/'
PACKAGES="${LOCAL_TARGET_FOLDER}DSE_SOFTWARE/packages/"


# ========================================= END !!


## lower case composite paths - no need to edit !!

# java
Djava_tmp_folder="${TEMP_FOLDER}"
java_tar_file="${PACKAGES}oracle-java/${JAVA_TARBALL}"
java_untar_folder="${INSTALL_FOLDER}oracle-java/"

# -----------------

# dse
dse_tar_folder="${PACKAGES}dse/"
dse_tar_file="${dse_tar_folder}${DSE_TARBALL}"
dse_untar_config_folder="${INSTALL_FOLDER}${DSE_VERSION}/resources/dse/conf/"
dse_untar_bin_folder="${INSTALL_FOLDER}${DSE_VERSION}/bin/"

# -----------------

# cassandra
cassandra_log_folder="${PARENT_LOG_FOLDER}cassandra/"
commitlog_directory="${PARENT_DATA_FOLDER}commitlog/"
cdc_raw_directory="${PARENT_DATA_FOLDER}cdc_raw/"
saved_caches_directory="${PARENT_DATA_FOLDER}saved_caches/"
hints_directory="${PARENT_DATA_FOLDER}hints/"
cassandra_untar_config_folder="${INSTALL_FOLDER}${DSE_VERSION}/resources/cassandra/conf/"

# -----------------

# spark data and log folders
spark_local_data="${PARENT_DATA_FOLDER}spark/rdd/"
spark_worker_data="${PARENT_DATA_FOLDER}spark/worker/"
spark_master_log_folder="${PARENT_LOG_FOLDER}spark/master/"
spark_worker_log_folder="${PARENT_LOG_FOLDER}spark/worker/"
spark_untar_config_folder="${INSTALL_FOLDER}${DSE_VERSION}/resources/spark/conf/"

# -----------------

# gremlin
gremlin_log_folder="${PARENT_LOG_FOLDER}gremlin/"

# -----------------

# dsefs
dsefs_untar_folder="${INSTALL_FOLDER}${DSE_VERSION}/resources/dsefs/"

# -----------------

# tomcat
tomcat_log_folder="${PARENT_LOG_FOLDER}tomcat/"

# -----------------
