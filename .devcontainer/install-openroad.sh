#!/usr/bin/env bash
set -euo pipefail

OPENROAD_URL="https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/openroad-linux-x64.tar.gz"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

echo "[INFO] Downloading OpenROAD package..."
wget --retry-connrefused --tries=5 --waitretry=5 \
  -O "$tmpdir/openroad.tar.gz" "$OPENROAD_URL"

echo "[INFO] Extracting OpenROAD package..."
tar -xzf "$tmpdir/openroad.tar.gz" -C "$tmpdir"

echo "[INFO] Locating OpenROAD binary..."
OPENROAD_BIN="$(find "$tmpdir" -type f -name openroad | head -n 1 || true)"

if [ -z "${OPENROAD_BIN}" ]; then
  echo "[ERROR] Could not find 'openroad' binary inside downloaded archive."
  echo "[DEBUG] Archive contents:"
  tar -tzf "$tmpdir/openroad.tar.gz" | head -100 || true
  exit 1
fi

OPENROAD_ROOT="$(cd "$(dirname "$OPENROAD_BIN")/.." && pwd)"
OPENROAD_LIB="${OPENROAD_ROOT}/lib"

echo "[INFO] Installing OpenROAD into /opt/openroad ..."
sudo mkdir -p /opt/openroad/bin /opt/openroad/lib

sudo cp "$OPENROAD_BIN" /opt/openroad/bin/openroad
sudo chmod 755 /opt/openroad/bin/openroad

if [ -d "$OPENROAD_LIB" ]; then
  echo "[INFO] Copying shared libraries..."
  sudo cp -a "$OPENROAD_LIB"/. /opt/openroad/lib/
fi

sudo chmod 755 /opt/openroad
sudo chmod 755 /opt/openroad/bin
sudo chmod 755 /opt/openroad/lib
sudo chmod 644 /opt/openroad/lib/*.so* 2>/dev/null || true

echo "[INFO] Creating launcher symlink..."
sudo ln -sf /opt/openroad/bin/openroad /usr/local/bin/openroad

echo "[INFO] Registering runtime library path..."
echo '/opt/openroad/lib' | sudo tee /etc/ld.so.conf.d/openroad.conf >/dev/null
sudo ldconfig

echo "[INFO] Checking for unresolved shared libraries..."
if ldd /opt/openroad/bin/openroad | grep -q 'not found'; then
  echo "[ERROR] Missing shared libraries detected:"
  ldd /opt/openroad/bin/openroad | grep 'not found' || true
  exit 1
fi

echo "[INFO] OpenROAD version:"
/usr/local/bin/openroad -version || /usr/local/bin/openroad || true

echo "[INFO] OpenROAD installation completed successfully."
