#!/bin/bash

# script_name:  setup_ops-agent.sh
# author:       jondowson
# about:        setup opscenter and datastax agent software on a node

#-------------------------------------------

# uncoment to see full bash trace (debug)
# set -x

#-------------------------------------------EDIT-ME!!

## specify dse config script to use

config_file="config_ops-agent6.1.x_template.sh"

#-------------------------------------------LEAVE!!

## determine host OS

os=$(uname -a)
if [[ ${os} == *"Darwin"* ]]; then
  os="Mac"
elif [[ ${os} == *"Ubuntu"* ]]; then
  os="Ubuntu"
elif [[ "$(cat /etc/system-release-cpe)" == *"centos"* ]]; then
  os="Centos"
elif [[ "$(cat /etc/system-release-cpe)" == *"redhat"* ]]; then
  os="Redhat"
else
  os="Bad"
  generic_msg_colour_simple "error" "OS Not Supported"
  exit 1;
fi

#-------------------------------------------

## determine this scripts' folder path

if [[ ${os} == "Mac" ]]; then
  script=$(greadlink -f "$0")
else
  script=$(readlink -f "$0")
fi
dseSetupFolder=$(dirname $script)

#-------------------------------------------

## source other scripts 

# source lib folder scripts - don't bother sourcing dependencies_mac.sh script
files="$(find ${dseSetupFolder}/lib -name "*.sh*" | grep -v  "dependencies_mac.sh")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

# source the ops-agent config settings file to use - specified at top of this script
if [[ -f ${dseSetupFolder}/configs/setup_ops-agent/${config_file} ]]; then 
  source ${dseSetupFolder}/configs/setup_ops-agent/${config_file}
else
  generic_file_exists_check_abort "${dseSetupFolder}/configs/setup_ops-agent/${config_file}"
fi

# ---------------------------------------

## composite path variables - inherits from $config_file
  
# opscenter
ops_tar_folder="${packages_folder}opscenter/"
ops_tar_file="${ops_tar_folder}${ops_tarball}"
ops_untar_config_folder="${install_folder}${ops_version}/conf/"
ops_untar_bin_folder="${install_folder}${ops_version}/bin/"

# datastax-agent
agent_tar_folder="${packages_folder}datastax-agent/"
agent_tar_file="${agent_tar_folder}${agent_tarball}"
agent_untar_config_folder="${install_folder}${agent_version}/conf/"
agent_untar_bin_folder="${install_folder}${agent_version}/bin/"

# ----------------------------------------- START !!

clear
generic_msg_colour_simple "title" "Setting up DSE Opscenter ${yellow}${ops_version}${cyan} and agents ${yellow}${agent_version}${cyan} on this node"

# -----------------

## test specified tarballs exist for opscenter + datastax-agent

# opscenter tarball
if [[ "${ops_install_type}" == "tar" ]]; then
  generic_file_exists_check_abort "${ops_tar_file}"
fi 

# datastax-agent tarball
if [[ "${agent_install_type}" == "tar" ]]; then
  generic_file_exists_check_abort "${agent_tar_file}"
fi 

# -----------------

## opscenter install 

if [[ "${ops_install_type}" == "tar" ]]; then
  generic_msg_colour_simple "alert" "Creating opscenter folders"
  ops_create_ops_folders
  generic_msg_colour_simple "alert" "Untarring ${yellow}${ops_version}"
  ops_install_ops_tar_local
  generic_msg_colour_simple "alert" "Configuring '.bash_profile' for opscenter"
  ops_configure_ops_bash_profile
  if [[ ${os} != "Mac" ]]; then
    generic_msg_colour_simple "alert" "Configuring '.bashrc' to source .bash_profile"
    ops_configure_bashrc
  fi
elif [[ "${ops_install_type}" == "package-internet" ]]; then
  ops_install_dse_package_internet
elif [[ "${ops_install_type}" == "package-private" ]]; then
  :
fi

# -----------------

## datastax-agent install

if [[ "${agent_install_type}" == "tar" ]]; then
  generic_msg_colour_simple "alert" "Creating datastax-agent folders"
  agent_create_agent_folders
  generic_msg_colour_simple "alert" "Untarring ${yellow}${agent_version}"
  agent_install_agent_tar_local
  generic_msg_colour_simple "alert" "Configuring '.bash_profile' for datastax-agent"
  agent_configure_agent_bash_profile
  if [[ ${os} != "Mac" ]]; then
    generic_msg_colour_simple "alert" "Configuring '.bashrc' to source .bash_profile"
    agent_configure_bashrc
  fi
elif [[ "${agent_install_type}" == "package-internet" ]]; then
  agent_install_agent_package_internet
elif [[ "${agent_install_type}" == "package-private" ]]; then
  :
fi

# -----------------

## opscenter configuration files

generic_msg_colour_simple "alert" "Configuring 'opscenterd.conf'"
ops_configure_opscenterd.conf

generic_msg_colour_simple "alert" "Configuring 'ssl.conf'"
ops_configure_ssl.conf

generic_msg_colour_simple "alert" "Configuring 'logback.xml'"
ops_configure_logback.xml

printf "%s\n"

# -----------------

## datastax-agent configuration files

generic_msg_colour_simple "alert" "Configuring 'address.yaml'"
agent_configure_address.yaml

generic_msg_colour_simple "alert" "Configuring 'datastax-agent-env.sh'"
agent_configure_datastax-agent-env.sh

generic_msg_colour_simple "alert" "Configuring 'kerberos.config'"
agent_configure_kerberos.config

generic_msg_colour_simple "alert" "Configuring 'log4j.properties'"
agent_configure_log4j.properties

printf "%s\n"

# -----------------

## screen messages

if [[ ${os} == "Mac" ]] || [[ ${java_install_type} != "tar" ]]; then
  generic_msg_colour_simple "title"     "Final tasks to complete dse-setup"
  generic_msg_colour_simple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
  generic_msg_colour_simple "info"      "$ . ~/.bash_profile"
  generic_msg_colour_simple "info-bold" "(b) Run dse:"
  generic_msg_colour_simple "info"      "$ dse cassandra            # start dse storage"
  generic_msg_colour_simple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
elif [[ ${java_install_type} == "tar" ]]; then
  generic_msg_colour_simple "title"     "Final tasks to complete dse-setup"
  generic_msg_colour_simple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
  generic_msg_colour_simple "info"      "$ . ~/.bash_profile"
  generic_msg_colour_simple "info-bold" "(b) Add java tar to system java alternatives:"
  generic_msg_colour_simple "info"      "$ sudo update-alternatives --install /usr/bin/java java ${java_untar_folder}${jdk_version}/bin/java 100"
  generic_msg_colour_simple "info-bold" "(c) Select this java tar from list:"
  generic_msg_colour_simple "info"      "$ sudo update-alternatives --config java"
  generic_msg_colour_simple "info-bold" "(d) Run dse:"
  generic_msg_colour_simple "info"      "$ dse cassandra            # start dse storage"
  generic_msg_colour_simple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
fi
printf "%s\n"

# -----------------

## TODO
