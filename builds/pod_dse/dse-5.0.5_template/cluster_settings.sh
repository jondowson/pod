#!/bin/bash

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

# -----------------------------------------

## [2] choose 'basic' cluster-wide cassandra settings

CLUSTER_NAME="My Kluster"                       # avoid special characters !!
ENDPOINT_SNITCH="GossipingPropertyFileSnitch"   # 'GossipingPropertyFileSnitch' should be the default !!
VNODES="8"                                      # specify a value (8,16,32) for vnodes or "false" for assigned tokens (picked up from servers/<file>.json)

# -----------------------------------------

## [3] choose software versions

# note: on a Mac, Java installs pod cannot manage installs from tars - so always ignored

# this needs to match the name of folder in the DSE_SOFTWARE folder holding the java tarball - e.g. oracle-java, open-java, azul-zing etc
JAVA_DISTRIBUTION="oracle-java" 
JAVA_VERSION="jre1.8.0_152"
JAVA_TARBALL="jre-8u152-linux-x64.tar.gz"
# -----
DSE_VERSION="dse-5.0.5"
DSE_TARBALL="${DSE_VERSION}-bin.tar.gz"

# -----------------------------------------

## [4] choose required folder-paths

# note: use defualts or change to suit
# note: leave trailing '/' for all FOLDER paths but NOT file paths !!!!!!
# note: out of the box - all paths hang off 'LOCAL_TARGET_FOLDER'

# -----

# the target folder is where the DSE_SOFTWARE and pod folders will be copied to on remote servers
# out-of-the-box it is the default location as well for dse-installation folder containing the untarred and configured binaries
# for local setups it does not matter that you are sending the software to where it originated from
# for remote servers, this setting will be auto-edited based on the value set in server's json file definition 
# if desired, DSE_SOFTWARE + pod can be copied to different folders on different machines
LOCAL_TARGET_FOLDER="/home/jd/Desktop/"

# -----

# where dse tarballs are unpacked to from the LOCAL_TARGET_FOLDER
INSTALL_FOLDER="${LOCAL_TARGET_FOLDER}dse-installations/"

# -----

# location of logs and data folders
PARENT_LOG_FOLDER="${INSTALL_FOLDER}${dse_version}data.logs/logs/"
PARENT_DATA_FOLDER="${INSTALL_FOLDER}${dse_version}data.logs/data/"

# -----

# temp folder where java has write permissions
TEMP_FOLDER="${INSTALL_FOLDER}tmp/"

# -----------------CHANGE-WITH-CAUTION!!

# the local folder holding the datastax/java binaries
DSE_SOFTWARE="${LOCAL_TARGET_FOLDER}DSE_SOFTWARE/"

# PACKAGES needs to be set but can be set to DSE_SOFTWARE
# i.e. it allows you to add sub-folders and the default setting reflects this
# don't forget the trailing '/'
PACKAGES="${DSE_SOFTWARE}packages/"


# ========================================= END !!


## lower case composite paths - no need to edit !!

# java
Djava_tmp_folder="${TEMP_FOLDER}"
java_tar_file="${PACKAGES}${JAVA_DISTRIBUTION}/${JAVA_TARBALL}"
java_untar_folder="${INSTALL_FOLDER}${JAVA_DISTRIBUTION}/"

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
