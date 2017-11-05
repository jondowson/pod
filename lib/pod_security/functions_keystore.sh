#!/bin/bash

# script_name:   functions_keystore.sh
# author:        jondowson
# about:         bash functions used by and specific to 'setup_keystore.sh'

# ---------------------------------------

function keystore_ping_nodes_in_cluster(){

# ensure other nodes are reachable via their hostnames

for i in "${node_array[@]}"
do
  ping -c 3 ${i}
done
}

# --------------------------------------------

function keystore_keytool_list(){

# list keys for a given keystore

keytool -list \
-keystore ${keystore_name} \
-storepass ${store_pass}
}

# --------------------------------------------

function keystore_keytool_import_public_keys(){

# import existing public keys into a given keystore

for i in "${key_array[@]}"
do
  keytool -keystore ${keystore_name} \
  -alias ${i} \
  -importcert -file ${i} \
  -keypass ${key_pass} \
  -storepass ${store_pass} \
  -noprompt
done
}

# --------------------------------------------

function keystore_keytool_generate_key(){

# generate a keypair - the keystore will be made if it does not already exist

keytool -genkeypair \
-keyalg RSA \
-keysize 2048 \
-sigalg SHA256withRSA \
-alias ${alias} \
-ext SAN=${san} \
-keystore ${keystore_name} \
-keypass ${key_pass} \
-storepass ${store_pass} \
-dname ${dname}
}

# --------------------------------------------

function keystore_keytool_generate_certificate_request(){

# generate a certificate request file - this will be sent back to corporate root cert team

keytool -certreq  \
-alias ${alias} \
-keystore ${keystore_name} \
-file ${alias}.csr
}

# --------------------------------------------

function keystore_keytool_import_signed_cert(){

# the returned re-signed certificate file is imported into the keystore

keytool  -importcert -noprompt \
-keystore ${keystore_name} \
-alias ${alias} \
-file ${alias} \
-keypass ${key_pass} \
-storepass ${store_pass}
}
