VENV_NAME?=.venv

build:
	docker build --build-arg TARGETPLATFORM=linux/amd64 .

buildx:
	docker buildx build --progress plain --platform linux/amd64,linux/arm64,linux/arm/v7 --push -t glomium/grafana:multiarch .
