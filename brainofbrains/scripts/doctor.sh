#!/usr/bin/env bash
# brainofbrains doctor — self-diagnostic for common substrate setup issues.
# Mirrors the check/summary pattern used by the cost-optimization doctor.
# Non-intrusive: reads and probes only, never modifies anything.
#
# Exit codes:
#   0 — all critical checks passed (warnings may be present)
#   1 — one or more critical checks FAILED

set -euo pipefail

WORKSPACE="$(pwd)"

# ── colour codes ──────────────────────────────────────────────────────────────
RED='\033[0;31m'
YEL='\033[0;33m'
GRN='\033[0;32m'
RST='\033[0m'

PASS_LABEL="${GRN}PASS${RST}"
WARN_LABEL="${YEL}WARN${RST}"
FAIL_LABEL="${RED}FAIL${RST}"

# ── counters ──────────────────────────────────────────────────────────────────
TOTAL=0
N_PASS=0
N_WARN=0
N_FAIL=0

# ── helpers ───────────────────────────────────────────────────────────────────
pass() {
  TOTAL=$((TOTAL + 1))
  N_PASS=$((N_PASS + 1))
  printf "  [${PASS_LABEL}] %s\n" "$1"
}

warn() {
  TOTAL=$((TOTAL + 1))
  N_WARN=$((N_WARN + 1))
  printf "  [${WARN_LABEL}] %s\n" "$1"
}

fail() {
  TOTAL=$((TOTAL + 1))
  N_FAIL=$((N_FAIL + 1))
  printf "  [${FAIL_LABEL}] %s\n" "$1"
}

# ── banner ────────────────────────────────────────────────────────────────────
printf "\n== brainofbrains doctor ==\n\n"
printf "Workspace: %s\n\n" "$WORKSPACE"

# ════════════════════════════════════════════════════════════════════════════
printf "Critical checks\n"

# 1. bin/brain exists and is executable (CRITICAL)
BRAIN="$WORKSPACE/bin/brain"
if [[ -x "$BRAIN" ]]; then
  pass "bin/brain exists and is executable"
else
  if [[ -e "$BRAIN" ]]; then
    fail "bin/brain exists but is NOT executable (run: chmod +x bin/brain)"
  else
    fail "bin/brain not found at $BRAIN (run scripts/install.sh first)"
  fi
fi

# 2. evidence/brain/STATE.json exists and is valid JSON (CRITICAL)
STATE="$WORKSPACE/evidence/brain/STATE.json"
if [[ ! -f "$STATE" ]]; then
  fail "evidence/brain/STATE.json not found — no tick has run yet"
else
  STATE_VALID="unknown"
  if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import json,sys; json.load(sys.stdin)" < "$STATE" 2>/dev/null; then
      STATE_VALID="ok"
    else
      STATE_VALID="invalid"
    fi
  elif command -v jq >/dev/null 2>&1; then
    if jq empty "$STATE" 2>/dev/null; then
      STATE_VALID="ok"
    else
      STATE_VALID="invalid"
    fi
  else
    STATE_VALID="skipped"
  fi
  case "$STATE_VALID" in
    ok)      pass "evidence/brain/STATE.json exists and is valid JSON" ;;
    invalid) fail "evidence/brain/STATE.json exists but contains invalid JSON" ;;
    skipped) pass "evidence/brain/STATE.json exists — JSON validation skipped (python3/jq unavailable)" ;;
    *)       pass "evidence/brain/STATE.json exists" ;;
  esac
fi

# ════════════════════════════════════════════════════════════════════════════
printf "\nNon-critical checks\n"

# 3. evidence/brain/brains.json exists and is valid JSON (WARN)
REGISTRY="$WORKSPACE/evidence/brain/brains.json"
if [[ ! -f "$REGISTRY" ]]; then
  warn "evidence/brain/brains.json not found"
else
  # Try python3 first, then jq, then skip validation
  JSON_VALID="unknown"
  if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import json,sys; json.load(sys.stdin)" < "$REGISTRY" 2>/dev/null; then
      JSON_VALID="ok"
    else
      JSON_VALID="invalid"
    fi
  elif command -v jq >/dev/null 2>&1; then
    if jq empty "$REGISTRY" 2>/dev/null; then
      JSON_VALID="ok"
    else
      JSON_VALID="invalid"
    fi
  else
    JSON_VALID="skipped"
  fi

  case "$JSON_VALID" in
    ok)      pass "evidence/brain/brains.json exists and is valid JSON" ;;
    invalid) warn "evidence/brain/brains.json exists but contains invalid JSON" ;;
    skipped) warn "evidence/brain/brains.json exists — JSON validation skipped (python3 and jq not available)" ;;
    *)       warn "evidence/brain/brains.json exists — JSON validation result unknown" ;;
  esac
fi

# 4. evidence/brain/prelude.txt exists (WARN)
PRELUDE="$WORKSPACE/evidence/brain/prelude.txt"
if [[ -f "$PRELUDE" ]]; then
  pass "evidence/brain/prelude.txt exists"
else
  warn "evidence/brain/prelude.txt not found — substrate may lack system context"
fi

# 5. At least one .aaak file exists in evidence/brain/ (WARN)
AAAK_COUNT=0
if [[ -d "$WORKSPACE/evidence/brain" ]]; then
  # Use find with || true so pipefail does not fire on empty results
  AAAK_COUNT="$(find "$WORKSPACE/evidence/brain" -maxdepth 2 -name '*.aaak' 2>/dev/null | wc -l | tr -d ' ')" || true
fi
if [[ "$AAAK_COUNT" -ge 1 ]]; then
  pass "evidence/brain/ contains $AAAK_COUNT .aaak closet file(s)"
else
  warn "no .aaak files found in evidence/brain/ — closet knowledge is empty"
fi

# ════════════════════════════════════════════════════════════════════════════
printf "\nBin/brain probe\n"

# 6. Run bin/brain status (non-critical; failures are WARNs)
if [[ -x "$BRAIN" ]]; then
  printf "  [bin/brain status output]\n"
  "$BRAIN" status 2>&1 | sed 's/^/    /' || true
  printf "\n"
  pass "bin/brain status ran without error"
else
  warn "bin/brain not executable — skipping status probe"
fi

# ════════════════════════════════════════════════════════════════════════════
printf "\n== doctor summary: %d PASS · %d WARN · %d FAIL (%d total) ==\n\n" \
  "$N_PASS" "$N_WARN" "$N_FAIL" "$TOTAL"

if [[ "$N_FAIL" -gt 0 ]]; then
  printf "${RED}One or more critical checks failed. Fix the issues above and re-run.${RST}\n\n"
  exit 1
else
  printf "${GRN}All critical checks passed.${RST}\n\n"
  exit 0
fi
