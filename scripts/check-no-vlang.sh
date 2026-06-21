#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# check-no-vlang.sh — enforce "the V language is banned in the estate".
#
# Estate rule: V (vlang.io) is banned; use Rust (or, for the typed FFI seam,
# Zig). Zig is an ALLOWED estate language and is NOT flagged by this check.
#
# Detection is content/manifest based, NOT extension based: the `.v` file
# extension is intentionally NOT used as a marker because Coq/Rocq theorem
# files share that extension (e.g. verification/proofs/coq/*.v) and are
# explicitly exempt. V is detected by:
#   * its module manifest `v.mod` (the canonical estate `vmod_detected` marker); and
#   * explicit textual `vlang` / `v-lang` references in tracked files.
#
# Excludes:
#   .git/, node_modules/ (vcs / vendored internals)
#   affinescript/ (a separately-licensed subtree; not estate-managed here)
#
# Exit codes:
#   0 — no V-lang references found
#   1 — V-lang references found (treat as drift)
#   2 — usage / setup error

set -euo pipefail

REPO_ROOT="${1:-.}"

# Textual patterns that uniquely indicate V (vlang.io) code, scaffolding, or
# naming. Zig, Rust, and Coq `.v` are deliberately NOT matched.
PATTERNS=(
    'vlang'
    'v-lang'
    'vlang\.io'
)

PATTERN_OR=$(IFS='|'; echo "${PATTERNS[*]}")

# Files that legitimately name "vlang" while documenting the ban itself.
DOC_EXCLUSIONS=(
    "estate-rules.yml"             # the workflow that calls this script
    "check-no-vlang.sh"            # this script itself
    "PLAYBOOK.a2ml"                # documents the [rsr-repo-skeleton] rules
    "feedback_v_lang_banned.md"    # memory entry documenting the ban
)

EXCLUDE_ARGS=()
for f in "${DOC_EXCLUSIONS[@]}"; do
    EXCLUDE_ARGS+=(--exclude="$f")
done

# Content references to V-lang.
HITS=$(grep -rni -E "$PATTERN_OR" "$REPO_ROOT" \
    --exclude-dir=.git \
    --exclude-dir=affinescript \
    --exclude-dir=node_modules \
    "${EXCLUDE_ARGS[@]}" \
    2>/dev/null || true)

# V module manifests (unambiguous V marker, false-positive free).
VMOD=$(find "$REPO_ROOT" -name 'v.mod' -not -path '*/.git/*' -not -path '*/affinescript/*' 2>/dev/null || true)

if [ -z "$HITS" ] && [ -z "$VMOD" ]; then
    echo "PASS: no V-lang references"
    exit 0
fi

COUNT=0
{
    echo "FAIL: V-lang reference(s) found (estate rule: the V language is banned):"
    if [ -n "$VMOD" ]; then
        echo "$VMOD" | sed 's|^|  v.mod: |'
        COUNT=$((COUNT + $(echo "$VMOD" | wc -l)))
    fi
    if [ -n "$HITS" ]; then
        echo "$HITS" | sed 's|^|  |'
    fi
    echo ""
    echo "V has been replaced by Rust (and Zig for the typed FFI seam). Remove these references."
} >&2
exit 1
