FROM golang:1.14-alpine AS build

RUN set -e; \
    apk update && apk add ca-certificates git; \
    go get -v github.com/janw/fritzbox_exporter; \
    cd $GOPATH/src/github.com/janw/fritzbox_exporter; \
    CGO_ENABLED=0 go build -v -o /fritzbox_exporter


FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /go/src/github.com/janw/fritzbox_exporter/metrics*.json /
COPY --from=build /fritzbox_exporter /

EXPOSE 9042

ENTRYPOINT ["/fritzbox_exporter", "-listen-address", "0.0.0.0:9042"]
