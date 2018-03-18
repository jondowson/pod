# about:    non-generic functions executed on remote server

# ---------------------------------------

function lib_doStuff_remotely_pod_DSE-OPSCENTER(){

# [1] delete any previous install folder with the same version
rm -rf ${UNTAR_FOLDER}

# [2] make folders
lib_generic_doStuff_remotely_createFolders "${UNTAR_FOLDER}${SOFTWARE_VERSION}"

# [3] un-compress software
lib_generic_doStuff_remotely_unpackTar "${TAR_FILE}" "${UNTAR_FOLDER}"

# [4] configure local environment
lib_generic_doStuff_remotely_updatePathBashProfile "OPSC_HOME" "${UNTAR_EXEC_FOLDER}"
}
