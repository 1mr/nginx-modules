#!/bin/sh

set -e

NGINX_VERSION="1.30.2"

docker build -f ngx_brotli/Dockerfile --build-arg NGINX_VERSION="${NGINX_VERSION}" --output type=local,dest=./modules .
docker build -f ngx_geoip2/Dockerfile --build-arg NGINX_VERSION="${NGINX_VERSION}" --output type=local,dest=./modules .
docker build -f ngx_vts/Dockerfile --build-arg NGINX_VERSION="${NGINX_VERSION}" --output type=local,dest=./modules .
