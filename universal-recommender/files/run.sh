#!/usr/bin/env bash
set -euxo pipefail

source ./conf/pio-env.sh

find ./vendors -name "hbase-site.xml" -exec sed -i "s|HBASE_HOST|${HBASE_HOST}|g;s|HBASE_PORT|${HBASE_PORT}|g" {} \;

PIO_APP_NAME="welt_pio"

pushd ~/ur

sed -i "s|VAR_APP_NAME|$PIO_APP_NAME|" engine.json

pio status
pio app new $PIO_APP_NAME || true
pio app show $PIO_APP_NAME
pio build --clean
pio train --verbose -- --driver-memory 4g --executor-memory 4g

pio deploy --event-server-ip pio