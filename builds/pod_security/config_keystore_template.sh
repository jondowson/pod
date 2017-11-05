#!/bin/bash

# script_name:  config_setup_keystore.template
# author:       jondowson
# about:        settings for 'setup_keystore.sh'

# --------------------------------------------

# dse verison being configure_dsefs_dse
dse_version="dse-5.1.4"
keystore_path="/home/${USER}/Datastax/packages/dse/${dse_version}/resources/dse/conf/"

# auto-calculated: the name of the machine that resolves via DNS to an ip or manually assign
hostname=$(hostname)
#hostname=""

# alias for key/certificate - name appropriately for environment
alias="dev-server"
# certs to import from root folder - can be one or more
declare -a key_array
key_array[0]="sha1.cer"
key_array[1]="sha2.cer"

# local key and keystore specific settings
store_pass="changeit"
key_pass="changeit"
keystore_name="dse-internode.keystore.jks"

# node hostnames for cluster
declare -a node_array
node_array[0]="hostname_1"
node_array[1]="hostname_2"
node_array[2]="hostname_3"

# san setting used when generating a local keypair
comma="false"
for i in "${node_array[@]}"
do
  if [[ ${comma} == "false" ]]; then
    san="dns:${i}"
    comma="true"
  else
    san="${san},dns:${i}"
  fi
done

# dname setting used when generating a local keypair
OU="OU=Project,OU=Unix,OU=Servers"
DC="DC=Acme,DC=co,DC=uk"
O="O=Acme"
L="L=Norwich"
ST="ST=Norfolk"
C="C=GB"
dname="cn=${hostname},${OU},${DC},${O},${L},${ST},${C}"
