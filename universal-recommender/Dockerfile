FROM pio:pio-latest

RUN apt-get update \
    && apt-get install -y --auto-remove --no-install-recommends python3-setuptools python3-pip git-core vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install predictionio datetime

RUN git clone https://github.com/actionml/universal-recommender.git /root/ur
RUN cd /root/ur && pio build --clean
COPY files/engine.json /root/ur/engine.json
COPY files/run.sh /root/run.sh

RUN chmod a+x /root/run.sh
WORKDIR /root

EXPOSE 8000
CMD [ "./run.sh" ]