#!/usr/bin/env bash
# Run all three skill diagnostics in one pass and print a pass/fail summary.
# Usage: scripts/diagnose.sh [--verbose]
set -euo pipefail

VERBOSE="no"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose|-v) VERBOSE="yes"; shift ;;
    --help|-h)    sed -n '2,4p' "$0"; exit 0 ;;
    *) shift ;;
  esac
done

PASS=0; FAIL=0

run_check() {
  local label="$1"; shift
  if [[ "$VERBOSE" == "yes" ]]; then
    if "$@"; then
      echo "  PASS  $label"
      PASS=$((PASS + 1))
    else
      echo "  FAIL  $label"
      FAIL=$((FAIL + 1))
    fi
  else
    if "$@" >/dev/null 2>&1; then
      echo "  PASS  $label"
      PASS=$((PASS + 1))
    else
      echo "  FAIL  $label"
      FAIL=$((FAIL + 1))
    fi
  fi
}

echo "[diagnose] cost-optimization"
run_check "smoke-test" bash cost-optimization/scripts/smoke-test.sh

echo "[diagnose] brainofbrains"
run_check "doctor" bash brainofbrains/scripts/doctor.sh

echo "[diagnose] elasticjudge"
run_check "judge --help" bash elasticjudge/scripts/judge.sh --help

echo
echo "[diagnose] results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
