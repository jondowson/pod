# author:        jondowson
# about:         software version and path configurations for a cluster created by pod_DSE

# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
source ${pod_home_path}/misc/.suitcase
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"
INSTALL_FOLDER_POD="${TARGET_FOLDER}POD_INSTALLS/DATASTAX/"
# //////////////////////////////////////////




# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

# pod_DSE build to edit on servers
pod_DSE_build_folder="dse-5.1.5_practice"

# -----

## dse.yaml

# audit logging settings
audit_logging_enabled="true"
audit_logging_included_categories="DML,DDL,DCL,AUTH,ADMIN,ERROR"
audit_logging_included_keyspaces="ob_accounts,ob_payauth,ob_paysub"

# at rest TDE encryption settings
tde_encryption_system_info_enabled="true"
tde_encryption_cipher_algorithm="AES"
tde_encryption_secret_key_strength="256"
tde_encryption_chunk_length_kb="64"

# -----

## cassandra.yaml

# server_encryption_options
server_encryption_internode_encryption="all"
server_encryption_keystore="/etc/dse/conf/Nwide_ob.keystore.jks"
server_encryption_keystore_password="changeit"
server_encryption_truststore="/etc/dse/conf/Nwide_ob.truststore.jks"
server_encryption_truststore_password="changeit"
# server_encryption_protocol="TLS"
# server_encryption_algorithm="SunX509"
# server_encryption_store_type="JKS"
server_encryption_cipher_suites= "[TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]"
server_encryption_require_client_auth="true"
# server_encryption_require_endpoint_verification="false"

# enable or disable client/server encryption
client_encryption_enabled="false"
client_encryption_optional="false"
client_encryption_keystore_client_server="/etc/dse/conf/Nwide_ob.keystore.jks"
client_encryption_keystore_client_server_password="changeit"
# client_encryption_require_client_auth="false"
# client_encryption_truststore="resources/dse/conf/.truststore"
# client_encryption_truststore_password="cassandra"
# client_encryption_protocol="TLS"
# client_encryption_algorithm="SunX509"
# client_encryption_store_type="JKS"
# client_encryption_cipher_suites="[TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]"

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
# java

# //////////////////////////////////////////
