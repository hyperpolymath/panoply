#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# install-tools.sh — Developer toolchain installer
#
# Detects Guix (canonical) or asdf. Nix is deprecated.

set -euo pipefail

echo "=== RSR Toolchain Installer ==="

if [ -f "build/guix.scm" ] || [ -f "guix.scm" ] || [ -f "build/.guix-channel" ]; then
    if command -v guix &>/dev/null; then
        echo "Guix detected. Enter: just guix-shell"
        guix --version | head -1 || true
    else
        echo "Guix manifest present but guix is not on PATH."
        echo "Install Guix: https://guix.gnu.org/manual/en/html_node/Binary-Installation.html"
    fi
elif [ -f ".tool-versions" ] && command -v asdf &>/dev/null; then
    echo "asdf detected. Installing plugins and tools..."
    while read -r line; do
        plugin=$(echo "$line" | awk '{print $1}')
        asdf plugin add "$plugin" || true
    done < .tool-versions
    asdf install
else
    echo "No Guix channel/manifest detected."
    echo "Please refer to README.adoc for manual setup instructions."
fi

echo "Installer complete."
