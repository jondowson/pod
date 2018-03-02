# about:  miscellaneous generic bash functions

# ---------------------------------------

function lib_generic_misc_chooseOsCommand(){

## dynamically choose command based on the OS
# e.g. generic_dynamic_os_command "gsed -i" "sed -i" "sed -i" "sed -i"

mac_cmd=${1}
ubuntu_cmd=${2}
centos_cmd=${3}
redhat_cmd=${4}

if [[ "${os}" == "Mac" ]];then
  printf "%s" /usr/local/bin/${mac_cmd}
elif [[ "${os}" == "Ubuntu" ]];then
  printf "%s" ${ubuntu_cmd}
elif [[ "${os}" == "Centos" ]];then
  printf "%s" ${centos_cmd}
elif [[ "${os}" == "Redhat" ]];then
  printf "%s" ${redhat_cmd}
else
  prepare_generic_display_msgColourSimple "ERROR-->" "lib_generic_misc.bash | generic_dynamic_os_command --> 'Unsupported OS'"
  exit 1;
fi
}

# ---------------------------------------

function lib_generic_misc_timestamp(){

# generate a timestamp
date +%F_%T
}

# ---------------------------------------

function lib_generic_misc_timecount(){
min=0
sec=${1}
message=${2}
printf "%s\n" "${2}"
while [ $min -ge 0 ]; do
      while [[ $sec -ge 0 ]]; do
          echo -ne "00:0$min:$sec\033[0K\r"
          sec=$((sec-1))
          sleep 1
      done
      sec=59
      min=$((min-1))
done
}

# ---------------------------------------

function lib_generic_misc_timePod(){

## calculate pod runtime

pod_end=$(date +%s)
diff=$((pod_end - script_start))
}
