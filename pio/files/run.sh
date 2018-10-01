#!/usr/bin/env bash
set -euox pipefail

source ./conf/pio-env.sh

find ./vendors -name "hbase-site.xml" -exec sed -i "s|HBASE_HOST|${HBASE_HOST}|g;s|HBASE_PORT|${HBASE_PORT}|g" {} \;

pio eventserver --ip 0.0.0.0 --port 7070