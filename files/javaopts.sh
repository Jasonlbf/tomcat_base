#!/bin/sh

NORMAL="-server -d64 -Xms5G -Xmx5G"
# MAX_PERM_GEN="-XX:MaxPermSize=256m"
HEAP_DUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEADLESS="-Djava.awt.headless=true"

JAVA_OPTS="$JAVA_OPTS $NORMAL $HEAP_DUMP $HEADLESS"
export JAVA_OPTS
