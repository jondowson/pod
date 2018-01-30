# about:  set software versions, paths and homogenous settings ( i.e non server.json settings)




# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

## [1] capitalised sub-folder of POD_SOFTWARE where is stored the tarball - e.g. DATASTAX, JAVA ...

# leave empty if pod does not involve tarball !
PACKAGE="JAVA"




# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
source ${pod_home_path}/misc/.suitcase
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"
PACKAGES="${POD_SOFTWARE}${PACKAGE}/"
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"
INSTALL_FOLDER_POD="${INSTALL_FOLDER}${WHICH_POD}/"
# //////////////////////////////////////////




# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

## [2] SOFTWARE DETAILS

# this needs to match the name of folder in the POD_SOFTWARE folder holding the java tarball

SOFTWARE_NAME="oracle"
SOFTWARE_VERSION="jre1.8.0_152"
SOFTWARE_TARBALL="jre-8u152-linux-x64.tar.gz"

# -----

JAVA_SECURITY_DISTRIBUTION="oracle"
JAVA_SECURITY_ZIP="jce_policy-8.zip"

# -----

# [3] TMP FOLDER LOCATIONS

# temp folder - can be anywhere with suffcient permissions
TEMP_FOLDER="${INSTALL_FOLDER}tmp/"
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
TAR_FOLDER="${PACKAGES}${SOFTWARE_NAME}/"
TAR_FILE="${TAR_FOLDER}${SOFTWARE_TARBALL}"
UNTAR_FOLDER="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/"
UNTAR_EXEC_FOLDER="${UNTAR_FOLDER}bin"
java_security_folder="${PACKAGES}${JAVA_SECURITY_DISTRIBUTION}/"
java_security_zip_file="${java_security_folder}${JAVA_SECURITY_ZIP}"
# //////////////////////////////////////////
