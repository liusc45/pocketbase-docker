ARG PB_VERSION=0.28.0

# 🛠 Stage 1: Descargar PocketBase
FROM alpine:latest AS setup

ARG PB_VERSION
WORKDIR /setup

RUN apk add --no-cache unzip curl ca-certificates

RUN curl -fsSL https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip -o /tmp/pb.zip \
  && unzip /tmp/pb.zip -d . \
  && chmod +x pocketbase

# 🚀 Stage 2: Imagen final
FROM alpine:latest AS app

ARG PB_VERSION
WORKDIR /app

# Copiar binario desde setup
COPY --from=setup /setup/pocketbase ./pocketbase
COPY entrypoint.sh ./entrypoint.sh

# Crear usuario seguro
RUN addgroup -S pocketbase && adduser -S -G pocketbase pocketbase

# ✅ Asegurar permisos de ejecución
RUN chmod +x ./entrypoint.sh ./pocketbase

# ✅ Asegurar permisos de propiedad
RUN chown -R pocketbase:pocketbase ./

USER pocketbase
EXPOSE 8090

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./pocketbase", "serve", "--http=0.0.0.0:8090"]

# 📦 OCI Labels
LABEL org.opencontainers.image.title="Pocketbase Docker"
LABEL org.opencontainers.image.description="Unofficial repository of PocketBase project images"
LABEL org.opencontainers.image.version="${PB_VERSION}"
LABEL org.opencontainers.image.authors="Bakir Gracic <me@bakirg.dev>"
LABEL org.opencontainers.image.source="https://github.com/bakirgracic/pocketbase-docker"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.documentation="https://github.com/BakirGracic/pocketbase-docker/blob/main/README.md"
