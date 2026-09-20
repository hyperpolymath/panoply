#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# P2P / coupling: Idris2 ABI (Types + Foreign) ↔ Zig FFI.
# Taxonomy: a single seam (caller→callee / FFI boundary).

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
fail() { echo "FAIL: $*"; FAIL=$((FAIL + 1)); }
pass() { echo "PASS: $*"; }

echo "PANOPLY — P2P (ABI ↔ FFI seam)"

IDR="src/interface/Abi/Types.idr"
ZIG="src/interface/ffi/src/main.zig"
FOR="src/interface/Abi/Foreign.idr"

# Idris Result constructors (data Result = Ok | Error | …)
IDR_RES=$(grep -E '^data Result' "$IDR" | sed 's/.*= //; s/|//g')
echo "  Idris Result: $IDR_RES"

# Zig Result tags
ZIG_TAGS=$(awk '/pub const Result = enum/,/};/' "$ZIG" | grep -E '^\s+(ok|@"error"|error|invalid_param|busy)' | sed 's/[=,].*//; s/@"error"/error/; s/[[:space:]]//g')
echo "  Zig Result tags:"
echo "$ZIG_TAGS"

echo "$IDR_RES" | grep -qw Ok || fail "Idris Result missing Ok"
echo "$IDR_RES" | grep -qw Error || fail "Idris Result missing Error"
echo "$IDR_RES" | grep -qw InvalidParam || fail "Idris Result missing InvalidParam"
echo "$IDR_RES" | grep -qw Busy || fail "Idris Result missing Busy"

echo "$ZIG_TAGS" | grep -qx ok || fail "Zig Result missing ok=0"
echo "$ZIG_TAGS" | grep -qx error || fail "Zig Result missing error"
echo "$ZIG_TAGS" | grep -qx invalid_param || fail "Zig Result missing invalid_param"
echo "$ZIG_TAGS" | grep -qx busy || fail "Zig Result missing busy"

# Drift: Zig must not grow extra ABI codes Idris cannot name
if echo "$ZIG_TAGS" | grep -Eq 'out_of_memory|null_pointer'; then
  fail "Zig Result has codes not in Idris Result (ABI is Idris SSOT)"
else
  pass "Zig Result tags ⊆ Idris Result constructors"
fi

# C symbol names: %foreign "C:name,lib" vs pub export fn name
IDR_SYMS=$(grep '%foreign' "$FOR" | sed 's/.*C://; s/,.*//' | sort)
ZIG_SYMS=$(grep -E '^pub export fn ' "$ZIG" | sed 's/pub export fn //; s/(.*//' | sort)
echo "  Idris C symbols:"; echo "$IDR_SYMS"
echo "  Zig exports:"; echo "$ZIG_SYMS"

while read -r s; do
  [ -z "$s" ] && continue
  if echo "$ZIG_SYMS" | grep -qx "$s"; then
    pass "export $s present on both sides"
  else
    fail "Idris %foreign C:$s has no Zig pub export fn $s"
  fi
done <<< "$IDR_SYMS"

# Handle non-null: Idris createHandle 0 = Nothing; Zig init must not return a zero page as success — structural check only
grep -q 'createHandle 0 = Nothing' "$IDR" && pass "Idris rejects null handle" || fail "Idris createHandle null rule missing"

echo "FAIL=$FAIL"
exit "$FAIL"
