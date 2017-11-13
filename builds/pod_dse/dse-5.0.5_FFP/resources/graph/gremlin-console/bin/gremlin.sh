#!/bin/bash
#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

set -e
set -u

DIR="$( cd -P "$( dirname "$0" )" && pwd )"
SYSTEM_EXT_DIR="${DIR}/../ext"
JAVA_OPTIONS=${JAVA_OPTIONS:-}

if [ ! -z "${JAVA_OPTIONS}" ]; then
  USER_EXT_DIR=$(grep -o '\-Dtinkerpop.ext=\(\([^"][^ ]*\)\|\("[^"]*"\)\)' <<< "${JAVA_OPTIONS}" | cut -f2 -d '=' | xargs -0 echo)
  if [ ! -z "${USER_EXT_DIR}" -a ! -d "${USER_EXT_DIR}" ]; then
    mkdir -p "${USER_EXT_DIR}"
    cp -R ${SYSTEM_EXT_DIR}/* ${USER_EXT_DIR}/
  fi
fi

if [ -z ${GREMLIN_CONSOLE_CONF_DIR+x} ]; then
    for dir in "`dirname $0`/../conf" \
               "/etc/dse/graph/gremlin-console/conf"; do
        if [ -r "$dir/remote.yaml" ]; then
            export GREMLIN_CONSOLE_CONF_DIR="$dir"
            break
        fi
    done
    if [ -z ${GREMLIN_CONSOLE_CONF_DIR+x} ]; then
        echo "Could not found a valid configuration folder"
        exit 1
    fi
fi

CP="$GREMLIN_CONSOLE_CONF_DIR"
CP="$CP":$( echo `dirname $0`/../lib/*.jar . | sed 's/ /:/g')

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

CP=$CP:$( find -L "${SYSTEM_EXT_DIR}" "${USER_EXT_DIR:-${SYSTEM_EXT_DIR}}" -mindepth 1 -maxdepth 1 -type d | \
          sort -u | sed 's/$/\/plugin\/*/' | tr '\n' ':' )

export CLASSPATH="${CLASSPATH:-}:$CP"

# Find Java
if [ -z "${JAVA_HOME:-}" ]; then
    JAVA="java -server"
else
    JAVA="$JAVA_HOME/bin/java -server"
fi

# Script debugging is disabled by default, but can be enabled with -l
# TRACE or -l DEBUG or enabled by exporting
# SCRIPT_DEBUG=nonemptystring to gremlin.sh's environment
if [ -z "${SCRIPT_DEBUG:-}" ]; then
    SCRIPT_DEBUG=
fi

# Process options
MAIN_CLASS=org.apache.tinkerpop.gremlin.console.Console
while getopts "elv" opt; do
    case "$opt" in
    e) MAIN_CLASS=org.apache.tinkerpop.gremlin.groovy.jsr223.ScriptExecutor
       # For compatibility with behavior pre-Titan-0.5.0, stop
       # processing gremlin.sh arguments as soon as the -e switch is
       # seen; everything following -e becomes arguments to the
       # ScriptExecutor main class
       break;;
    l) eval GREMLIN_LOG_LEVEL=\$$OPTIND
       OPTIND="$(( $OPTIND + 1 ))"
       if [ "$GREMLIN_LOG_LEVEL" = "TRACE" -o \
            "$GREMLIN_LOG_LEVEL" = "DEBUG" ]; then
	   SCRIPT_DEBUG=y
       fi
       ;;
    v) MAIN_CLASS=org.apache.tinkerpop.gremlin.util.Gremlin
    esac
done

# Remove processed options from $@. Anything after -e is preserved by the break;; in the case
shift $(( $OPTIND - 1 ))

JAVA_OPTIONS="${JAVA_OPTIONS} -Dtinkerpop.ext=${USER_EXT_DIR:-${SYSTEM_EXT_DIR}} -Dlogback.configurationFile=logback-tools.xml"

if [ -n "${GREMLIN_LOG_LEVEL:-}" ]; then
    JAVA_OPTIONS="$JAVA_OPTIONS -Dlogback.root.level=$GREMLIN_LOG_LEVEL"
fi

JAVA_OPTIONS=$(awk -v RS=' ' '!/^$/ {if (!x[$0]++) print}' <<< "${JAVA_OPTIONS}" | grep -v '^$' | paste -sd ' ' -)

if [ -n "$SCRIPT_DEBUG" ]; then
    echo "JAVA_OPTIONS: $JAVA_OPTIONS"
    echo "CLASSPATH: $CLASSPATH"
    set -x
fi

# include the following in $JAVA_OPTIONS "-Divy.message.logger.level=4 -Dgroovy.grape.report.downloads=true" to debug :install

# Start the JVM, execute the application, and return its exit code
exec $JAVA $JAVA_OPTIONS $MAIN_CLASS scripts/dse-init.groovy "$@"
