# ////////////////////////////////////////// BLOCK 1/4
# DO-NOT-EDIT-THIS-BLOCK !!
# user defined settings are all lowercase. leave alone UPPERCASE variables!!

PACKAGE="DATASTAX"                                    # empty if pod does not involve tarball
source ${podHomePath}/misc/.suitcase                # file used to access server specific variables on remote machines
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"          # the parent folder with all the tarballs and the pod software
PACKAGES="${POD_SOFTWARE}${PACKAGE}/"                 # the relevant tarball folders for this pod
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"        # the parent folder where tarball software is unpacked to
INSTALL_FOLDER_POD="${INSTALL_FOLDER}${WHICH_POD}/"   # the pod specific folder where tarballs are unpacked to
# //////////////////////////////////////////



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BLOCK 2/4
# EDIT-THIS-BLOCK !!

## [1] SOFTWARE DETAILS

# match to name of folder in POD_SOFTWARE/${PACKAGE} holding the software tarball
software_name="opscenter"
software_version="opscenter-6.5.0"
software_tarball="opscenter-6.5.0.tar.gz"

## [2] TMP FOLDER LOCATION

# can be anywhere with suffcient permissions
temp_folder="${INSTALL_FOLDER}TEMP/"

## [3] USE THIS OPSCENTER CLUSTER TO STORE METRICS OF OTHER CLUSTERS

# set to true to apply the [storage_cassandra] block defined in the server json, to Opscenter's /conf/clusters/cluster_name.conf config file
# to use ssl - add keystore/truststore paths to the json file, otherwise leave all empty!
apply_storage_cluster="false"
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



# ////////////////////////////////////////// BLOCK 3/4
# DO-NOT-EDIT-THIS-BLOCK !!
TAR_FOLDER="${PACKAGES}${software_name}/"
TAR_FILE="${TAR_FOLDER}${software_tarball}"
UNTAR_FOLDER="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/"
UNTAR_EXEC_FOLDER="${UNTAR_FOLDER}bin"
OPSCENTER_FOLDER_UNTAR="${UNTAR_FOLDER}${software_version}"
OPSCENTER_FOLDER_UNTAR_CONFIG="${OPSCENTER_FOLDER_UNTAR}/conf/"
OPSCENTER_FOLDER_UNTAR_BIN="${OPSCENTER_FOLDER_UNTAR}/bin/"
OPSCENTER_FOLDER_UNTAR_LOG="${OPSCENTER_FOLDER_UNTAR}/log/"
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
