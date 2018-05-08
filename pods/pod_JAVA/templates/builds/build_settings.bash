# ////////////////////////////////////////// BLOCK 1/4
# DO-NOT-EDIT-THIS-BLOCK !!
# user defined settings are all lowercase. leave alone UPPERCASE variables!!

PACKAGE="JAVA"                                        # empty if pod does not involve tarball
source ${podHomePath}/misc/.suitcase                # file used to access server specific variables on remote machines
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"          # the parent folder with all the tarballs and the pod software
PACKAGES="${POD_SOFTWARE}${PACKAGE}/"                 # the relevant tarball folders for this pod
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"        # the parent folder where tarball software is unpacked to
INSTALL_FOLDER_POD="${INSTALL_FOLDER}${WHICH_POD}/"   # the pod specific folder where tarballs are unpacked to
# //////////////////////////////////////////



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BLOCK 2/4
# EDIT-THIS-BLOCK !!

## [1] SOFTWARE DETAILS

# this needs to match the name of folder in the POD_SOFTWARE folder holding the java tarball

software_name="oracle"
software_version="jxx1.8.x_xxx"
software_tarball="jxx-8uxxx-linux-x64.tar.gz"

java_security_distribution="oracle"
java_security_zip="jce_policy-x.zip"

# [2] TMP FOLDER LOCATIONS

# temp folder - can be anywhere with suffcient permissions
temp_folder="${INSTALL_FOLDER}TEMP/"
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



# ////////////////////////////////////////// BLOCK 3/4
# DO-NOT-EDIT-THIS-BLOCK !!
TAR_FOLDER="${PACKAGES}${software_name}/"
TAR_FILE="${TAR_FOLDER}${software_tarball}"
UNTAR_FOLDER="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/"
UNTAR_EXEC_FOLDER="${UNTAR_FOLDER}bin"
JAVA_FOLDER_SECURITY="${PACKAGES}${java_security_distribution}/"
JAVA_FILE_SECURITY_ZIP="${JAVA_FOLDER_SECURITY}${java_security_zip}"
# //////////////////////////////////////////



# ////////////////////////////////////////// BLOCK 4/4
# DO-NOT-EDIT-THIS-BLOCK !!

## folders to be write tested !!

# build_settings paths from this file to write test
BUILDPATHS_WRITETEST="temp_folder"
# json server paths to write test
JSONPATHS_WRITETEST=""

# note:
# declare all paths (; seperated) to be write tested for this pod
# supply the variable string and omit the '$' - e.g "data_path;log_path"
# no need to specify target_folder as automatically added by function
# the writetest creates and then deletes a dummy folder in the specified path
# any folders that need to exist prior to running the application should be added here
# //////////////////////////////////////////
