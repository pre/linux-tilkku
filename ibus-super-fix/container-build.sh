#!/usr/bin/env bash
# Runs inside the ubuntu:24.04 container. /work has patches/ and build/.
set -euo pipefail

version='1.5.29-2ubuntu0~local1'

/usr/bin/cat > /etc/apt/sources.list.d/ubuntu.sources <<'SOURCES'
Types: deb deb-src
URIs: http://archive.ubuntu.com/ubuntu
Suites: noble noble-updates
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
SOURCES

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends dpkg-dev devscripts
apt-get build-dep -y ibus

mkdir -p /build && cd /build
apt-get source ibus
cd ibus-1.5.29

cp /work/patches/0006-*.patch /work/patches/0007-*.patch debian/patches/
basename -a debian/patches/0006-*.patch debian/patches/0007-*.patch >> debian/patches/series
{ /usr/bin/cat /work/patches/changelog.txt; echo; /usr/bin/cat debian/changelog; } > debian/changelog.new
mv debian/changelog.new debian/changelog
dpkg-parsechangelog --show-field Version | grep -qx "$version"

dpkg-buildpackage -us -uc -b

cp /build/*.deb /work/build/
cd /work/build && dpkg-deb --field ibus_*.deb Version
