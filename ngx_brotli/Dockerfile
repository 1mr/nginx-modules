ARG NGINX_VERSION="1.30.3"

FROM debian:13 AS builder

ARG NGINX_VERSION
ENV NGINX_VERSION=$NGINX_VERSION DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
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
  && git clone --recurse-submodules https://github.com/google/ngx_brotli.git

WORKDIR /build/ngx_brotli/deps/brotli/
ARG TARGETARCH="amd64"
RUN \
  case "$TARGETARCH" in \
  amd64) ARCH_FLAGS="-m64 -march=x86-64 -mtune=generic" ;; \
  arm64) ARCH_FLAGS="-march=armv8-a -mtune=generic" ;; \
  esac && \
  FLAGS="-Ofast ${ARCH_FLAGS} -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" && \
  cmake -B ./out/ -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_C_FLAGS="${FLAGS}" \
  -DCMAKE_CXX_FLAGS="${FLAGS}" \
  && cmake --build ./out/ --config Release --target brotlienc

WORKDIR /build/nginx-${NGINX_VERSION}/
RUN \
  ./configure --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' \
  --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
  --with-compat --add-dynamic-module=/build/ngx_brotli/ \
  && make modules

WORKDIR /modules/
RUN cp /build/nginx-${NGINX_VERSION}/objs/*.so ./

FROM scratch
ARG NGINX_VERSION
COPY --from=builder /modules/ ${NGINX_VERSION}/
