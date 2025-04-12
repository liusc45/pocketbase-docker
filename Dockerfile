ARG PB_VERSION=0.26.6

FROM alpine:latest AS setup

ARG PB_VERSION

RUN apk add --no-cache unzip ca-certificates
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

FROM alpine:latest AS final

ARG PB_VERSION

WORKDIR /pb
COPY --from=setup /pb/pocketbase /pb/pocketbase
COPY entrypoint.sh /pb/entrypoint.sh

RUN addgroup -S pocketbase && adduser -SG pocketbase pocketbase
RUN chmod +x /pb/entrypoint.sh /pb/pocketbase
RUN chown -R pocketbase:pocketbase /pb/
USER pocketbase

EXPOSE 8090

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost:8090/api/health || exit 1

LABEL org.opencontainers.image.title="Pocketbase Docker"
LABEL org.opencontainers.image.description="Unofficial repository of PocketBase project images"
LABEL org.opencontainers.image.version="${PB_VERSION}"
LABEL org.opencontainers.image.authors="Bakir Gracic <me@bakirg.dev>"
LABEL org.opencontainers.image.source="https://github.com/bakirgracic/pocketbase-docker"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.documentation="https://github.com/BakirGracic/pocketbase-docker/blob/main/README.md"

ENTRYPOINT ["/pb/entrypoint.sh"]
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8090"]
