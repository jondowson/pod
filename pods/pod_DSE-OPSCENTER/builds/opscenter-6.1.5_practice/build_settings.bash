# about:  set software versions, paths and homogenous settings ( i.e non server.json settings)




# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

## [1] capitalised sub-folder of POD_SOFTWARE where is stored the tarball - e.g. DATASTAX, JAVA ...

# leave empty if pod does not involve tarball !
PACKAGE="DATASTAX"




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

# match to name of folder in POD_SOFTWARE/${PACKAGE} holding the software tarball
SOFTWARE_NAME="opscenter"
SOFTWARE_VERSION="opscenter-6.1.5"
SOFTWARE_TARBALL="opscenter-6.1.5.tar.gz"

# -----

# [3] TMP FOLDER LOCATION

# temp folder - can be anywhere with suffcient permissions
TEMP_FOLDER="${INSTALL_FOLDER}TEMP/"
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
# //////////////////////////////////////////
