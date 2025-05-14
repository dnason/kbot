FROM quay.io/projectquay/golang:1.24 AS builder
WORKDIR /app
COPY . .
RUN make build

FROM scratch
WORKDIR /
COPY --from=builder /app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]