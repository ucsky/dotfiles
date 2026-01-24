#!/usr/bin/env bash
#
# Description:
#   Installer for WSL (Windows Subsystem for Linux).
#   This is a Linux environment with Windows host constraints.
#
# Usage:
#   ./make/install_bare-mswin-wsl.bash
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Detected environment: WSL"
echo "Running Linux bare installer with WSL-friendly defaults."

# In WSL, sudo may or may not be available. The Linux installer is already non-fatal without admin.
bash "$REPO_ROOT/make/install_bare-ubuntu.bash"

