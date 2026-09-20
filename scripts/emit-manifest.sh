#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Fail-closed manifest emitter (#7).
# No guarantee without an envelope; no envelope without non-refused evidence;
# no composition without a named rule.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE="${1:-$ROOT/src/evidence/examples/core-typing.evidence}"
BACKEND="${2:-none}"
OUT="${3:-}"

if [[ ! -f "$EVIDENCE" ]]; then
  echo "emit-manifest: missing evidence: $EVIDENCE" >&2
  exit 2
fi

status="refused"
if grep -q ':status accepted' "$EVIDENCE"; then
  status="accepted"
elif grep -q ':status refused' "$EVIDENCE"; then
  status="refused"
else
  echo "emit-manifest: evidence has no :status" >&2
  exit 2
fi

if [[ "$status" != "accepted" ]]; then
  # Central rule: refused or missing evidence ⇒ empty earned, refused manifest.
  body=$(cat <<EOF
(manifest
  :schema-version "0.1.0"
  :program "panoply-core"
  :backend "${BACKEND}"
  :status refused
  :earned ()
  :unearned (total-correctness memory-safety confluence)
  :composition-rules ())
EOF
)
else
  echo "emit-manifest: accepted evidence is not produced by any checker yet" >&2
  exit 1
fi

if [[ -n "$OUT" ]]; then
  printf '%s\n' "$body" > "$OUT"
else
  printf '%s\n' "$body"
fi
