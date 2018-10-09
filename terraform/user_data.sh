#!/usr/bin/env bash
set -x

yum --assumeyes install git docker

[[ -e /home/ubuntu/prediction-io ]] || git clone https://github.com/spring-media/rbbt-prediction-io.git /home/ubuntu/prediction-io
chown -R ubuntu:ubuntu /home/ubuntu
eval $(aws ecr get-login --region eu-west-1 --no-include-email)
docker-compose --file /home/ubuntu/prediction-io/docker-compose.prod.yml up --build