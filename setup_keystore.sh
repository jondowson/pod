#!/bin/bash

# script_name:  setup_keystore.sh
# author:       jondowson
# about:        generate local key pair and keystore; generate cert request file for a local keystore; import public certs from 3rd parties

#-------------------------------------------

# uncoment to see full bash trace (debug)
# set -x

#-------------------------------------------

# determine host OS
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

# determine script folder path
if [[ ${os} == "Mac" ]]; then
  script=$(greadlink -f "$0")
else
  script=$(readlink -f "$0")
fi
dseSetupFolder=$(dirname $script)

#-------------------------------------------

# get all the application scripts and source them so that their functions are available
# .. don't bother sourcing the setup script
files="$(find ${dseSetupFolder}/lib -name "*.sh*" | grep -v  "dependencies_mac.sh")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

#------------------------------------------- SELECT-CONFIG-FILE !!

# source the config settings file to use
config_file="config_keystore_template.sh"
source ${dseSetupFolder}/configs/setup_keystore/${config_file}

# --------------------------------------------INSTRUCTIONS!!

# threee parts to generating a keystore/truststore

# part1
# - generate a local keystore with a local private key pair
# - unique to the server, this private key has a 'forever' expirary date
# - from this keystore generate a certificate request file and send to the 'corporate root cert team'

# part2
# - import into the keystore the 'corporate root cert team' supplied public certificates (sha1.cer - unreadable and sha2.cer - readable)

# part3
# - import the returned signed certificate from Part1 into the keystore (verified by the 2 certs imported in part2)
# - the keystore (truststore) is now ready to be used.

# Instructions

# (1) $ mkdir -p ~/Datastax/packages/dse/<dse-version>/resources/dse/conf && cd ~/Datastax/packages/dse/<dse-version>/resources/dse/conf
# (2) copy here the corporate public keys e.g. sha1.cer and sha2.cer and this script
# (3) run this script - passing either 'part1', 'part2' or 'part3'

# ./keystore.sh part1      
# ./keystore.sh part2     
# ./keystore.sh part3 

# (4) copy this keystore to each node

# ----------------------------------------- START !!

# incoming variable - either 'part1','part2' or part3
part=${1}

# make some screen space !
clear

# part1 - generate and import certs into a local keystore and from this create a .csr request file
if [[ ${part} == "part1" ]]; then

  printf "%s\n" "${cyan}Pinging each node in cluster by hostname 3 times - if these don't work - fix them !!${reset}"
  keystore_ping_nodes_in_cluster
  printf "%s\n" "${cyan}Generating new local key and putting it in local keystore (store will be made if it does not already exist)${reset}"
  keystore_keytool_generate_key
  printf "%s\n" "${cyan}Listing contents of local keystore${reset}"
  keystore_keytool_list
  printf "%s\n" "${cyan}Generating a request file (.csr) from local keystore - to be validated by corporate body${reset}"
  keystore_keytool_generate_certificate_request
  printf "%s\n"
  printf "%s\n" "${cyan}Please now send the generated '.csr' certificate to the validation team and await their signed '.cer' certificate"
  printf "%s\n" "Once you have it - place it in this folder and run this script again, passing 'part2':"
  printf "%s\n" "$ ./keystore.sh 'part2'${reset}"

# part2 - import the corporate public keys into the keystore in preparation for PART3
elif [[ ${part} == "part2" ]]; then

  printf "%s\n" "${cyan}Importing corporate public and private keys into local keystore${reset}"
  keystore_keytool_import_public_keys
  printf "%s\n" "${cyan}Listing contents of local keystore${reset}"
  keystore_keytool_list
  printf "%s\n"

# part3 - import the returned and signed .csr certificate (now a .cer file) into the local keystore
elif [[ ${part} == *"part3:"* ]]; then

  alias=${part#*:}
  printf "%s\n" "${cyan}Importing the signed cert into the local keystore${reset}"
  keystore_keytool_import_signed_cert
  printf "%s\n" "${cyan}Listing contents of local keystore${reset}"
  keystore_keytool_list
  printf "%s\n"
else
  printf "%s\n" "${red}Something has gone horribly wrong :(${reset}"
fi
