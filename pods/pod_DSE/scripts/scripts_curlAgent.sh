#!/bin/bash

pub_ip=${1}

url=http://${pub_ip}:61621/v1/connection-status
head=true
while IFS= read -r line; do
  if $head; then
    if [[ -z $line ]]; then
      head=false
    else
      headers+=("$line")
    fi
  else
    body+=("$line")
  fi
done < <(curl -sD - "$url" | sed 's/\r$//')
unset IFS
runningVersion=$(printf "%s\n" "${headers[@]}" | grep X-Datastax-Agent-Version)
runningVersion=$(echo "${runningVersion#*:}" | tr -d [:space:])
printf "%s\n" "${runningVersion}"
