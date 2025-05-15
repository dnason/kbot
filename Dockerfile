ARG TARGETOS
ARG TARGETARCH
ARG BASE_IMAGE

FROM --platform=$TARGETOS/$TARGETARCH quay.io/projectquay/golang:1.24 AS builder

WORKDIR /app
COPY . .

ARG VERSION
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -o kbot$(if [ "$TARGETOS" = "windows" ]; then echo ".exe"; fi) \
    -ldflags "-X=github.com/dnason/kbot/cmd.appVersion=${VERSION}" .

FROM --platform=$TARGETOS/$TARGETARCH ${BASE_IMAGE} AS final

WORKDIR /app
COPY --from=builder /app/kbot$(if [ "$TARGETOS" = "windows" ]; then echo ".exe"; fi) /app/kbot$(if [ "$TARGETOS" = "windows" ]; then echo ".exe"; fi)

# For Linux, add CA certs
RUN if [ "$TARGETOS" = "linux" ]; then \
        apt-get update && apt-get install -y ca-certificates && update-ca-certificates; \
    fi

ENTRYPOINT ["./kbot$(if [ \"$TARGETOS\" = \"windows\" ]; then echo \".exe\"; fi)"]
