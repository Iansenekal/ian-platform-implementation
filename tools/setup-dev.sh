#!/usr/bin/env bash
set -e

echo "[devcontainer] Installing basic developer packages (best-effort)"
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y || true
  apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    make \
    ca-certificates \
    gnupg \
    lsb-release || true

  # Install docker CLI if present in repo needs
  apt-get install -y --no-install-recommends docker.io || true
else
  echo "apt-get not found; skipping package installation"
fi

echo "[devcontainer] Setup complete. Install language-specific tools as needed."
