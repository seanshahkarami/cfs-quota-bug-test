FROM golang:1.19 AS builder
WORKDIR /src
COPY src /src
RUN go build

FROM scratch
COPY --from=builder /src/cfs-quota-bug-test /entrypoint
ENTRYPOINT [ "/entrypoint" ]
