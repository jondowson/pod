# about:         functions required prior to running pod

# ------------------------------------------

function GENERIC_prepare_misc_podBuildTempFolder(){

## GENERIC_prepare duplicate version of 'pod' project
# this requires an existing local resources folder
# it is this duplicate folder that will be configured locally and then sent to remote server(s)

SUITCASE_FILE_PATH="${podHomePath}/misc/.suitcase"
TMP_FOLDER_POD="${podHomePath}/tmp/pod/" && \
TMP_FOLDER_BUILDS="${TMP_FOLDER_POD}pods/${WHICH_POD}/builds/" && \
TMP_FOLDER_BUILDFILE="${TMP_FOLDER_BUILDS}${BUILD_FOLDER}/" && \
TMP_FILE_BUILDSETTINGS="${TMP_FOLDER_BUILDFILE}build_settings.bash" && \
TMP_FILE_SUITCASE="${TMP_FOLDER_POD}misc/.suitcase" && \

# delete any existing duplicated 'pod' folder from '/tmp'
tmp_folder="${podHomePath}/tmp/" && \
rm -rf "${tmp_folder}" && \

# duplicate 'pod' folder to working directory '/tmp'
mkdir -p "${TMP_FOLDER_POD}" && \
cp -rp "${podHomePath}/misc"         "${TMP_FOLDER_POD}" && \
cp -rp "${podHomePath}/pods"         "${TMP_FOLDER_POD}" && \
cp -rp "${podHomePath}/servers"      "${TMP_FOLDER_POD}" && \
cp -rp "${podHomePath}/third_party"  "${TMP_FOLDER_POD}" && \
cp -p  "${podHomePath}/README.md"    "${TMP_FOLDER_POD}" && \
cp -p  "${podHomePath}/CHANGE.md"    "${TMP_FOLDER_POD}" && \
cp -p  "${podHomePath}/.gitignore"   "${TMP_FOLDER_POD}" && \
cp -p  "${podHomePath}/pod"          "${TMP_FOLDER_POD}"

# check these paths have been created
GENERIC_lib_checks_fileExists   "GENERIC_prepare_misc.bash#1" "true" "${SUITCASE_FILE_PATH}"
GENERIC_lib_checks_fileExists   "GENERIC_prepare_misc.bash#2" "true" "${TMP_FILE_BUILDSETTINGS}"
}

# ------------------------------------------

function GENERIC_prepare_misc_identifyOs(){

## determine OS of this computer

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
  GENERIC_prepare_display_msgColourSimple "ERROR-->" "OS Not Supported"
  exit 1;
fi
}

# ------------------------------------------

function GENERIC_prepare_misc_getPodPath(){

## determine the folder path of pod

parentPath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parentPath}
cd ../../
podHomePath="$(pwd)/"
}

# ------------------------------------------

function GENERIC_prepare_misc_sourceGeneric(){

## source generic reusable pod scripts

files="$(find ${podHomePath}/pods/pod_/ -name "*.bash*" -not -path "*scripts/*" | grep -v  "template_*" | grep -v  "GENERIC_lib_prepare.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done
}

# ------------------------------------------

function GENERIC_prepare_misc_sourceThisPod(){

## source pod-specific lib scripts

# check pod exists
GENERIC_lib_checks_fileFolderExists "pod does not exist" "true" "${podHomePath}/pods/" "folder" "${WHICH_POD}"

files="$(find ${podHomePath}/pods/${WHICH_POD}/ -name "*.bash" -not -path "*builds/*" -not -path "*scripts/*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done
}

# ------------------------------------------

function GENERIC_prepare_misc_sourceThisPodBuild(){

## source the pod-specific 'builds' folder to use

if [[ ${buildFlag} == "true" ]]; then
  GENERIC_lib_checks_fileFolderExists "build file path is wrong:" "true" "${podHomePath}/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/" "file" "build_settings.bash"
  source  "${podHomePath}/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/build_settings.bash"
fi
}

# ------------------------------------------

function GENERIC_prepare_misc_clearTheDecks(){

## remove any temporary files/folders that may be left from a previous run of pod

> ${podHomePath}/misc/.suitcase
rm -rf ${podHomePath}/tmp
rm -rf ${podHomePath}/.suitcase
}

# ------------------------------------------

function GENERIC_prepare_misc_checkSoftwareExists(){

## test POD_SOFTWARE folder and software tar file are available

if [[ "${SEND_POD_SOFTWARE}" == "true" ]]; then
  GENERIC_lib_checks_folderExists "GENERIC_prepare_misc.bash#3" "true" "${POD_SOFTWARE}"
fi
}
