FROM golang:1.19-alpine AS build

ARG GO111MODULE=on
ARG CGO_ENABLED=0
ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache ca-certificates git

WORKDIR /go/src/app

COPY go.* main.go ./
COPY fritzbox_lua ./fritzbox_lua
COPY fritzbox_upnp ./fritzbox_upnp

RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -a \
    -ldflags '-w -extldflags "-static"' \
    -o fritzbox_exporter \
    main.go

FROM scratch

COPY metrics*.json /
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /go/src/app/fritzbox_exporter /

EXPOSE 9042

ENTRYPOINT ["/fritzbox_exporter", "-listen-address", "0.0.0.0:9042"]
