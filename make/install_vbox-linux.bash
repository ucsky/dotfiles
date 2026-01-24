#!/usr/bin/env bash
#
# Description:
#   Installer for Linux running inside VirtualBox.
#
# Usage:
#   ./make/install_vbox-linux.bash
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Detected environment: VirtualBox Linux guest"
echo "Running standard Linux bare installer."

bash "$REPO_ROOT/make/install_bare-linux.bash"

