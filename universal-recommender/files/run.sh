#!/usr/bin/env bash
set -euxo pipefail

PIO_APP_NAME="welt_pio"

pushd ~/ur

sed -i "s|VAR_APP_NAME|$PIO_APP_NAME|" engine.json

pio status
pio app new $PIO_APP_NAME || true
pio app show $PIO_APP_NAME
pio build --clean
pio train --verbose -- --driver-memory 4g --executor-memory 4g

pio deploy --event-server-ip pio