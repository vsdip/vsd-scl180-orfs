#!/usr/bin/env bash
set -euo pipefail

OPENROAD_URL="https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/openroad-linux-x64.tar.gz"

tmpdir=$(mktemp -d)

wget -O "$tmpdir/openroad.tar.gz" "$OPENROAD_URL"
tar -xzf "$tmpdir/openroad.tar.gz" -C "$tmpdir"

sudo mkdir -p /opt/openroad
sudo cp -r "$tmpdir/bin" /opt/openroad/
sudo cp -r "$tmpdir/lib" /opt/openroad/

sudo ln -sf /opt/openroad/bin/openroad /usr/local/bin/openroad

echo "/opt/openroad/lib" | sudo tee /etc/ld.so.conf.d/openroad.conf
sudo ldconfig

openroad -version || true
