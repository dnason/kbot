APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := ghcr.io/dnason
VERSION := $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

.PHONY: linux arm64 windows macos push clean

linux:
	docker buildx build \
		--platform linux/amd64 \
		--build-arg VERSION=$(VERSION) \
		--build-arg TARGETOS=linux \
		--build-arg TARGETARCH=amd64 \
		--build-arg BASE_IMAGE=scratch \
		--output type=docker \
		-t $(REGISTRY)/$(APP):$(VERSION)-linux-amd64 \
		.

arm64:
	docker buildx build \
		--platform linux/arm64 \
		--build-arg VERSION=$(VERSION) \
		--build-arg TARGETOS=linux \
		--build-arg TARGETARCH=arm64 \
		--build-arg BASE_IMAGE=scratch \
		--output type=docker \
		-t $(REGISTRY)/$(APP):$(VERSION)-linux-arm64 \
		.

windows:
	docker buildx build \
		--platform windows/amd64 \
		--build-arg VERSION=$(VERSION) \
		--build-arg TARGETOS=windows \
		--build-arg TARGETARCH=amd64 \
		--build-arg BASE_IMAGE=mcr.microsoft.com/windows/nanoserver:ltsc2022 \
		--output type=docker \
		-t $(REGISTRY)/$(APP):$(VERSION)-windows-amd64 \
		.

macos:
	docker buildx build \
		--platform darwin/arm64 \
		--build-arg VERSION=$(VERSION) \
		--build-arg TARGETOS=darwin \
		--build-arg TARGETARCH=arm64 \
		--build-arg BASE_IMAGE=scratch \
		--output type=docker \
		-t $(REGISTRY)/$(APP):$(VERSION)-darwin \
		.

push:
	docker buildx build \
		--platform linux/amd64,linux/arm64,darwin/arm64,windows/amd64 \
		--build-arg VERSION=$(VERSION) \
		--build-arg BASE_IMAGE=scratch \
		--push \
		-t $(REGISTRY)/$(APP):$(VERSION) \
		.

clean:
	@rm -rf kbot*; \
	DOCKER_IMAGE=$$(docker images -q | head -n 1); \
	if [ -n "$${DOCKER_IMAGE}" ]; then  docker rmi -f $${IMG1};