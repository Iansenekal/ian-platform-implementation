#!/usr/bin/env bash
set -euo pipefail

echo "[check] Proxmox version"
pveversion -v | head -n 5

echo "[check] system running state"
systemctl is-system-running || true

echo "[check] critical listeners"
ss -tulpen | grep -E '(:22\b|:8006\b)' || true

echo "[check] ssh policy flags"
grep -E '^(PasswordAuthentication|PermitRootLogin|PubkeyAuthentication)' /etc/ssh/sshd_config || true

echo "[check] timezone and ntp"
timedatectl | sed -n '1,12p'
timedatectl show-timesync --all | sed -n '1,25p' || true

echo "[check] network and routes"
ip -br a
ip r

echo "[check] dns resolv"
cat /etc/resolv.conf

echo "post-install-hardening-verification: REVIEW OUTPUT MANUALLY"
