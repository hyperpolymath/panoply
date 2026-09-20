#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# P2P tests — peer/process composition of envelopes.
# Design phase: there is no runtime peer protocol. This gate documents
# the obligation and fails closed only if a claimed P2P surface appears
# without tests.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

echo "PANOPLY — P2P tests"

# If a peer protocol lands under src/bridges or src/backends, this file
# must grow real cases. Until then, skip is the honest result.
if grep -RIl --include='*.zig' --include='*.idr' -E 'p2p|peer.?to.?peer' src/ 2>/dev/null | grep -q .; then
    echo "FAIL: P2P-shaped source exists without a real P2P test harness"
    exit 1
fi

echo "SKIP: no peer protocol in this repository yet (charter design phase)"
echo "PASS=0 FAIL=0 SKIP=1"
exit 0
