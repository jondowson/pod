#!/bin/bash

# author:        jondowson
# about:         help on pod usage and flags

# ------------------------------------------

function pod_generic_help_pod(){

pod_generic_display_msgColourSimple "STAGE" "pod help:"
printf "%s\n"    
printf "%s%s%s\n" "${b}" "description                              | flag                 | required?  | values[default]" "${reset}"
printf "%s\n"            "--------------------------------------------------------------------------------------------"
printf "%s\n\n"          "${b}${cyan}==> pod flags:${reset}"
printf "%s\n"            ".. help                                  | -h  --help           |    no      |     n/a"
printf "%s\n"            ".. specify pod to run                    | -p  --pod            |   always   |  <pod_name>"
printf "%s\n"            "--------------------------------------------------------------------------------------------"
printf "%s\n"            "${b}${cyan}==> pod_dse flags:${reset}"
printf "%s\n"
printf "%s\n"            ".. specify server .json defintions       | -s  --servers        |    yes     |  <server_json>"
printf "%s\n"            ".. specify build folder                  | -b  --build          |    yes     |  <build_folder>"
printf "%s\n"            ".. scp DSE_SOFTWARE folder to servers    | -ss --sendsoft       |    no      |  false [true]"
printf "%s\n"            ".. re-generate build resources folder    | -rr --regenresources |    no      |  true  [false]"
printf "%s\n"            ".. rolling stop/start of cluster         | -cs --clusterstate   | on-its-own |  start stop"
printf "%s\n"
printf "%s\n"            "${b}examples:${reset}"
printf "%s\n"            "--------------------------------------------------------------------------------------------"
printf "%s\n"            "$ ./launch-pod ${cyan}-p pod_dse ${reset}-s myServers.json ${cyan}-b dse-5.0.5_pre-prod ${reset}-ss false ${cyan}--rr true${reset}"
printf "%s\n"            "$ ${cyan}./launch-pod ${reset}-p pod_dse ${cyan}--servers myServers.json ${reset}--clusterstate start"
printf "%s\n"            "--------------------------------------------------------------------------------------------"
pod_generic_display_msgColourSimple "TASK" "Available pods:"
availablePods=$(ls ${pod_home_path}/pods | cut -f 1 -d '.')
printf "%s\n" ${availablePods}
pod_generic_display_msgColourSimple "TASK" "Available server definitions:"
ls ${pod_home_path}/servers
pod_generic_display_msgColourSimple "TASK" "Available builds:"
ls ${pod_home_path}/builds/pod_dse
printf "%s\n"
}
