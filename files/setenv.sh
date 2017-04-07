#!/bin/sh

CATALINA_HOME="/opt/tomcat"
export CATALINA_HOME

CATALINA_BASE=$CATALINA_HOME
export CATALINA_BASE

JAVA_HOME="/usr/lib/jvm/java-8-oracle"
export JAVA_HOME

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CATALINA_HOME/lib
export LD_LIBRARY_PATH

NORMAL="-server -d64 -Xms${XMS_SIZE} -Xmx${XMX_SIZE}"
# MAX_PERM_GEN="-XX:MaxPermSize=256m"
HEAP_DUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEADLESS="-Djava.awt.headless=true"

JAVA_OPTS="$JAVA_OPTS $NORMAL $HEAP_DUMP $HEADLESS"
export JAVA_OPTS
