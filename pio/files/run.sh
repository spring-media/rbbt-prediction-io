#!/usr/bin/env bash
set -euox pipefail

source $PIO_HOME/conf/pio-env.sh

sed -i "s|HBASE_HOST|${HBASE_HOST}|g;s|HBASE_PORT|${HBASE_PORT}|g" $HBASE_CONF_DIR/hbase-site.xml
sed -i "s|HDFS_HOST|${HDFS_HOST}|g;s|HDFS_PORT|${HDFS_PORT}|g" $HADOOP_CONF_DIR/core-site.xml

pio eventserver --ip 0.0.0.0 --port 7070
