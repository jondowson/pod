#!/bin/bash

# author:        jondowson
# about:         software version and path configurations for 'pod_java'
#                this file should not be renamed !!

# ----------------------------------------- AUTO-EDITED !!

# the TARGET_FOLDER is where the java and pod folders will be copied to on each server 
# the java tarball will subsequently be uncompressed to a user defined folder (see below)

# this value is auto-edited and is taken from the servers' .json defintion file
TARGET_FOLDER="/home/jd/Desktop/"

# ----------------------------------------- END !!





# ========================================= OPTIONS !!


## [1] choose java binaries

# this needs to match the name of folder in the POD_SOFTWARE folder holding the java tarball
# e.g. oracle-java, open-java, azul-zing etc
JAVA_DISTRIBUTION="oracle-java" 
JAVA_VERSION="jre1.8.0_152"
JAVA_TARBALL="jre-8u152-linux-x64.tar.gz"

# -----------------------------------------

## [2] choose required folder-paths

# note: out of the box - all paths hang off 'TARGET_FOLDER'

# the POD_SOFTWARE folder should always hang-off TARGET_FOLDER
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"

# PACKAGES needs to hang off POD_SOFTWARE - default is POD_SOFTWARE/packages
# but can be set to just POD_SOFTWARE
PACKAGES="${POD_SOFTWARE}packages/"

# -----

# where java tarball is uncompressed to - can be anywhere with suffcient permissions
INSTALL_FOLDER="${TARGET_FOLDER}pod-installations/"

# -----

# temp folder where java has write permissions - can be anywhere with suffcient permissions
TEMP_FOLDER="${INSTALL_FOLDER}tmp/"


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
