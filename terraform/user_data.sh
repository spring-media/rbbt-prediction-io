#!/usr/bin/env bash
set -x

yum --assumeyes install git docker
service docker start
curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
PATH=$PATH:/usr/local/bin
echo 'PATH=$PATH:/usr/local/bin' >> ~/.bashrc

usermod -aG docker ec2-user

[[ -e /opt/prediction-io ]] || git clone https://github.com/spring-media/rbbt-prediction-io.git /opt/prediction-io
eval $(aws ecr get-login --region eu-west-1 --no-include-email)
docker-compose --file /opt/prediction-io/docker-compose.prod.yml up --build