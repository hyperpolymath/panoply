#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Guards the Core specification artefacts (issue #5). Does not pretend a
# checker exists.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
fail() { echo "FAIL: $*"; FAIL=$((FAIL + 1)); }
pass() { echo "PASS: $*"; }

for f in src/core/CORE-SYNTAX.adoc src/core/CORE-JUDGEMENTS.adoc src/core/README.adoc; do
  if [[ -f "$f" ]]; then pass "exists $f"; else fail "missing $f"; fi
done

grep -q 'Π (x : q A)' src/core/CORE-SYNTAX.adoc && pass "syntax names dependent product" || fail "Π missing"
grep -q 'Γ ⊢ t ↝ E : q A' src/core/CORE-JUDGEMENTS.adoc && pass "judgements yield evidence" || fail "evidence judgement missing"
grep -q 'not implemented' src/core/CORE-JUDGEMENTS.adoc && pass "honest unimplemented checker" || fail "must not claim a checker"

echo "FAIL=$FAIL"
exit "$FAIL"
