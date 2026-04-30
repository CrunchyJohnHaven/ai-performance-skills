#!/usr/bin/env bash
# Seed a deterministic before/after workload for demo walkthroughs.
# Runs init -> demo seed -> scan -> proof to show the full workflow end-to-end.
# Use this for first-time-user demos or when the ledger is empty.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

echo "[cost-optimization] step 1/4 — initializing kostai"
npx --yes @sapperjohn/kostai@^0.5.2 init

echo
echo "[cost-optimization] step 2/4 — seeding deterministic before/after workload"
npx --yes @sapperjohn/kostai@^0.5.2 demo --clear

echo
echo "[cost-optimization] step 3/4 — scanning for LLM call sites"
npx --yes @sapperjohn/kostai@^0.5.2 scan

echo
echo "[cost-optimization] step 4/4 — generating proof of savings"
npx --yes @sapperjohn/kostai@^0.5.2 proof

echo
echo "[cost-optimization] demo complete."
echo "  run: scripts/proof.sh    — emit a full proof-of-savings report"
