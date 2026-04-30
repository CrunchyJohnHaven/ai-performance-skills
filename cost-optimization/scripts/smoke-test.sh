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

# ── check 5: scripts/demo.sh invocable ──────────────────────────────────────
echo
echo -e "${BOLD}Check 5: scripts/demo.sh (smoke invocation)${RESET}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEMO_SH="$SKILL_DIR/scripts/demo.sh"
if [[ -x "$DEMO_SH" ]]; then
  DEMO_OUTPUT=$(bash "$DEMO_SH" 2>&1) || true
  if [[ -n "$DEMO_OUTPUT" ]]; then
    pass "demo.sh ran and produced output"
    info "$DEMO_OUTPUT"
    record "scripts/demo.sh invocable" "PASS"
  else
    warn "demo.sh ran but produced no output"
    record "scripts/demo.sh invocable" "WARN"
  fi
else
  fail "scripts/demo.sh not found or not executable at $DEMO_SH"
  record "scripts/demo.sh invocable" "FAIL"
fi

# ── check 6: scripts/proof.sh --help exits 0 ────────────────────────────────
echo
echo -e "${BOLD}Check 6: scripts/proof.sh --help${RESET}"
PROOF_SH="$SKILL_DIR/scripts/proof.sh"
if [[ -x "$PROOF_SH" ]]; then
  PROOF_OUTPUT=$(bash "$PROOF_SH" --help 2>&1)
  PROOF_EXIT=$?
  if [[ $PROOF_EXIT -eq 0 ]]; then
    pass "proof.sh --help exited 0"
    info "$PROOF_OUTPUT"
    record "scripts/proof.sh --help" "PASS"
  else
    fail "proof.sh --help exited $PROOF_EXIT"
    info "$PROOF_OUTPUT"
    record "scripts/proof.sh --help" "FAIL"
  fi
else
  fail "scripts/proof.sh not found or not executable at $PROOF_SH"
  record "scripts/proof.sh --help" "FAIL"
fi

# ── check 7: scripts/feedback.sh --help exits 0 ─────────────────────────────
echo
echo -e "${BOLD}Check 7: scripts/feedback.sh --help${RESET}"
FEEDBACK_SH="$SKILL_DIR/scripts/feedback.sh"
if [[ -x "$FEEDBACK_SH" ]]; then
  FEEDBACK_OUTPUT=$(bash "$FEEDBACK_SH" --help 2>&1)
  FEEDBACK_EXIT=$?
  if [[ $FEEDBACK_EXIT -eq 0 ]]; then
    pass "feedback.sh --help exited 0"
    info "$FEEDBACK_OUTPUT"
    record "scripts/feedback.sh --help" "PASS"
  else
    fail "feedback.sh --help exited $FEEDBACK_EXIT"
    info "$FEEDBACK_OUTPUT"
    record "scripts/feedback.sh --help" "FAIL"
  fi
else
  fail "scripts/feedback.sh not found or not executable at $FEEDBACK_SH"
  record "scripts/feedback.sh --help" "FAIL"
fi

# ── check 8: package-elastic-pilot-zip.sh --help exits 0 ────────────────────
echo
echo -e "${BOLD}Check 8: scripts/package-elastic-pilot-zip.sh --help${RESET}"
ZIP_SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZIP_SH="$ZIP_SKILL_DIR/scripts/package-elastic-pilot-zip.sh"
if [[ -x "$ZIP_SH" ]]; then
  ZIP_HELP=$(bash "$ZIP_SH" --help 2>&1)
  ZIP_EXIT=$?
  if [[ $ZIP_EXIT -eq 0 ]]; then
    pass "package-elastic-pilot-zip.sh --help exited 0"
    info "$ZIP_HELP"
    record "scripts/package-elastic-pilot-zip.sh --help" "PASS"
  else
    fail "package-elastic-pilot-zip.sh --help exited $ZIP_EXIT"
    info "$ZIP_HELP"
    record "scripts/package-elastic-pilot-zip.sh --help" "FAIL"
  fi
else
  fail "package-elastic-pilot-zip.sh not found or not executable at $ZIP_SH"
  record "scripts/package-elastic-pilot-zip.sh --help" "FAIL"
fi

# ── check 9: scripts/pilot-complete.sh --help exits 0 ───────────────────────
echo
echo -e "${BOLD}Check 9: scripts/pilot-complete.sh --help${RESET}"
PC_SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PC_SH="$PC_SKILL_DIR/scripts/pilot-complete.sh"
if [[ -x "$PC_SH" ]]; then
  PC_OUT=$(bash "$PC_SH" --help 2>&1)
  PC_EXIT=$?
  if [[ $PC_EXIT -eq 0 ]]; then
    pass "pilot-complete.sh --help exited 0"
    info "$PC_OUT"
    record "scripts/pilot-complete.sh --help" "PASS"
  else
    fail "pilot-complete.sh --help exited $PC_EXIT"
    info "$PC_OUT"
    record "scripts/pilot-complete.sh --help" "FAIL"
  fi
else
  fail "pilot-complete.sh not found or not executable at $PC_SH"
  record "scripts/pilot-complete.sh --help" "FAIL"
fi

# ── check 10: scripts/pilot-30d-report.sh --help exits 0 ────────────────────
echo
echo -e "${BOLD}Check 10: scripts/pilot-30d-report.sh --help${RESET}"
P30_SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
P30_SH="$P30_SKILL_DIR/scripts/pilot-30d-report.sh"
if [[ -x "$P30_SH" ]]; then
  P30_OUT=$(bash "$P30_SH" --help 2>&1)
  P30_EXIT=$?
  if [[ $P30_EXIT -eq 0 ]]; then
    pass "pilot-30d-report.sh --help exited 0"
    info "$P30_OUT"
    record "scripts/pilot-30d-report.sh --help" "PASS"
  else
    fail "pilot-30d-report.sh --help exited $P30_EXIT"
    info "$P30_OUT"
    record "scripts/pilot-30d-report.sh --help" "FAIL"
  fi
else
  fail "pilot-30d-report.sh not found or not executable at $P30_SH"
  record "scripts/pilot-30d-report.sh --help" "FAIL"
fi

# ── summary ──────────────────────────────────────────────────────────────────
echo
echo -e "${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "${BOLD}Smoke-test summary${RESET}"
echo -e "${BOLD}────────────────────────────────────────────────────${RESET}"

N_PASS_TOTAL=0
N_TOTAL=${#CHECK_NAMES[@]}

for i in "${!CHECK_NAMES[@]}"; do
  name="${CHECK_NAMES[$i]}"
  result="${CHECK_RESULTS[$i]}"
  case "$result" in
    PASS) echo -e "  ${GREEN}PASS${RESET}  $name"; N_PASS_TOTAL=$((N_PASS_TOTAL + 1)) ;;
    WARN) echo -e "  ${YELLOW}WARN${RESET}  $name" ;;
    FAIL) echo -e "  ${RED}FAIL${RESET}  $name" ;;
  esac
done

echo -e "${BOLD}────────────────────────────────────────────────────${RESET}"
echo -e "${BOLD}${N_PASS_TOTAL}/${N_TOTAL} checks passed${RESET}"
echo -e "${BOLD}────────────────────────────────────────────────────${RESET}"

if [[ $CRITICAL_FAILURE -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}All critical checks passed.${RESET}"
else
  echo -e "${RED}${BOLD}One or more critical checks failed. See FAIL lines above.${RESET}"
fi

echo

exit $CRITICAL_FAILURE
