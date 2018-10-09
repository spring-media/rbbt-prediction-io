#!/usr/bin/env bash
set -euxo pipefail

source ./conf/pio-env.sh

find ./vendors -name "hbase-site.xml" -exec sed -i "s|HBASE_HOST|$HBASE_HOST|;s|HBASE_PORT|$HBASE_PORT|" {} \;

PIO_APP_NAME="welt_pio"
PIO_TRAINING_ARGS=""
pushd ~/ur

sed -i "s|VAR_APP_NAME|$PIO_APP_NAME|;s|VAR_ES_HOST|$ES_HOST|;s|VAR_ES_PORT|$ES_PORT|" engine.json
if [ "$ES_SCHEME" == "https" ]; then
    sed -i '/sparkConf/ a\
    "es.net.ssl": "true", ' engine.json
    PIO_TRAINING_ARGS="--conf spark.es.nodes.wan.only=true"
fi

# still in debug mode
# echo 'debug-sleep'
# sleep 2073600

pio status
pio app new $PIO_APP_NAME || true
pio app show $PIO_APP_NAME
pio build --clean
pio train -- --driver-memory 4g --executor-memory 4g $PIO_TRAINING_ARGS

pio deploy --event-server-ip pio