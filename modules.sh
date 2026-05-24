#!/bin/sh

set -e

NGINX_VERSION="${NGINX_VERSION:-1.30.2}"
PLATFORMS="${PLATFORMS:-linux/amd64}"
# PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"

for p in $(echo "${PLATFORMS}" | tr ',' ' '); do
  arch=$(echo "${p}" | tr '/' '-')
  for m in ngx_brotli ngx_geoip2 ngx_vts; do
    docker buildx build \
      --platform "${p}" \
      --build-arg NGINX_VERSION="${NGINX_VERSION}" \
      --build-arg TARGETARCH="${p#linux/}" \
      --output "type=local,dest=./modules/${arch}" \
      -f "${m}/Dockerfile" \
      .
  done
done
