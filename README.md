# PredictionIO docker-compose

Docker container for PredictionIO-based machine learning services

[PredictionIO](https://prediction.io) is an open-source Machine Learning
server for developers and data scientists to build and deploy predictive
applications in a fraction of the time.

This container uses Apache Spark, HBase and Elasticsearch.

Credits go to: https://github.com/sphereio/docker-predictionio for providing inspiration on how to dockerize prediction io.

## Architecture

todo

## Dev

```Bash
docker-compose up
```

starts up the following containers (also see [docker-compose.yml](docker-compose.yml) for `ports`/`networks`/`mounts` used):

- `es` ⇢ Elasticsearch
- `hbase` ⇢ Hbase and Zookeeper
- `pio` ⇢ the PredictionIO event server
- `ur` ⇢ the Universal Recommender

Test the `pio` containers health endpoint:

```Bash
$ curl -i http://localhost:7070

HTTP/1.1 200 OK
Server: spray-can/1.3.3
Date: Fri, 28 Sep 2018 13:33:53 GMT
Content-Type: application/json; charset=UTF-8
Content-Length: 18
{"status":"alive"}
```

Then ssh into the `ur` container:

```Bash
docker exec -it `docker ps | grep _ur | awk '{print $1}'` bash
```

The Universal Recommender will available at `~/ur`; for starters run the [integration tests](http://actionml.com/docs/ur_quickstart):

_Hint_: You may need to adapt the URL of the `pio` server and enable the elasticsearch wan in `examples/integration-test`:

    python3 examples/import_handmade.py --access_key $ACCESS_KEY --file data/sample-handmade-data.txt --url http://pio:7070
    ...
    pio train  -- --driver-memory 4g --executor-memory 4g --conf spark.es.nodes.wan.only=true

_Hint_: You may need to adapt the `examples/handmade-engine.json`; set `es.net.ssl` to `true` only if you're connecting through HTTPS:

        "es.nodes": "vpc-prediction-io-mlilctsisxnuweu5pu3qd36vny.eu-west-1.es.amazonaws.com",
        "es.port": "443",
        "es.net.ssl": "true"

```Bash
cd ~/ur
./examples/integration-test
```