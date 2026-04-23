#!/usr/bin/env bash
# Walk a first-time user through init → scan → report for demo walkthroughs.
# Shows the full workflow end-to-end without claiming measured savings.
# Use this for first-time-user demos or when the ledger is empty.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

echo "[cost-optimization] step 1/3 — initializing kostai"
npx --yes @sapperjohn/kostai init

echo
echo "[cost-optimization] step 2/3 — scanning for LLM call sites"
npx --yes @sapperjohn/kostai scan

echo
echo "[cost-optimization] step 3/3 — generating savings report"
npx --yes @sapperjohn/kostai report

echo
echo "[cost-optimization] demo complete."
echo "  run: scripts/proof.sh    — emit a full proof-of-savings report"
