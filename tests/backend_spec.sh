#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
fail() { echo "FAIL: $*"; FAIL=$((FAIL+1)); }
pass() { echo "PASS: $*"; }
[[ -f src/backends/BACKEND-CONTRACT.adoc ]] && pass "contract spec" || fail "missing BACKEND-CONTRACT"
[[ -f src/backends/none/CONTRACT.adoc ]] && pass "none" || fail "none"
[[ -f src/backends/zig-ffi/CONTRACT.adoc ]] && pass "zig-ffi" || fail "zig-ffi"
grep -q 'Upholds nothing' src/backends/none/CONTRACT.adoc && pass "none upholds nothing" || fail "none must uphold nothing"
echo "FAIL=$FAIL"
exit "$FAIL"
