# REVISION = $(shell git rev-parse --short=8 HEAD)

docker_build:
	docker build -t pio:pio-latest pio/
	docker tag pio:pio-latest 933782373565.dkr.ecr.eu-west-1.amazonaws.com/pio:pio-latest
	docker build -t pio:ur-latest universal-recommender/
	docker tag pio:ur-latest 933782373565.dkr.ecr.eu-west-1.amazonaws.com/ur:ur-latest

docker_push: docker_build
	docker push 933782373565.dkr.ecr.eu-west-1.amazonaws.com/pio:pio-latest
	docker push 933782373565.dkr.ecr.eu-west-1.amazonaws.com/pio:ur-latest