#!/usr/bin/env bash
# smoke-test.sh — verify the AI Performance skill is wired up correctly
# Usage: bash scripts/smoke-test.sh
# Exit: 0 if all critical checks pass, 1 if any critical check fails

set -uo pipefail

# ── colour helpers ──────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

pass()  { echo -e "${GREEN}[PASS]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
fail()  { echo -e "${RED}[FAIL]${RESET} $*"; }
info()  { echo -e "      $*"; }

# ── result tracking ─────────────────────────────────────────────────────────
declare -a CHECK_NAMES=()
declare -a CHECK_RESULTS=()   # PASS | WARN | FAIL
CRITICAL_FAILURE=0

record() {
  local name="$1" result="$2"
  CHECK_NAMES+=("$name")
  CHECK_RESULTS+=("$result")
  if [[ "$result" == "FAIL" ]]; then
    CRITICAL_FAILURE=1
  fi
}

# ── check 1: kostai CLI available ───────────────────────────────────────────
echo
echo -e "${BOLD}Check 1: npx @sapperjohn/kostai --version${RESET}"
VERSION_OUTPUT=$(npx --yes @sapperjohn/kostai --version 2>&1) || true
if echo "$VERSION_OUTPUT" | grep -Eq '[0-9]+\.[0-9]+'; then
  pass "kostai is available"
  info "Version: $VERSION_OUTPUT"
  record "kostai --version" "PASS"
else
  fail "kostai not found or returned unexpected output"
  info "Output: $VERSION_OUTPUT"
  record "kostai --version" "FAIL"
fi

# ── check 2: ai-cost.config.json present (non-critical) ─────────────────────
echo
echo -e "${BOLD}Check 2: ai-cost.config.json in current directory${RESET}"
if [[ -f "ai-cost.config.json" ]]; then
  pass "ai-cost.config.json found"
  record "ai-cost.config.json present" "PASS"
else
  warn "ai-cost.config.json not found — run scripts/install.sh or 'npx @sapperjohn/kostai init' first"
  record "ai-cost.config.json present" "WARN"
fi

# ── check 3: kostai doctor ──────────────────────────────────────────────────
echo
echo -e "${BOLD}Check 3: npx @sapperjohn/kostai doctor${RESET}"
DOCTOR_OUTPUT=$(npx --yes @sapperjohn/kostai doctor 2>&1) || true
if [[ -n "$DOCTOR_OUTPUT" ]]; then
  pass "doctor ran and returned output"
  info "$DOCTOR_OUTPUT"
  record "kostai doctor" "PASS"
else
  warn "doctor produced no output"
  record "kostai doctor" "WARN"
fi

# ── check 4: kostai scan exits 0 (critical) ─────────────────────────────────
echo
echo -e "${BOLD}Check 4: npx @sapperjohn/kostai scan (must exit 0)${RESET}"
SCAN_OUTPUT=$(npx --yes @sapperjohn/kostai scan 2>&1)
SCAN_EXIT=$?
if [[ $SCAN_EXIT -eq 0 ]]; then
  pass "scan exited 0"
  info "$SCAN_OUTPUT"
  record "kostai scan exit 0" "PASS"
else
  fail "scan exited $SCAN_EXIT"
  info "$SCAN_OUTPUT"
  record "kostai scan exit 0" "FAIL"
fi

# ── summary ──────────────────────────────────────────────────────────────────
echo
echo -e "${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "${BOLD}Smoke-test summary${RESET}"
echo -e "${BOLD}────────────────────────────────────────────────────${RESET}"

for i in "${!CHECK_NAMES[@]}"; do
  name="${CHECK_NAMES[$i]}"
  result="${CHECK_RESULTS[$i]}"
  case "$result" in
    PASS) echo -e "  ${GREEN}PASS${RESET}  $name" ;;
    WARN) echo -e "  ${YELLOW}WARN${RESET}  $name" ;;
    FAIL) echo -e "  ${RED}FAIL${RESET}  $name" ;;
  esac
done

echo -e "${BOLD}────────────────────────────────────────────────────${RESET}"

if [[ $CRITICAL_FAILURE -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}All critical checks passed.${RESET}"
else
  echo -e "${RED}${BOLD}One or more critical checks failed. See FAIL lines above.${RESET}"
fi

echo

exit $CRITICAL_FAILURE
