#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
fail() { echo "FAIL: $*"; FAIL=$((FAIL+1)); }
pass() { echo "PASS: $*"; }
[[ -f src/projections/PROJECTION.adoc ]] && pass "projection spec" || fail "missing"
[[ -f src/projections/null/equivalence-refuse-refuse.witness ]] && pass "witness" || fail "witness"
grep -q ':result rejected' src/projections/null/equivalence-refuse-refuse.witness && pass "reject witnessed" || fail "must reject"
echo "FAIL=$FAIL"
exit "$FAIL"
