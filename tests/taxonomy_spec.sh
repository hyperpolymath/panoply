#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
fail() { echo "FAIL: $*"; FAIL=$((FAIL+1)); }
pass() { echo "PASS: $*"; }

[[ -f docs/status/TEST-NEEDS.adoc ]] && pass "TEST-NEEDS" || fail "TEST-NEEDS"
[[ -f docs/reports/PHASE-4-VERIFICATION.adoc ]] && pass "phase4 report" || fail "phase4"
[[ -f verification/proofs/idris2/TaxonomyDecl.idr ]] && pass "TaxonomyDecl" || fail "TaxonomyDecl"
grep -q 'eighteenCategories' verification/proofs/idris2/TaxonomyDecl.idr && pass "count pin" || fail "count"
for c in UT P2P E2E BLD EXE REF LCY SMK PBT MUT FUZ CTR REG CHS CMP PRF TSF CDF; do
  grep -q "$c" docs/status/TEST-NEEDS.adoc && pass "needs $c" || fail "needs $c"
done
[[ -f tests/p2p.sh ]] && pass "CDF/P2P artefact" || fail "p2p"
echo "FAIL=$FAIL"
exit "$FAIL"
