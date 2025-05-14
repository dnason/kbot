ifeq '$(findstring ;,$(PATH))' ';'
	detected_OS := windows
	TARGET_ARCH := amd64
else
	TARGET_OS := $(shell uname | tr '[:upper:]' '[:lower:]' 2> /dev/null || echo Unknown)
	TARGET_OS := $(patsubst CYGWIN%,Cygwin,$(TARGET_OS))
	TARGET_OS := $(patsubst MSYS%,MSYS,$(TARGET_OS))
	TARGET_OS := $(patsubst MINGW%,MSYS,$(TARGET_OS))
	TARGET_ARCH := $(shell uname -m || echo amd64)
endif

REGISTRY := ghcr.io
APP := $(shell basename $(shell git remote get-url origin))
USERNAME := dnason
VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.1.0)-$(shell git rev-parse --short HEAD 2>/dev/null || echo unknown)

format:
	docker run --rm -v $(CURDIR):/app -w /app golang:1.24-alpine sh -c "gofmt -w -s ./"

get:
	docker run --rm -v $(CURDIR):/app -w /app golang:1.24-alpine sh -c "go get"

lint:
	docker run --rm -v $(CURDIR):/app -w /app golang:1.24-alpine sh -c "go install golang.org/x/lint/golint@latest && golint"

test:
	docker run --rm -v $(CURDIR):/app -w /app golang:1.24-alpine sh -c "go test -v"

build:
	docker run --rm -v $(CURDIR):/app -w /app golang:1.24-alpine sh -c "CGO_ENABLED=0 GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH} go build -o kbot -ldflags \"-X=github.com/dnason/kbot/cmd.appVersion=${VERSION}\""

image: format get
	docker build --build-arg GOOS=${TARGET_OS} --build-arg GOARCH=${TARGET_ARCH} --build-arg VERSION=${VERSION} -t ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-${TARGET_OS}-${TARGET_ARCH} .

linux: format get
	docker build --build-arg GOOS=linux --build-arg GOARCH=${TARGET_ARCH} --build-arg VERSION=${VERSION} -t ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-linux-${TARGET_ARCH} .

windows: format get
	docker build --build-arg GOOS=windows --build-arg GOARCH=${TARGET_ARCH} --build-arg VERSION=${VERSION} -t ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-windows-${TARGET_ARCH} .

darwin: format get
	docker build --build-arg GOOS=darwin --build-arg GOARCH=${TARGET_ARCH} --build-arg VERSION=${VERSION} -t ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-darwin-${TARGET_ARCH} .

arm: format get
	docker build --build-arg GOOS=${TARGET_OS} --build-arg GOARCH=arm --build-arg VERSION=${VERSION} -t ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-${TARGET_OS}-arm .

push:
	docker push ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-${TARGET_OS}-${TARGET_ARCH}

clean:
	@rm -rf kbot 2>/dev/null || true
	@DOCKER_IMAGE=$$(docker images -q ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-${TARGET_OS}-${TARGET_ARCH} 2>/dev/null); \
	if [ -n "$${DOCKER_IMAGE}" ]; then docker rmi -f $${DOCKER_IMAGE}; fi

.PHONY: format get lint test build image linux windows darwin arm push clean