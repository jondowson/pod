#!/bin/bash

# author:        jondowson
# about:         functions executed on remote server

# ---------------------------------------

function pod_java_run_remote_createJavaFolders(){

## create required folders

# java
mkdir -p ${java_untar_folder}
}

# ---------------------------------------

function pod_java_run_remote_installJavaTar(){

## install from local tar to the designated java folder

tar -xf ${java_tar_file} -C ${java_untar_folder}
}

# ---------------------------------------

function pod_java_run_remote_javaBashProfile(){

## configure bash_profile to set paths in an idempotent 'manner'

# file to edit
file="${HOME}/.bash_profile"
touch ${file}

# search for and remove any lines starting with:
pod_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export JAVA_HOME=" "dummy"
pod_generic_strings_sedStringManipulation "searchFromLineStartAndRemoveEntireLine" ${file} "export PATH=\$PATH:\$JAVA_HOME" "dummy"

# append to end of files
cat << EOF >> ${file}
export JAVA_HOME="${java_untar_folder}${JAVA_VERSION}/bin"
export PATH=\$PATH:\$JAVA_HOME
EOF
}

# ---------------------------------------

function pod_java_run_remote_bashrc(){

## configure bashrc to source bash_profile everytime a new terminal is started (on ubuntu/centos)

# file to edit
file="${HOME}/.bashrc"
touch ${file}

# search for and remove any pre-canned blocks containing a label:
label="source_bash_profile"
pod_generic_strings_sedStringManipulation "searchAndReplaceLabelledBlock" ${file} "${label}" "dummy"

# add line sourcing .bashrc - no need on a Mac
cat << EOF >> ${file}
#BOF CLEAN-${label}
if [ -r ~/.bash_profile ]; then source ~/.bash_profile; fi
#EOF CLEAN-${label}
EOF
}
