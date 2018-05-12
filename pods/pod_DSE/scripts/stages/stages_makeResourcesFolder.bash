function task_makeResourcesFolder(){

## create a stripped resources folder containing all + only dse config files

# used by error message
taskFile="task_makeResourcesFolder"

# [1] assign paths to variables
destBuildFolderPath="${podHomePath}/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
destResourcesFolderPath="${destBuildFolderPath}resources/"
sourceResourcesFolderPath="${podHomePath}/tmp/${dse_version}/resources/"

# [2] check to see folder paths exist
GENERIC_lib_checks_folderExists "${taskFile}#1" "true" "${destBuildFolderPath}"

# [3] copy resources folder from dse package to dse-setup
if [ -d "${destResourcesFolderPath}" ]; then

  GENERIC_prepare_display_msgColourSimple "INFO-->" "Existing ${yellow}'${BUILD_FOLDER}/resources'${white} will be deleted"
  printf "%s\n"
  GENERIC_prepare_display_msgColourSimple "ALERT"   "Are you sure ?"
  printf "%s\n"
  GENERIC_lib_misc_timeCount "${STAGE_PAUSE}" "<ctrl-c> to abort now.."
  rm -rf ${destResourcesFolderPath}
  GENERIC_prepare_display_stageCount      "Prepare 'resources' Folder" "1" "7"
  GENERIC_prepare_display_msgColourSimple "TASK==>"  "TASK: Strip out all non config files"
fi

# [4] copy resources folder from dse package to pod_dse build folder
GENERIC_prepare_display_msgColourSimple "INFO" "Unpack from:   ${red}${DSE_FILE_TAR}${reset}"
GENERIC_prepare_display_msgColourSimple "INFO" "Unpack to:     ${yellow}${destResourcesFolderPath}${reset}"

# [5] make a tmp folder to store the full unzipped dse folder
mkdir -p "${podHomePath}/tmp"
tar -xf "${DSE_FILE_TAR}" -C "${podHomePath}/tmp/"


# [6] declare file extensions to remove into an array
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
array_file_extensions_to_strip[24]="jpg"
array_file_extensions_to_strip[25]="svg"
array_file_extensions_to_strip[26]="jsp"
array_file_extensions_to_strip[27]="kryo"
array_file_extensions_to_strip[28]="ico"
array_file_extensions_to_strip[29]="war"

# [7] display stats on removed files
printf "%s\n"
printf "%s\t%s\t%s\t\t%s\t%s\n" "${b}Extension" "|" "No." "|" "Bytes${reset}"
printf "%s\n" "--------------------------------------------------"
#sleep 5 # for the benefit of macs - otherwise file permission errors !!
before_size=$(du -sh "${sourceResourcesFolderPath}" | awk '{ print $1 }')

for i in "${array_file_extensions_to_strip[@]}"
do
  amount=$(find ${sourceResourcesFolderPath} -name "*.${i}" -type f -print | wc -l)
  size=$(find ${sourceResourcesFolderPath} -name "*.${i}" -type f -print | xargs wc -c | awk 'END { print $1 }')
  printf "%s\t\t%s\t%s\t%s\t%s\n" "${yellow}*.${i}${reset}" "|" "${amount}" "|" "${size}"
  find ${sourceResourcesFolderPath} -name "*.${i}" -type f -delete
done

printf "%s\n" "--------------------------------------------------"
printf "%s\t\t\t\t%s\n"   "${b}Folder size before:" "${before_size}"
printf "%s\t\t\t\t%s\n\n" "${b}Folder size after:"  "$(du -sh ${sourceResourcesFolderPath} | awk '{ print $1 }')${reset}"

# [8] copy source folder to destination folder
GENERIC_prepare_display_msgColourSimple "ALERT" "Move stripped 'resources' folder into the pod_DSE 'build' folder"
printf "%s\n"
GENERIC_prepare_display_msgColourSimple "INFO" "move from:    ${yellow}${sourceResourcesFolderPath}${reset}"
GENERIC_prepare_display_msgColourSimple "INFO" "move to:      ${green}${destResourcesFolderPath}${reset}"
printf "%s\n"
cp -rp ${sourceResourcesFolderPath} ${destResourcesFolderPath}

# [9] remove tmp file and recreate pod tmp folder
rm -rf "${podHomePath}tmp/"
GENERIC_prepare_misc_podBuildTempFolder
flagOne="true" # record that this stage was run
}
