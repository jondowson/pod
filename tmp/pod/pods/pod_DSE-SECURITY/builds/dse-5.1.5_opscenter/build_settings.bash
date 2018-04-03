# about:  set software versions, paths and homogenous settings ( i.e non server.json settings)




# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

## [1] capitalised sub-folder of POD_SOFTWARE where is stored the tarball - e.g. DATASTAX, JAVA ...

# leave empty if pod does not require sending a tarball !
PACKAGE=""

# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
source ${pod_home_path}/misc/.suitcase
POD_SOFTWARE="${TARGET_FOLDER}POD_SOFTWARE/"
PACKAGES="${POD_SOFTWARE}${PACKAGE}/"
INSTALL_FOLDER="${TARGET_FOLDER}POD_INSTALLS/"
INSTALL_FOLDER_POD="${INSTALL_FOLDER}pod/${WHICH_POD}/"
# //////////////////////////////////////////




# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# EDIT-THIS-BLOCK !!

## General settings

# [1.1] DSE version to configure
DSE_VERSION="dse-5.1.5"

# [1.2] pod_DSE build folder to configure
pod_DSE_build_folder="dse-5.1.5_opscenter"

# [1.3] name to give 'application' key used for encrypting non-system tables
application_key_name="ob_key"

# [1.4] name to give 'system' key used for encrypting system tables
system_key_flag="true"

# -----

## dse.yaml

## [2.1] location of system + 'application' encryption keys
system_key_directory="/etc/jondowson/Desktop/key/"

## [2.2] transparent data encryption settings
tde_system_info_enabled="true"
tde_cipher_algorithm="AES"
tde_secret_key_strength="256"
tde_chunk_length_kb="64"

## [2.3] audit_logging
audit_logging_enabled="true"
audit_logging_included_categories="DML,DDL,DCL,AUTH,ADMIN,ERROR"
audit_logging_included_keyspaces="acme_accounts,acme_payauth,acme_paysub"

# -----

## cassandra.yaml

## [3.1] server_encryption_options - empty settings will be left commented out !
se_internode_encryption="all"
se_keystore="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/etc/dse/conf/acme.keystore.jks"
se_keystore_password="changeme"
se_truststore="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/etc/dse/conf/acme.truststore.jks"
se_truststore_password="changeme"
# More advanced defaults below:
se_protocol=""
se_algorithm=""
se_store_type=""
se_cipher_suites="[TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]"
se_require_client_auth="true"
se_require_endpoint_verification=""

# note: this commented out block shows the default server_encryption_options !!

# server_encryption_options:
#  internode_encryption: none
#  keystore: resources/dse/conf/.keystore
#  keystore_password: cassandra
#  truststore: resources/dse/conf/.truststore
#  truststore_password: cassandra
# More advanced defaults below:
#  protocol: TLS
#  algorithm: SunX509
#  store_type: JKS
#  cipher_suites: [TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]
#  require_client_auth: false
#  require_endpoint_verification: false

# -----

## [3.2] client encryption options - empty settings will be left commented out !
ce_enabled="false"
ce_optional="false"
ce_keystore="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/etc/dse/conf/acme.keystore.jks"
ce_keystore_password="changeit"
ce_require_client_auth="false"
ce_truststore="${INSTALL_FOLDER_POD}${BUILD_FOLDER}/etc/dse/conf/acme.keystore.jks"
ce_truststore_password="changeit"
# More advanced defaults below:
ce_protocol=""
ce_algorithm=""
ce_store_type=""
ce_cipher_suites=""

# note: this commented out block shows the default client/server encryption options !!

#client_encryption_options:
# enabled: false
# If enabled and optional is set to true, encrypted and unencrypted connections over native transport are handled.
# optional: false
# keystore: resources/dse/conf/.keystore
# keystore_password: cassandra
# require_client_auth: false
# Set trustore and truststore_password if require_client_auth is true
# truststore: resources/dse/conf/.truststore
# truststore_password: cassandra
# More advanced defaults below:
# protocol: TLS
# algorithm: SunX509
# store_type: JKS
# cipher_suites: [TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]

# -----

## [3.3] enable JMX authentication for clients such as nodetool - this enables remote connection, otherwise restricted to localhost
# set LOCAL_JMX to anything other than null to enable authentication
LOCAL_JMX="yes"
# set these JVM_OPTS to enable ssl
jmxremote.ssl="true"
jmxremote.ssl.need.client.auth="true"
jmxremote.ssl.enabled.protocols="<enabled-protocols>"
jmxremote.ssl.enabled.cipher.suites="<enabled-cipher-suites>"
net.ssl.keyStore="/path/to/keystore"
net.ssl.keyStorePassword="<keystore-password>"
net.ssl.trustStore="/path/to/truststore"
net.ssl.trustStorePassword="<truststore-password>"

# block taken from cassandra-env.sh
#  if [ "$LOCAL_JMX" = "yes" ]; then
#    JVM_OPTS="$JVM_OPTS -Dcassandra.jmx.local.port=$JMX_PORT"
#    JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
#  else
#    JVM_OPTS="$JVM_OPTS -Dcassandra.jmx.remote.port=$JMX_PORT"
# if ssl is enabled the same port cannot be used for both jmx and rmi so either
# pick another value for this property or comment out to use a random port (though see CASSANDRA-7087 for origins)
#    JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.rmi.port=$JMX_PORT"

# turn on JMX authentication. See below for further options
#    JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=true"

# jmx ssl options
#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=true"
#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.need.client.auth=true"
#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.protocols=<enabled-protocols>"
#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.cipher.suites=<enabled-cipher-suites>"
#JVM_OPTS="$JVM_OPTS -Djavax.net.ssl.keyStore=/path/to/keystore"
#JVM_OPTS="$JVM_OPTS -Djavax.net.ssl.keyStorePassword=<keystore-password>"
#JVM_OPTS="$JVM_OPTS -Djavax.net.ssl.trustStore=/path/to/truststore"
#JVM_OPTS="$JVM_OPTS -Djavax.net.ssl.trustStorePassword=<truststore-password>"
#  fi

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



# //////////////////////////////////////////
# DO-NOT-EDIT-THIS-BLOCK !!
dse_config_folder="${INSTALL_FOLDER}pod_DSE/${pod_DSE_build_folder}/${DSE_VERSION}/resources/"
config_folder_dseYaml="${dse_config_folder}dse/conf/"
config_folder_cassandraYaml="${dse_config_folder}cassandra/conf/"
# //////////////////////////////////////////
