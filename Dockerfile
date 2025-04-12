FROM alpine:latest AS setup

ARG PB_VERSION=0.26.6

RUN apk add --no-cache unzip ca-certificates
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

FROM alpine:latest AS final

WORKDIR /pb
COPY --from=setup /pb/pocketbase /pb/pocketbase

RUN addgroup -S pocketbase && adduser -SG pocketbase pocketbase
RUN chown -R pocketbase:pocketbase /pb/ && chmod +x /pb/pocketbase
USER pocketbase

EXPOSE 8090

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost:8090/api/health || exit 1

RUN /pb/pocketbase superuser create test@test.com Test123!

CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8090"]
