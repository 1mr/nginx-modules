ARG NGINX_VERSION="1.30.5"
ARG DEBIAN_VERSION="13"

FROM debian:${DEBIAN_VERSION} AS builder

ARG NGINX_VERSION
ENV NGINX_VERSION=$NGINX_VERSION DEBIAN_FRONTEND=noninteractive

RUN . /etc/os-release \
  && if [ "$VERSION_ID" = "11" ]; then sed -i '/debian-security/d' /etc/apt/sources.list; fi \
  && apt-get update && apt-get install -y \
  build-essential \
  cmake \
  make \
  libpcre2-dev \
  libssl-dev \
  zlib1g-dev \
  git \
  curl

WORKDIR /build/
RUN \
  curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o - | tar xz \
  && git clone https://github.com/vozlt/nginx-module-vts.git

WORKDIR /build/nginx-${NGINX_VERSION}/
RUN \
  ./configure --with-compat --add-dynamic-module=/build/nginx-module-vts \
  && make modules

WORKDIR /modules/
RUN cp /build/nginx-${NGINX_VERSION}/objs/*.so ./

FROM scratch
ARG NGINX_VERSION
ARG DEBIAN_VERSION
COPY --from=builder /modules/ ${NGINX_VERSION}/debian${DEBIAN_VERSION}/
