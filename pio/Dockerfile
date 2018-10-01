FROM ubuntu

RUN apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends curl openjdk-8-jdk libgfortran3 python-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

ENV SCALA_VERSION 2.11.8
ENV PIO_VERSION 0.13.0
ENV SPARK_VERSION 2.1.1
ENV ELASTICSEARCH_VERSION 5.5.2
ENV HBASE_VERSION 1.3.1

ENV PIO_HOME /PredictionIO-${PIO_VERSION}
ENV PATH=${PIO_HOME}/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

            
RUN curl -O http://ftp.fau.de/apache/predictionio/${PIO_VERSION}/apache-predictionio-${PIO_VERSION}.tar.gz \
    && tar zxvf apache-predictionio-${PIO_VERSION}.tar.gz -C / \
    && rm apache-predictionio-${PIO_VERSION}.tar.gz \
    && ./make-distribution.sh -Dscala.version=${SCALA_VERSION} -Dspark.version=${SPARK_VERSION} -Delasticsearch.version=${ELASTICSEARCH_VERSION}
RUN tar zxvf PredictionIO-${PIO_VERSION}.tar.gz

RUN mkdir -p ${PIO_HOME}/vendors

RUN curl -O https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz \
    && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop2.7.tgz -C ${PIO_HOME}/vendors \
    && rm spark-${SPARK_VERSION}-bin-hadoop2.7.tgz

RUN curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
    && tar -xvzf elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz -C ${PIO_HOME}/vendors \
    && rm elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
    && echo 'cluster.name: predictionio' >> ${PIO_HOME}/vendors/elasticsearch-${ELASTICSEARCH_VERSION}/config/elasticsearch.yml \
    && echo 'network.host: 127.0.0.1' >> ${PIO_HOME}/vendors/elasticsearch-${ELASTICSEARCH_VERSION}/config/elasticsearch.yml

RUN curl -O http://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
    && tar -xvzf hbase-${HBASE_VERSION}-bin.tar.gz -C ${PIO_HOME}/vendors \
    && rm hbase-${HBASE_VERSION}-bin.tar.gz

COPY files/hbase-site.xml ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/conf/hbase-site.xml
COPY files/run.sh ${PIO_HOME}/run.sh
COPY files/pio-env.sh ${PIO_HOME}/conf/pio-env.sh

WORKDIR ${PIO_HOME}
EXPOSE 7070
CMD [ "run.sh" ]