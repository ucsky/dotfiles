#!/usr/bin/env bash
#
# Description:
#   Installer for Ubuntu running inside VirtualBox.
#
# Usage:
#   ./make/install_vbox-ubuntu.bash
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Detected environment: VirtualBox Ubuntu guest"
echo "Running standard Ubuntu bare installer."

bash "$REPO_ROOT/make/install_bare-ubuntu.bash"

