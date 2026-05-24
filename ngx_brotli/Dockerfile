ARG NGINX_VERSION="1.30.2"

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
RUN \
  cmake -B ./out/ -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" \
  -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" \
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
