#!/bin/sh

set -e

NGINX_VERSION="${NGINX_VERSION:-1.30.5}"
PLATFORMS="${PLATFORMS:-linux/amd64}"
# PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
DEBIAN_VERSIONS="${DEBIAN_VERSIONS:-11,12,13}"

for p in $(echo "${PLATFORMS}" | tr ',' ' '); do
  arch=$(echo "${p}" | tr '/' '-')
  for d in $(echo "${DEBIAN_VERSIONS}" | tr ',' ' '); do
    for m in ngx_brotli ngx_geoip2 ngx_vts; do
      docker buildx build \
        --platform "${p}" \
        --build-arg NGINX_VERSION="${NGINX_VERSION}" \
        --build-arg DEBIAN_VERSION="${d}" \
        --build-arg TARGETARCH="${p#linux/}" \
        --output "type=local,dest=./modules/${arch}" \
        -f "${m}/Dockerfile" \
        .
    done
  done
done
