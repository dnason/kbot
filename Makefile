GOLANG_IMAGE = golang:1.24
APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := ghcr.io/dnason
VERSION := $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

TARGETOS ?= linux# linux, darwin, windows
TARGETARCH ?= amd64# amd64, arm64

OUTPUT_NAME := kbot$(if $(findstring windows,$(TARGETOS)),.exe,)

DOCKER_RUN = docker run --rm \
	-v $(PWD):/app \
	-w /app \
	-e CGO_ENABLED=0 \
	-e GOOS=$(TARGETOS) \
	-e GOARCH=$(TARGETARCH) \
	$(GOLANG_IMAGE)

.PHONY: all format build image push clean

all: build image

format:
	$(DOCKER_RUN) sh -c "gofmt -s -w ./"

build:
	$(DOCKER_RUN) sh -c "go mod tidy && go build -v -o $(OUTPUT_NAME) -ldflags='-X=github.com/dnason/kbot/cmd.appVersion=$(VERSION)'"

image:
	docker build . \
		--build-arg name=$(TARGETOS) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

push:
	docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)
linux:
	docker build . \
		--build-arg name=linux \
		--build-arg TARGETOS=linux \
		--build-arg TARGETARCH=amd64 \
		-t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)
macos:
	docker build . \
		--build-arg name=darwin \
		--build-arg TARGETOS=darwin \
		--build-arg TARGETARCH=arm64 \
		-t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)
arm64:
	docker build . \
		--build-arg name=linux-arm64 \
		--build-arg TARGETOS=linux \
		--build-arg TARGETARCH=arm64 \
		-t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)
windows:
	docker build . \
		--build-arg name=windows \
		--build-arg TARGETOS=windows \
		--build-arg TARGETARCH=amd64 \
		-t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

clean:
	rm -f kbot kbot.exe
	-docker rmi -f $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) 2>/dev/null || true
