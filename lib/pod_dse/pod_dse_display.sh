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

 
