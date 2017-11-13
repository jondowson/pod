# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ "x$CASSANDRA_HOME" = "x" ]; then
    CASSANDRA_HOME="`dirname $0`/../.."
fi

# The directory where Cassandra's configs live (required)
if [ "x$CASSANDRA_CONF" = "x" ]; then
    CASSANDRA_CONF="$CASSANDRA_HOME/conf"
fi
# Construct jar folders to use
CASSANDRA_JARS="$CASSANDRA_HOME"/lib
DSE_JARS="$CASSANDRA_HOME"/../../lib
TOOLS_JARS=

# Customization for package installs. This keeps this script compatible
# with the old style directory strucure.
if [ -d /etc/dse/cassandra ]; then
    CASSANDRA_CONF=/etc/dse/cassandra
    CASSANDRA_JARS=/usr/share/dse/common
    DSE_JARS=/usr/share/dse
fi

# Add tools jars if we are inside the tools directory
if [ -d "../../tools" ]; then
    TOOLS_JARS="../lib"
fi


# This can be the path to a jar file, or a directory containing the
# compiled classes. NOTE: This isn't needed by the startup script,
# it's just used here in constructing the classpath.
cassandra_bin="$CASSANDRA_HOME/build/classes/main"
cassandra_bin="$cassandra_bin:$CASSANDRA_HOME/build/classes/stress"
cassandra_bin="$cassandra_bin:$CASSANDRA_HOME/build/classes/thrift"
#cassandra_bin="$cassandra_home/build/cassandra.jar"

# the default location for commitlogs, sstables, and saved caches
# if not set in cassandra.yaml
cassandra_storagedir="$CASSANDRA_HOME/data"

# JAVA_HOME can optionally be set here
#JAVA_HOME=/usr/local/jdk6

# The java classpath (required)
if [ "$cassandra_bin" != "" ]; then
    CLASSPATH="$CLASSPATH:$CASSANDRA_CONF:$cassandra_bin"
else
    CLASSPATH="$CLASSPATH:$CASSANDRA_CONF"
fi

# Add tools jars
if [ "$TOOLS_JARS" != "" ]; then
    for jar in "$TOOLS_JARS"/*.jar; do
        CLASSPATH="$CLASSPATH:$jar"
    done
fi

for jar in "$CASSANDRA_JARS"/*.jar; do
    CLASSPATH="$CLASSPATH:$jar"
done

