# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
PACKAGE="DATASTAX"                                    # empty if pod does not involve tarball
source ${pod_home_path}/misc/.suitcase                # file used to access server specific variables on remote machines
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"          # the parent folder with all the tarballs and the pod software
PACKAGES="${POD_SOFTWARE}${PACKAGE}/"                 # the relevant tarball folders for this pod
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"        # the parent folder where tarball software is unpacked to
INSTALL_FOLDER_POD="${INSTALL_FOLDER}${WHICH_POD}/"   # the pod specific folder where tarballs are unpacked to
# //////////////////////////////////////////


# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

## [1] SOFTWARE DETAILS

# match to name of folder in POD_SOFTWARE/${PACKAGE} holding the software tarball
SOFTWARE_NAME="opscenter"
SOFTWARE_VERSION="opscenter-6.1.x"
SOFTWARE_TARBALL="opscenter-6.1.x.tar.gz"

## [2] TMP FOLDER LOCATION

# can be anywhere with suffcient permissions
TEMP_FOLDER="${INSTALL_FOLDER}TEMP/"

## [3] USE THIS OPSCENTER CLUSTER TO STORE METRICS OF OTHER CLUSTERS

# set to true to apply the [storage_cassandra] block defined in the server json, to Opscenter's /conf/clusters/cluster_name.conf config file
# to use ssl - add keystore/truststore paths to the json file, otherwise leave all empty!
apply_storage_cluster="true"
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
TAR_FOLDER="${PACKAGES}${SOFTWARE_NAME}/"
TAR_FILE="${TAR_FOLDER}${SOFTWARE_TARBALL}"
UNTAR_FOLDER="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/"
UNTAR_EXEC_FOLDER="${UNTAR_FOLDER}bin"
opscenter_untar_folder="${UNTAR_FOLDER}${SOFTWARE_VERSION}"
opscenter_untar_config_folder="${opscenter_untar_folder}/conf/"
opscenter_untar_bin_folder="${opscenter_untar_folder}/bin/"
opscenter_untar_log_folder="${opscenter_untar_folder}/log/"

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
