#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Lifecycle tests — install/build/clean round-trip for the FFI scaffold.
# Honest: Core language artefacts are not implemented; this covers the
# Idris2 ABI / Zig FFI that *does* exist.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

PASS=0
FAIL=0
SKIP=0
green() { printf '\033[32m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

pass() { green "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { red "  FAIL: $1"; FAIL=$((FAIL + 1)); }
skip() { yellow "  SKIP: $1"; SKIP=$((SKIP + 1)); }

echo "PANOPLY — Lifecycle tests"

if ! command -v zig >/dev/null 2>&1; then
    skip "zig not on PATH — cannot exercise FFI lifecycle"
    echo "PASS=$PASS FAIL=$FAIL SKIP=$SKIP"
    exit 0
fi

if (cd src/interface/ffi && zig build); then
    pass "zig build (debug library)"
else
    fail "zig build"
fi

if (cd src/interface/ffi && zig build test --summary all >/dev/null); then
    pass "zig build test after build"
else
    fail "zig build test"
fi

rm -rf src/interface/ffi/.zig-cache src/interface/ffi/zig-out
pass "clean FFI caches"

if command -v idris2 >/dev/null 2>&1; then
    if idris2 --typecheck src/interface/abi.ipkg; then
        pass "idris2 --typecheck abi.ipkg"
    else
        fail "idris2 --typecheck abi.ipkg"
    fi
else
    skip "idris2 not on PATH — ABI typecheck not run"
fi

echo "PASS=$PASS FAIL=$FAIL SKIP=$SKIP"
exit "$FAIL"
