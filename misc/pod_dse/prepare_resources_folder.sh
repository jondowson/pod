#!/bin/bash

# script_name:   prepare_resources_folder.sh
# author:        jondowson
# about:         prepare dse 'resources' folder by removing all non-configuration files

#--------------------------------------------

## uncomment to see full bash trace (debug)
# set -x

#--------------------------------------------

## passed in parameters

# setup_dse config folder to copy stripped resources folder to
_CONFIG_FOLDER="${1}"

# optional display setting
if [ -z "$2" ]; then
  _STAGE_PAUSE="10"
else
  _STAGE_PAUSE="${2}"
fi

#--------------------------------------------

## determine this scripts' folder path

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
podSetupFolder="$(cd ../; pwd)/"
thisScript=$(printf "%s" `basename "$0"`)

#--------------------------------------------

## source other scripts

# source lib folder scripts - don't bother sourcing dependencies_mac.sh script
files="$(find ../lib -name "*.sh*" | grep -v  "dependencies_mac.sh")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

#-------------------------------------------

## source the config settings folder to use

# folder specified at top of this script
config_file_folder="${podSetupFolder}configs/setup_dse/${_CONFIG_FOLDER}/"
config_file_path="${config_file_folder}cluster_settings.sh"
if [[ -f ${config_file_path} ]]; then
  source ${config_file_path}
else
  generic_file_exists_check_abort "${config_file_path}"
fi

#-------------------------------------------

## assign paths to variables

destination_folder_parent_path="${podSetupFolder}configs/setup_dse/${_CONFIG_FOLDER}/"
destination_folder_path="${destination_folder_parent_path}resources/"
source_folder_path="${podSetupFolder}tmp/${DSE_VERSION}/resources/"

#-------------------------------------------

## checks to see folder paths exist

generic_folder_exists_check_abort ${destination_folder_parent_path}

#-------------------------------------------

## copy resources folder from dse package to dse-setup

banner
generic_msg_colour_simple "title" "Preparing 'resources' folder"

if [ -d "${destination_folder_path}" ]; then
  generic_msg_colour_simple "info-indented" "Existing ${yellow}'${_CONFIG_FOLDER}/resources'${white} will be deleted"
  printf "%s\n"
  generic_msg_colour_simple "alert" "Are you sure ?"
  printf "%s\n"
  generic_timecount "${_STAGE_PAUSE}" "<ctrl-c> to abort now.."
  rm -rf ${destination_folder_path}
  banner
  generic_msg_colour_simple "title" "Preparing 'resources' folder"
fi

generic_msg_colour_simple "info" "Unzip from:   ${red}${dse_tar_file}${reset}"
generic_msg_colour_simple "info" "Unzip to:     ${yellow}${source_folder_path}${reset}"
printf "%s\n"
generic_msg_colour_simple "alert" "Strip files from 'resources' folder"
mkdir -p "${podSetupFolder}tmp"
tar -xf "${dse_tar_file}" -C "${podSetupFolder}tmp/"

#-------------------------------------------

## declare file extensions to remove in an array

declare -a array_file_extensions_to_strip
array_file_extensions_to_strip[0]="zip"
array_file_extensions_to_strip[1]="gz"
array_file_extensions_to_strip[2]="jar"
array_file_extensions_to_strip[3]="jar.*"
array_file_extensions_to_strip[4]="md"
array_file_extensions_to_strip[5]="so.*"
array_file_extensions_to_strip[6]="so"
array_file_extensions_to_strip[7]="js"
array_file_extensions_to_strip[8]="a"
array_file_extensions_to_strip[9]="py"
array_file_extensions_to_strip[10]="R"
array_file_extensions_to_strip[11]="rds"
array_file_extensions_to_strip[12]="rdx"
array_file_extensions_to_strip[13]="rdb"
array_file_extensions_to_strip[14]="sl"
array_file_extensions_to_strip[15]="dylib"
array_file_extensions_to_strip[16]="dll"
array_file_extensions_to_strip[17]="txt"
array_file_extensions_to_strip[18]="data"
array_file_extensions_to_strip[19]="html"
array_file_extensions_to_strip[20]="css"
array_file_extensions_to_strip[21]="csv"
array_file_extensions_to_strip[22]="png"
array_file_extensions_to_strip[23]="gif"
array_file_extensions_to_strip[24]="svg"
array_file_extensions_to_strip[25]="jsp"
array_file_extensions_to_strip[26]="kryo"

#-------------------------------------------

## display stats on removed files

printf "%s\n"
printf "%s\t%s\t%s\t%s\t%s\n" "${b}Extension" "|" "No." "|" "Bytes${reset}"
printf "%s\n" "--------------------------------------------------"

before_size=$(du -sh ${source_folder_path} | awk '{ print $1 }')

for i in "${array_file_extensions_to_strip[@]}"
do
  amount=$(find ${source_folder_path} -name "*.${i}" -type f -print | wc -l)
  size=$(find ${source_folder_path} -name "*.${i}" -type f -print | xargs wc -c | awk 'END { print $1 }')
  printf "%s\t\t%s\t%s\t%s\t%s\n" "${yellow}*.${i}${reset}" "|" "${amount}" "|" "${size}"
  find ${source_folder_path} -name "*.${i}" -type f -delete
done

printf "%s\n" "--------------------------------------------------"
printf "%s\t\t\t%s\n"   "${b}Folder size before:" "${before_size}"
printf "%s\t\t\t%s\n\n" "${b}Folder size after:"  "$(du -sh ${source_folder_path} | awk '{ print $1 }')${reset}"

#-------------------------------------------

## copy source folder to destination folder
generic_msg_colour_simple "alert" "Move stripped 'resources' folder to 'dse-setup'"
printf "%s\n"
generic_msg_colour_simple "info" "move from:    ${yellow}${source_folder_path}${reset}"
generic_msg_colour_simple "info" "move to:      ${green}${destination_folder_path}${reset}"
printf "%s\n"
cp -R ${source_folder_path} ${destination_folder_path}
rm -rf "${podSetupFolder}tmp/"
generic_timecount "${_STAGE_PAUSE}" "Proceeding to next stage..."
