ifeq '$(findstring ;,$(PATH))' ';'
    detected_OS := windows
	TARGET_ARCH := amd64
else
    TARGET_OS := $(shell uname | tr '[:upper:]' '[:lower:]' 2> /dev/null || echo Unknown)
    TARGET_OS := $(patsubst CYGWIN%,Cygwin,$(TARGET_OS))
    TARGET_OS := $(patsubst MSYS%,MSYS,$(TARGET_OS))
    TARGET_OS := $(patsubst MINGW%,MSYS,$(TARGET_OS))
	TARGET_ARCH := $(shell uname -m || amd64)
endif

REGISTRY:=ghcr.io
APP:=$(shell basename $(shell git remote get-url origin))
USERNAME:=dnason
VERSION:=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

format:  
	gofmt -w -s ./

get:
	go get
 
lint:
	golint

test:
	go test -v

build: format get
	CGO_ENABLED=0 GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH} go build -o kbot -ldflags "-X="github.com/dnason/kbot/cmd.appVersion=${VERSION}

linux: format get
	CGO_ENABLED=0 GOOS=linux GOARCH=$(TARGET_ARCH) go build -v -o kbot -ldflags "-X="github.com/vit-um/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=linux -t ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-linux-$(TARGET_ARCH) .

windows: format get
	CGO_ENABLED=0 GOOS=windows GOARCH=$(TARGET_ARCH) go build -v -o kbot -ldflags "-X="github.com/vit-um/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=windows -t ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-windows-$(TARGET_ARCH) .

darwin:format get
	CGO_ENABLED=0 GOOS=darwin GOARCH=$(TARGET_ARCH) go build -v -o kbot -ldflags "-X="github.com/vit-um/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=darwin -t ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-darwin-$(TARGET_ARCH) .

arm: format get
	CGO_ENABLED=0 GOOS=$(TARGET_OS) GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/vit-um/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=arm -t ${REGISTRY}/${USERNAME}/${APP}:${VERSION}-${TARGET_OS}-arm .

image: build
	docker build . -t ${REGISTRY}/${USERNAME}/${APP}/${VERSION}-${TARGET_ARCH}

push:
	docker push ${REGISTRY}/${USERNAME}/${APP}/${VERSION}-${TARGET_ARCH}

clean:
	@rm -rf kbot; \
	DOCKER_IMAGE=$$(docker images -q | head -n 1); \
	if [ -n "$${DOCKER_IMAGE}" ]; then  docker rmi -f $${DOCKER_IMAGE}; fi