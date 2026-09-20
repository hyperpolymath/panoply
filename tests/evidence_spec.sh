#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
fail() { echo "FAIL: $*"; FAIL=$((FAIL+1)); }
pass() { echo "PASS: $*"; }

[[ -f src/evidence/EVIDENCE-KINDS.adoc ]] && pass "kinds spec" || fail "missing EVIDENCE-KINDS"
[[ -f src/evidence/examples/core-typing.evidence ]] && pass "example evidence" || fail "missing example"
grep -q ':kind check' src/evidence/examples/core-typing.evidence || fail "example kind"
grep -q ':status refused' src/evidence/examples/core-typing.evidence && pass "honest refused check" || fail "example must be refused until a checker exists"
# ABNF-shaped chora
head -5 panoply_chora.deed | grep -q 'repo-deed' && pass "panoply_chora.deed is repo-deed" || fail "chora"
grep -q '\[metadata\]' panoply_chora.deed && fail "chora must not be TOML" || pass "chora is not TOML"
grep -q '\[metadata\]' .machine_readable/descriptiles/STATE.deed && fail "STATE still TOML" || pass "STATE is s-expression"
grep -q '\[metadata\]' .machine_readable/descriptiles/LANGUAGES.deed && fail "LANGUAGES still TOML" || pass "LANGUAGES is s-expression"
grep -q '\[metadata\]' .machine_readable/descriptiles/AGENTIC.deed && fail "AGENTIC still TOML" || pass "AGENTIC is s-expression"

echo "FAIL=$FAIL"
exit "$FAIL"
