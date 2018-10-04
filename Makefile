# REVISION = $(shell git rev-parse --short=8 HEAD)

docker_build:
	docker build -t pio:es-latest pio/
	docker tag pio:es-latest 933782373565.dkr.ecr.eu-west-1.amazonaws.com/pio:es-latest
	docker build -t pio:ur-latest universal-recommender/
	docker tag pio:ur-latest 933782373565.dkr.ecr.eu-west-1.amazonaws.com/ur:es-latest

docker_push: docker_build
	docker push 933782373565.dkr.ecr.eu-west-1.amazonaws.com/pio:es-latest
	docker push 933782373565.dkr.ecr.eu-west-1.amazonaws.com/pio:ur-latest