# author:        jondowson
# about:         functions executed on remote server

# ---------------------------------------

function lib_doStuff_remotely_createJavaFolders(){

## create required folders

mkdir -p ${java_untar_folder}${JAVA_VERSION}
mkdir -p ${java_untar_folder}${JAVA_VERSION}/lib/security
}

# ---------------------------------------

function lib_doStuff_remotely_installJavaTar(){

## install from local tar to the designated java folder

tar -xf ${java_tar_file} -C ${java_untar_folder}
unzip ${java_security_zip_file} &>/dev/null
mv UnlimitedJCEPolicyJDK8/*.jar  ${java_untar_folder}${JAVA_VERSION}/lib/security/
rm -rf UnlimitedJCEPolicyJDK8/
}

# ---------------------------------------

function lib_doStuff_remotely_javaBashProfile(){

## configure bash_profile to set paths in an idempotent 'manner'

# file to edit
file="${HOME}/.bash_profile"
touch ${file}

# search for and remove any lines starting with:
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export JAVA_HOME=" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export PATH=\$JAVA_HOME:\$PATH" "dummy"
lib_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export PATH=\$PATH:\$JAVA_HOME" "dummy"

# search for and remove any pre-canned blocks containing a label:
label="java_bash_profile"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# remove any empty blank lines at end of file
a=$(<$file); printf "%s\n" "$a" > $file

# append to end of files
cat << EOF >> ${file}

#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
export JAVA_HOME="${java_untar_folder}${JAVA_VERSION}/bin"
export PATH=\$JAVA_HOME:\$PATH
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF
}

# ---------------------------------------

function lib_doStuff_remotely_bashrc(){

## configure bashrc to source bash_profile everytime a new terminal is started (on ubuntu/centos)

# file to edit
file="${HOME}/.bashrc"
touch ${file}

# search for and remove any pre-canned blocks containing a label:
label="source_bash_rc"
lib_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# remove any empty blank lines at end of file
a=$(<$file); printf "%s\n" "$a" > $file

# add line sourcing .bashrc - no need on a Mac
cat << EOF >> ${file}

#>>>>> BEGIN-ADDED-BY__'${WHICH_POD}@${label}'
if [ -r ~/.bash_profile ]; then source ~/.bash_profile; fi
#>>>>> END-ADDED-BY__'${WHICH_POD}@${label}'
EOF
}
