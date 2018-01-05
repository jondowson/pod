# about:    flag handling for this pod

# ------------------------------------------

function prepare_handleFlags(){

flag=${1}
value=${2}

while test $# -gt 0; do
  case "$flag" in
    -s|--servers)
        SERVERS_JSON=$value
        serversFlag="true"
        break
        ;;
    -b|--build)
        BUILD_FOLDER=$value
        buildFlag="true"
        break
        ;;
    -ss|--sendsoft)
        SEND_POD_SOFTWARE=$value
        sendsoftFlag="true"
        break
        ;;
    *)
      printf "%s\n"
      lib_generic_display_msgColourSimple "ERROR-->" "Not a recognised flag ${yellow}${1}${red}"
      exit 1;
        ;;
  esac
done
}
