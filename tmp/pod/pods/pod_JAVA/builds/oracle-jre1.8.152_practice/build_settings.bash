# author:        jondowson
# about:         software version and path configurations for a cluster created by pod_DSE

# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
source ${pod_home_path}/misc/.suitcase
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"
PACKAGES="${POD_SOFTWARE}JAVA/"
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"
INSTALL_FOLDER_POD="${INSTALL_FOLDER}${WHICH_POD}/"
# //////////////////////////////////////////




# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

## [1] JAVA VERSION

# this needs to match the name of folder in the POD_SOFTWARE folder holding the java tarball
# e.g. oracle-java, open-java, azul-zing etc
JAVA_DISTRIBUTION="oracle"
JAVA_VERSION="jre1.8.0_152"
JAVA_TARBALL="jre-8u152-linux-x64.tar.gz"

# -----

JAVA_SECURITY_DISTRIBUTION="oracle"
JAVA_SECURITY_ZIP="jce_policy-8.zip"

# -----

# [2] TMP FOLDER LOCATIONS

# temp folder - can be anywhere with suffcient permissions
TEMP_FOLDER="${INSTALL_FOLDER}tmp/"
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
# java
java_tar_file="${PACKAGES}${JAVA_DISTRIBUTION}/${JAVA_TARBALL}"
java_untar_folder="${INSTALL_FOLDER_POD}${JAVA_DISTRIBUTION}/"
java_security_folder="${PACKAGES}${JAVA_SECURITY_DISTRIBUTION}/"
java_security_zip_file="${java_security_folder}${JAVA_SECURITY_ZIP}"
# //////////////////////////////////////////
