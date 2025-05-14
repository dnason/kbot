GOLANG_IMAGE = golang:1.24
DOCKER_RUN = docker run --rm -v $(PWD):/app -w /app $(GOLANG_IMAGE)
APP := $(shell basename $(shell git remote get-url origin))
USERNAME := dnason
VERSION := $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGET_ARCH := $(shell uname -m)
ifeq ($(UNAME_ARCH),x86_64)
	TARGET_ARCH := amd64
else
	TARGET_ARCH := $(UNAME_ARCH)
endif
TARGET_OS := $(shell uname | tr '[:upper:]' '[:lower:]')

format:
	$(DOCKER_RUN) gofmt -s -w ./

get:
	$(DOCKER_RUN) go mod download

lint:
	$(DOCKER_RUN) sh -c "go install golang.org/x/lint/golint@latest && golint ./..."

test:
	$(DOCKER_RUN) go test -v ./...

build:
	$(DOCKER_RUN) sh -c "CGO_ENABLED=0 GOOS=$(TARGET_OS) GOARCH=$(TARGET_ARCH) go build -buildvcs=false -v -o kbot -ldflags='-X=github.com/dnason/kbot/cmd.appVersion=$(VERSION)'"


image: build
	docker build --build-arg name=build -t $(USERNAME)/$(APP):$(VERSION)-$(TARGET_OS)-$(TARGET_ARCH) .

push:
	docker push $(USERNAME)/$(APP):$(VERSION)-$(TARGET_OS)-$(TARGET_ARCH)

clean:
	@rm -rf kbot; \
	docker rm -f `docker ps -aq --filter ancestor=$(USERNAME)/$(APP):$(VERSION)-$(TARGET_OS)-$(TARGET_ARCH)` 2>/dev/null || true; \
	docker rmi -f $(USERNAME)/$(APP):$(VERSION)-$(TARGET_OS)-$(TARGET_ARCH) 2>/dev/null || true

# ifeq '$(findstring ;,$(PATH))' ';'
#     TARGET_OS := windows
# 	TARGET_ARCH := amd64
# else
#     TARGET_OS := $(shell uname | tr '[:upper:]' '[:lower:]' 2> /dev/null || echo Unknown)
#     TARGET_OS := $(patsubst CYGWIN%,Cygwin,$(TARGET_OS))
#     TARGET_OS := $(patsubst MSYS%,MSYS,$(TARGET_OS))
#     TARGET_OS := $(patsubst MINGW%,MSYS,$(TARGET_OS))
# 	TARGET_ARCH := $(shell dpkg --print-architecture 2>/dev/null || amd64)
# endif

# GOLANG_IMAGE = quay.io/projectquay/golang:1.24
# DOCKER_RUN = docker run --rm -v $(PWD):/app -w /app $(GOLANG_IMAGE)
# APP=$(shell basename $(shell git remote get-url origin))
# REGESTRY=dnason
# VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

# format:
# 	$(DOCKER_RUN) gofmt -s -w ./

# get:
# 	$(DOCKER_RUN) go get

# lint:
# 	$(DOCKER_RUN) golint

# test:
# 	$(DOCKER_RUN)  go test -v

# build: format get
# 	CGO_ENABLED=0 GOOS=$(TARGET_OS) GOARCH=$(TARGET_ARCH) go build -v -o kbot -ldflags "-X="github.com/dnason/kbot/cmd.appVersion=${VERSION}

# linux: format get
# 	CGO_ENABLED=0 GOOS=linux GOARCH=$(TARGET_ARCH) go build -v -o kbot -ldflags "-X="github.com/dnason/kbot/cmd.appVersion=${VERSION}
# 	docker build --build-arg name=linux -t ${REGESTRY}/${APP}:${VERSION}-linux-$(TARGET_ARCH) .

# windows: format get
# 	CGO_ENABLED=0 GOOS=windows GOARCH=$(TARGET_ARCH) go build -v -o kbot -ldflags "-X="github.com/dnason/kbot/cmd.appVersion=${VERSION}
# 	docker build --build-arg name=windows -t ${REGESTRY}/${APP}:${VERSION}-windows-$(TARGET_ARCH) .

# darwin:format get
# 	CGO_ENABLED=0 GOOS=darwin GOARCH=$(TARGET_ARCH) go build -v -o kbot -ldflags "-X="github.com/dnason/kbot/cmd.appVersion=${VERSION}
# 	docker build --build-arg name=darwin -t ${REGESTRY}/${APP}:${VERSION}-darwin-$(TARGET_ARCH) .

# arm: format get
# 	CGO_ENABLED=0 GOOS=$(TARGET_OS) GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/vit-um/dnason/cmd.appVersion=${VERSION}
# 	docker build --build-arg name=arm -t ${REGESTRY}/${APP}:${VERSION}-$(TARGET_OS)-arm .
# build:
# 	$(DOCKER_RUN) sh -c "CGO_ENABLED=0 GOOS=$(TARGET_OS) GOARCH=$(TARGET_ARCH) go build -v -o kbot -ldflags='-X=github.com/dnason/kbot/cmd.appVersion=$(VERSION)'"

# image: build
# 	docker build --build-arg name=build -t $(USERNAME)/$(APP):$(VERSION)-$(TARGET_OS)-$(TARGET_ARCH) .

# push:
# 	docker push $(USERNAME)/$(APP):$(VERSION)-$(TARGET_OS)-$(TARGET_ARCH)

# clean:
# 	@rm -rf kbot; \
# 	docker rm -f `docker ps -aq --filter ancestor=$(USERNAME)/$(APP):$(VERSION)-$(TARGET_OS)-$(TARGET_ARCH)` 2>/dev/null || true; \
# 	docker rmi -f $(USERNAME)/$(APP):$(VERSION)-$(TARGET_OS)-$(TARGET_ARCH) 2>/dev/null || true

# image: build
# 	docker build . -t ${REGESTRY}/${APP}:${VERSION}-$(TARGET_ARCH)

# push:
# 	docker push ${REGESTRY}/${APP}:${VERSION}-$(TARGET_ARCH)
