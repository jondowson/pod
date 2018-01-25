# about:    non-generic functions executed on remote server

# if at all possible make generic functions and put them in
# 'pod_/lib/lib_generic_doStuff_remotely.bash'
# otherwise pod specific functions run remotely go here.

# ---------------------------------------

function lib_doStuff_remotely_installJavaSecurity(){

## install from local tar to the designated java folder

unzip ${java_security_zip_file} &>/dev/null
mv UnlimitedJCEPolicyJDK8/*.jar  ${UNTAR_FOLDER}${SOFTWARE_VERSION}/lib/security/
chmod 0644 ${UNTAR_FOLDER}${SOFTWARE_VERSION}/lib/security/*.jar
rm -rf UnlimitedJCEPolicyJDK8/
}
