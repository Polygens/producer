FROM golang:1.13-alpine AS builder
RUN apk update && apk add --no-cache git make
WORKDIR /producer
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG VERSION=unknown
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 make build VERSION=$VERSION
RUN echo "appuser:x:65534:65534:appuser:/:" > /etc_passwd

FROM scratch
COPY --from=builder /root/go/bin/producer /producer/defaults.yaml /
COPY --from=builder /etc_passwd /etc/passwd
USER appuser
ENTRYPOINT ["/producer"]
