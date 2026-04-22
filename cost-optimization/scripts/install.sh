#!/usr/bin/env bash
# One-click bootstrap for the cost-optimization skill.
# Wraps `kostai init` — writes ai-cost.config.json and initializes the
# shadow-mode ledger. Idempotent: re-running is safe.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

echo "[cost-optimization] initializing @sapperjohn/kostai in $(pwd)"
npx --yes @sapperjohn/kostai init "$@"

echo
echo "[cost-optimization] done."
echo "  next: scripts/demo.sh     — run a before/after workflow demo"
echo "  then: scripts/optimize.sh — scan for LLM call sites to review"
echo "  then: scripts/proof.sh    — emit a proof-of-savings report"
