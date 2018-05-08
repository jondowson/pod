function lib_doStuffRemotely_pod_JAVA(){

## install from local tar to the designated java folder

# [1] delete any previous pod build folder with the same name
rm -rf ${UNTAR_FOLDER}

# on a mac don't do anything
if [[ ${os} != *"Mac"* ]]; then

  # [2] make folders
  GENERIC_lib_doStuff_remotely_createFolders "${UNTAR_FOLDER}${software_version}"
  GENERIC_lib_doStuff_remotely_createFolders "${UNTAR_FOLDER}${software_version}/lib/security"

  # [3] un-compress software
  GENERIC_lib_doStuff_remotely_unpackTar "${TAR_FILE}" "${UNTAR_FOLDER}"
  lib_doStuffRemotely_installJavaSecurity

  # [4] configure local environment
  lib_doStuffRemotely_updateJavaPathBashProfile "JAVA_HOME" "${UNTAR_FOLDER}${software_version}"

fi
}

# ---------------------------------------

function lib_doStuffRemotely_installJavaSecurity(){

## install from local tar to the designated java folder

unzip ${java_security_zip_file} &>/dev/null
mv UnlimitedJCEPolicyJDK8/*.jar  ${UNTAR_FOLDER}${software_version}/lib/security/
chmod 0644 ${UNTAR_FOLDER}${software_version}/lib/security/*.jar
rm -rf UnlimitedJCEPolicyJDK8/
}

# ---------------------------------------

function lib_doStuffRemotely_updateJavaPathBashProfile(){

## configure bash_profile to set paths in an idempotent 'manner'

program_home="${1}"
folder_path="${2}"

# file to edit
file="${HOME}/.bash_profile"
touch "${file}"

# search for and remove any lines starting with:
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export ${program_home}=" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$${program_home}:\$PATH" "dummy"
GENERIC_lib_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" "${file}" "export PATH=\$PATH:\$${program_home}" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="${program_home}_bash_profile"
#GENERIC_lib_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"
GENERIC_lib_strings_removePodBlockAndEmptyLines ${file} "${WHICH_POD}@${label}"

# remove any empty blank lines at end of file
a=$(<$file); printf "%s\n" "$a" > $file

# append to end of files
cat << EOF >> ${file}

#>>>>>BEGIN-ADDED-BY__${WHICH_POD}@${label}
export ${program_home}="${folder_path}"
export PATH=\$${program_home}/bin:\$PATH
export JVM_OPTS="-Djava.io.tmpdir=${temp_folder}"
#>>>>>END-ADDED-BY__${WHICH_POD}@${label}
EOF
}
