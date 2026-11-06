#!/usr/bin/env bash
# Builds ibus 1.5.29-2ubuntu0~local1 for Ubuntu 24.04 in a podman
# container and puts the .deb files in build/. See README.md. The host
# certificates are mounted at /host-certs, not /etc/ssl/certs, because
# the ca-certificates package writes there when it is configured.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$here/build"
rm -f "$here/build"/*.deb

podman run --rm \
  -v "$here:/work:z" \
  -v /etc/ssl/certs:/host-certs:ro \
  -e SSL_CERT_FILE=/host-certs/ca-certificates.crt \
  -e CURL_CA_BUNDLE=/host-certs/ca-certificates.crt \
  docker.io/library/ubuntu:24.04 \
  bash /work/container-build.sh

ls -l "$here/build"/*.deb
