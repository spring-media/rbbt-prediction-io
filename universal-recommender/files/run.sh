#!/usr/bin/env bash
set -euxo pipefail

function train {
    echo "Training engine."    
    pio train -- --driver-memory 4g --executor-memory 4g $PIO_TRAINING_ARGS
}

function deploy {
    echo "Deploying engine."
    pio deploy --event-server-ip pio
}

source $PIO_HOME/conf/pio-env.sh

sed -i "s|HBASE_HOST|${HBASE_HOST}|g;s|HBASE_PORT|${HBASE_PORT}|g" $HBASE_CONF_DIR/hbase-site.xml
sed -i "s|HDFS_HOST|${HDFS_HOST}|g;s|HDFS_PORT|${HDFS_PORT}|g" $HADOOP_CONF_DIR/core-site.xml

PIO_APP_NAME="welt_pio"
PIO_TRAINING_ARGS=""
pushd ~/ur

sed -i "s|VAR_APP_NAME|$PIO_APP_NAME|;s|VAR_ES_HOST|$ES_HOST|;s|VAR_ES_PORT|$ES_PORT|" engine.json
if [ "$ES_SCHEME" == "https" ]; then
    sed -i '/sparkConf/ a\
    "es.net.ssl": "true", ' engine.json
    PIO_TRAINING_ARGS="--conf spark.es.nodes.wan.only=true"
fi

pio status
pio app new $PIO_APP_NAME || true
pio app show $PIO_APP_NAME

echo "RUN_MODE == $RUN_MODE"
case $RUN_MODE in
    "TRAIN_ONLY")
        train
        echo "TRAIN_ONLY -> Finished. Exiting now."
        exit 0
        ;;
    "DEPLOY_ONLY")
        deploy
        ;;
    *)
        train
        deploy
        ;;
esac
