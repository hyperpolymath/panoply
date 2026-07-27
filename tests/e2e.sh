#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# RSR Standard E2E Test Template
#
# End-to-end tests validate the full pipeline: build → run → verify output.
# Customise this file for your project. Delete the examples that don't apply.
#
# Usage:
#   bash tests/e2e.sh
#   just e2e
#
# Merge requirements (STANDING): All 6 test categories must pass before merge:
#   P2P, E2E (this file), aspect, execution, lifecycle, benchmarks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0
SKIP=0

# ─── Colour helpers ──────────────────────────────────────────────────
green() { printf '\033[32m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

# ─── Assertion helpers ───────────────────────────────────────────────

# check <label> <expected-substring> <actual>
check() {
    local name="$1" expected="$2" actual="$3"
    if echo "$actual" | grep -q "$expected"; then
        green "  PASS: $name"
        PASS=$((PASS + 1))
    else
        red "  FAIL: $name (expected '$expected', got '${actual:0:120}')"
        FAIL=$((FAIL + 1))
    fi
}

# check_status <label> <expected-http-status> <actual-http-status>
check_status() {
    local name="$1" expected="$2" actual="$3"
    if [ "$actual" = "$expected" ]; then
        green "  PASS: $name (HTTP $actual)"
        PASS=$((PASS + 1))
    else
        red "  FAIL: $name (expected HTTP $expected, got HTTP $actual)"
        FAIL=$((FAIL + 1))
    fi
}

# skip <label> <reason>
skip_test() {
    yellow "  SKIP: $1 ($2)"
    SKIP=$((SKIP + 1))
}

echo "═══════════════════════════════════════════════════════════════"
echo "  PANOPLY — End-to-End Tests"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ─── Preflight ───────────────────────────────────────────────────────
bold "Preflight checks"

if command -v idris2 >/dev/null 2>&1; then
    green "  Found idris2: $(idris2 --version 2>&1 | head -1)"
else
    red "idris2 not found on PATH"
    exit 1
fi

if command -v zig >/dev/null 2>&1; then
    green "  Found zig: $(zig version)"
else
    red "zig not found on PATH"
    exit 1
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 1: Idris2 ABI build
# ═══════════════════════════════════════════════════════════════════════
bold "Section 1: Idris2 ABI (abi.ipkg)"

cd "$PROJECT_DIR"
ABI_OUTPUT=$(idris2 --build abi.ipkg 2>&1)
ABI_STATUS=$?
if [ "$ABI_STATUS" -eq 0 ]; then
    green "  PASS: idris2 --build abi.ipkg"
    PASS=$((PASS + 1))
else
    red "  FAIL: idris2 --build abi.ipkg"
    echo "$ABI_OUTPUT" | tail -20
    FAIL=$((FAIL + 1))
fi

# ═══════════════════════════════════════════════════════════════════════
# Section 2: Zig FFI build + test
# ═══════════════════════════════════════════════════════════════════════
bold "Section 2: Zig FFI (src/interface/ffi)"

cd "$PROJECT_DIR/src/interface/ffi"
ZIG_OUTPUT=$(zig build test --summary all 2>&1)
ZIG_STATUS=$?
if [ "$ZIG_STATUS" -eq 0 ]; then
    green "  PASS: zig build test"
    PASS=$((PASS + 1))
else
    red "  FAIL: zig build test"
    echo "$ZIG_OUTPUT" | tail -40
    FAIL=$((FAIL + 1))
fi
cd "$PROJECT_DIR"

# ═══════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════════"
printf "  Results: "
green "PASS=$PASS" | tr -d '\n'
echo -n "  "
if [ "$FAIL" -gt 0 ]; then red "FAIL=$FAIL" | tr -d '\n'; else echo -n "FAIL=0"; fi
echo -n "  "
if [ "$SKIP" -gt 0 ]; then yellow "SKIP=$SKIP"; else echo "SKIP=0"; fi
echo "═══════════════════════════════════════════════════════════════"

exit "$FAIL"
