# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
PACKAGE="JAVA"                                        # empty if pod does not involve tarball
source ${pod_home_path}/misc/.suitcase                # file used to access server specific variables on remote machines
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"          # the parent folder with all the tarballs and the pod software
PACKAGES="${POD_SOFTWARE}${PACKAGE}/"                 # the relevant tarball folders for this pod
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"        # the parent folder where tarball software is unpacked to
INSTALL_FOLDER_POD="${INSTALL_FOLDER}${WHICH_POD}/"   # the pod specific folder where tarballs are unpacked to
# //////////////////////////////////////////


# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

## [1] SOFTWARE DETAILS

# this needs to match the name of folder in the POD_SOFTWARE folder holding the java tarball

SOFTWARE_NAME="oracle"
SOFTWARE_VERSION="jre1.8.0_152"
SOFTWARE_TARBALL="jre-8u152-linux-x64.tar.gz"

JAVA_SECURITY_DISTRIBUTION="oracle"
JAVA_SECURITY_ZIP="jce_policy-8.zip"

# [2] TMP FOLDER LOCATIONS

# temp folder - can be anywhere with suffcient permissions
TEMP_FOLDER="${INSTALL_FOLDER}TEMP/"
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
TAR_FOLDER="${PACKAGES}${SOFTWARE_NAME}/"
TAR_FILE="${TAR_FOLDER}${SOFTWARE_TARBALL}"
UNTAR_FOLDER="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/"
UNTAR_EXEC_FOLDER="${UNTAR_FOLDER}bin"
java_security_folder="${PACKAGES}${JAVA_SECURITY_DISTRIBUTION}/"
java_security_zip_file="${java_security_folder}${JAVA_SECURITY_ZIP}"

## folders to be write tested !!
# declare all paths (; seperated) to be write tested for this pod
# supply the variable string and omit the '$' - e.g "data_path;log_path"
# no need to specify target_folder as automatically added by function
# the writetest creates and then deletes a dummy folder in the specified path
# any folders that need to exist prior to running the application should be added here

# build_settings paths from this file to write test
buildPathsWriteTest="TEMP_FOLDER"
# json server paths to write test
jsonPathsWriteTest=""
# //////////////////////////////////////////
