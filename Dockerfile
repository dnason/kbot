ARG TARGET_OS=linux
ARG TARGET_ARCH=amd64
FROM quay.io/projectquay/golang:1.24 AS builder
WORKDIR /go/src/app
COPY . .

RUN gofmt -s -w . && \
    go mod download && \
    CGO_ENABLED=0 GOOS=${TARGET_OS} GOARCH={TARGET_ARCH} go build -v -o kbot -ldflags "-X=github.com/dnason/kbot/cmd.appVersion=1.0.2-7f77a87"

FROM scratch

WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["./kbot"]

# FROM quay.io/projectquay/golang:1.24 AS builder
# WORKDIR /app
# COPY . .
# RUN make build

# FROM scratch
# WORKDIR /
# COPY --from=builder /app/kbot .
# COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# ENTRYPOINT ["./kbot"]