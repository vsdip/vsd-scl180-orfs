#!/usr/bin/env bash
set -euo pipefail

ORFS="/workspaces/vsd-scl180-orfs/orfs/tools/openroad"

git lfs install --skip-repo || true
git lfs pull

# Install binary
sudo install -m 0755 "$ORFS/bin/openroad" /usr/local/bin/openroad

# Install vendored libs (if present)
if [ -d "$ORFS/lib" ] && ls "$ORFS/lib"/*.so* >/dev/null 2>&1; then
  sudo mkdir -p /usr/local/lib/openroad
  sudo cp -a "$ORFS/lib"/*.so* /usr/local/lib/openroad/
  echo '/usr/local/lib/openroad' | sudo tee /etc/ld.so.conf.d/openroad.conf >/dev/null
fi

# Ensure runtime deps for the binary exist (tclreadline is needed)
sudo apt-get update
sudo apt-get install -y --no-install-recommends tcl-tclreadline

sudo ldconfig

# Sanity check: fail if any deps still missing
if ldd /usr/local/bin/openroad | grep -q 'not found'; then
  echo "ERROR: OpenROAD still has missing shared libraries:"
  ldd /usr/local/bin/openroad | grep 'not found' || true
  exit 1
fi

openroad -version || openroad -v || true
