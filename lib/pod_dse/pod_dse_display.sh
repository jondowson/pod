#!/bin/bash

# script_name:  pod_dse_display.sh
# author:       jondowson
# about:        pod_dse specific terminal output 

#-------------------------------------------

function pod_dse_display_banner(){

clear
printf "%s"  "${b}${cyan}"
cat << "EOF"
                     __    _  _ 
    ____  ____  ____/ /  _(_)(_)_  
   / __ \/ __ \/ __  /  (_)    (_)
  / /_/ / /_/ / /_/ /   (_)_  _(_)
 / .___/\____/\__,_/      (_)(_) 
/_/                                                                                    
EOF
printf "%s\n"  "${reset}"
}

# ---------------------------------------

function pod_dse_display_finalMessage(){

## at the end of each pod - display a message

which_pod="${1}"

case ${which_pod} in

    "pod_dse" )
        if [[ ${os} == "Mac" ]] || [[ ${JAVA_INSTALL_TYPE} != "tar" ]]; then
          pod_generic_display_msgColourSimple "title"     "Final tasks to complete pod"
          pod_generic_display_msgColourSimple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
          pod_generic_display_msgColourSimple "info"      "$ . ~/.bash_profile"
          pod_generic_display_msgColourSimple "info-bold" "(b) Run dse:"
          pod_generic_display_msgColourSimple "info"      "$ dse cassandra            # start dse storage"
          pod_generic_display_msgColourSimple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
        elif [[ "${JAVA_INSTALL_TYPE}" == "tar" ]]; then
          pod_generic_display_msgColourSimple "title"     "Final tasks to complete pod"
          pod_generic_display_msgColourSimple "info-bold" "(a) Source '.bash_profile' (or open new terminal):"
          pod_generic_display_msgColourSimple "info"      "$ . ~/.bash_profile"
          pod_generic_display_msgColourSimple "info-bold" "(b) Add java tar to system java alternatives - you may have to alter yellow portion of path:"
          pod_generic_display_msgColourSimple "info"      "$ sudo update-alternatives --install /usr/bin/java java ${yellow}${java_untar_folder}${white}${JAVA_VERSION}/bin/java 100"
          pod_generic_display_msgColourSimple "info-bold" "(c) Select this java tar from list:"
          pod_generic_display_msgColourSimple "info"      "$ sudo update-alternatives --config java"
          pod_generic_display_msgColourSimple "info-bold" "(d) Run dse:"
          pod_generic_display_msgColourSimple "info"      "$ dse cassandra            # start dse storage"
          pod_generic_display_msgColourSimple "info"      "$ dse cassandra -s -k -g   # start dse storage with search, analytics, graph (pick any combination)"
        fi
        printf "%s\n" ;; 
    "pod_security" )
      pod_generic_display_msgColourSimple "title"     "Final tasks to complete pod"
      pod_generic_display_msgColourSimple "info-bold" "Security blah blah blah" ;;

esac
}  
