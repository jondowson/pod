#!/bin/bash

# author:        jondowson
# about:         software version and path configurations for a cluster created by 'pod_JAVA'
#                this file should not be renamed !!

# ========================================= OPTIONS !!

## [1] choose java binaries

# this needs to match the name of folder in the POD_SOFTWARE folder holding the java tarball
# e.g. oracle-java, open-java, azul-zing etc
JAVA_DISTRIBUTION="oracle"
JAVA_VERSION="jre1.8.0_152"
JAVA_TARBALL="jre-8u152-linux-x64.tar.gz"

# -----------------------------------------

## [2] choose required folder-paths

# note: out of the box - all paths hang off 'TARGET_FOLDER' - specified for each server in the <server.json> defintion file

# the location of the POD_SOFTWARE folder
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"
# the PACKAGES folder should always hang-off POD_SOFTWARE
PACKAGES="${POD_SOFTWARE}JAVA/"

# -----

# where dse tarball is uncompressed to - can be anywhere with suffcient permissions
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"
INSTALL_FOLDER_POD="${TARGET_FOLDER}POD_INSTALLS/JAVA/"

# -----

# temp folder - can be anywhere with suffcient permissions
TEMP_FOLDER="${INSTALL_FOLDER}tmp/"


# ========================================= END !!


java_tar_file="${PACKAGES}${JAVA_DISTRIBUTION}/${JAVA_TARBALL}"
java_untar_folder="${INSTALL_FOLDER}JAVA/${JAVA_DISTRIBUTION}/"
