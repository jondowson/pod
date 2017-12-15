# author:        jondowson
# about:         functions required prior to running pod

# ------------------------------------------

function prepare_generic_misc_podBuildTempFolder(){

## prepare duplicate version of 'pod' project

# this requires an existing local resources folder
# note: it is this duplicate folder will be configured locally and then sent to remote server(s)

tmp_build_folder="${pod_home_path}/tmp/pod/" && \
tmp_builds_folder="${tmp_build_folder}pods/${WHICH_POD}/builds/" && \
tmp_build_file_folder="${tmp_builds_folder}${BUILD_FOLDER}/" && \
tmp_build_settings_file_path="${tmp_build_file_folder}build_settings.bash" && \
tmp_suitcase_file_path="${tmp_build_folder}misc/.suitcase" && \

# delete any existing duplicated 'pod' folder from '/tmp'
tmp_folder="${pod_home_path}/tmp/" && \
rm -rf "${tmp_folder}" && \

# duplicate 'pod' folder to working directory '/tmp'
tmp_working_folder="${pod_home_path}/tmp/pod/" && \
mkdir -p "${tmp_working_folder}" && \
cp -rp "${pod_home_path}/misc"         "${tmp_working_folder}" && \
cp -rp "${pod_home_path}/pods"         "${tmp_working_folder}" && \
cp -rp "${pod_home_path}/servers"      "${tmp_working_folder}" && \
cp -rp "${pod_home_path}/third_party"  "${tmp_working_folder}" && \
cp -p  "${pod_home_path}/README.md"    "${tmp_working_folder}" && \
cp -p  "${pod_home_path}/launch-pod"   "${tmp_working_folder}"
}

# ------------------------------------------

function prepare_generic_misc_identifyOs(){

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
  lib_generic_display_msgColourSimple "ERROR-->" "OS Not Supported"
  exit 1;
fi
}

# ------------------------------------------

function prepare_generic_misc_getPodPath(){

## determine the folder path of pod

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd ${parent_path}
cd ../../
pod_home_path="$(pwd)/"
}

# ------------------------------------------

function prepare_generic_misc_sourceGeneric(){

## source generic reusable pod scripts

files="$(find ${pod_home_path}/pods/pod_/ -name "*.bash*" -not -path "*scripts/*" | grep -v  "template_*" | grep -v  "lib_generic_prepare.bash")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done
}

# ------------------------------------------

function prepare_generic_misc_sourceThisPod(){

## source pod-specific lib scripts

# check pod exists
lib_generic_checks_folderExistsCaseSensitive "pod folder does not exist" "true" "${pod_home_path}/pods/" "${WHICH_POD}"

files="$(find ${pod_home_path}/pods/${WHICH_POD}/ -name "*.bash*" -not -path "*builds/*" -not -path "*scripts/*")"
for file in $(printf "%s\n" "$files"); do
    [ -f $file ] && . $file
done

}

# ------------------------------------------

function prepare_generic_misc_sourceThisPodBuild(){

# source the pod-specific 'builds' folder to use
if [[ ${buildFlag} == "true" ]]; then

  build_file_folder="${pod_home_path}/pods/${WHICH_POD}/builds/${BUILD_FOLDER}/"
  build_file_path="${build_file_folder}build_settings.bash"

  if [[ -f ${build_file_path} ]]; then
    source ${build_file_path}
  else
    lib_generic_checks_fileExists "build file path is wrong: ${build_file_path}" "true" "${build_file_path}"
  fi
fi
}

# ------------------------------------------

function prepare_generic_misc_setDefaults(){

## pod_DSE default settings

STAGE_PAUSE="5"      # pauses between STAGES
}

# ------------------------------------------

function prepare_generic_misc_clearTheDecks(){

## remove any temporary files/folders that may be left from a previous run of pod_DSE

> ${pod_home_path}/pods/pod_/.suitcase
rm -rf ${pod_home_path}/tmp
}
