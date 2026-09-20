#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
fail() { echo "FAIL: $*"; FAIL=$((FAIL+1)); }
pass() { echo "PASS: $*"; }

[[ -f src/manifest/MANIFEST-SCHEMA.adoc ]] && pass "schema spec" || fail "missing MANIFEST-SCHEMA"
[[ -f src/manifest/examples/refused.manifest ]] && pass "example" || fail "missing example"
grep -q ':status refused' src/manifest/examples/refused.manifest && pass "honest refused" || fail "example must be refused"
grep -q ':earned ()' src/manifest/examples/refused.manifest && pass "empty earned" || fail "must not claim earned envelopes"
grep -q 'No emitter' src/manifest/MANIFEST-SCHEMA.adoc && pass "schema admits no emitter" || fail "must not claim an emitter"

echo "FAIL=$FAIL"
exit "$FAIL"
