# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Formal verification — Idris2 only (estate FV language).

proof-check-all: proof-check-idris2 proof-scan-dangerous
    @echo "=== All proof checks complete ==="

proof-check-idris2:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== Checking Idris2 proofs ==="
    if ! command -v idris2 &>/dev/null; then
        echo "SKIP: idris2 not installed"
        exit 0
    fi
    ERRORS=0
    while IFS= read -r f; do
        echo -n "  Checking $f ... "
        if idris2 --check "$f" 2>/dev/null; then
            echo "OK"
        else
            echo "FAIL"
            ERRORS=$((ERRORS + 1))
        fi
    done < <(find verification/proofs/idris2 -name '*.idr' 2>/dev/null)
    if [ "$ERRORS" -gt 0 ]; then
        echo "FAIL: $ERRORS Idris2 proof(s) failed"
        exit 1
    fi
    echo "PASS: All Idris2 proofs verified"

proof-scan-dangerous:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== Scanning for dangerous patterns in proofs ==="
    DANGEROUS=0
    PATTERNS="believe_me|assert_total|postulate|sorry|Admitted|unsafeCoerce|Obj\\.magic"
    while IFS= read -r f; do
        MATCHES=$(grep -nE "$PATTERNS" "$f" 2>/dev/null || true)
        if [ -n "$MATCHES" ]; then
            echo "  DANGEROUS: $f"
            echo "$MATCHES" | sed 's/^/    /'
            DANGEROUS=$((DANGEROUS + 1))
        fi
    done < <(find verification/proofs -name '*.idr' 2>/dev/null)
    if [ "$DANGEROUS" -gt 0 ]; then
        echo "FAIL: $DANGEROUS file(s) contain dangerous patterns"
        exit 1
    fi
    echo "PASS: No dangerous patterns found in proofs"

proof-status:
    #!/usr/bin/env bash
    echo "=== Proof Status ==="
    echo "Idris2: $(find verification/proofs/idris2 -name '*.idr' 2>/dev/null | wc -l) files"
    grep -E "^\| \*Total\*" docs/status/PROOF-STATUS.adoc 2>/dev/null || true
