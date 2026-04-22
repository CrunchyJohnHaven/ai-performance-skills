#!/usr/bin/env bash
# One-click bootstrap for the cost-optimization skill.
# Wraps `kostai install` — writes ai-cost.config.json, applies safe starter
# patches (prompt cache, prose compress, expensive-model gate), and refreshes
# the savings plan. Idempotent: re-running is safe.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

echo "[cost-optimization] installing @sapperjohn/kostai into $(pwd)"
npx --yes @sapperjohn/kostai install "$@"

echo
echo "[cost-optimization] done."
echo "  next: scripts/scan.sh     — detect local LLM runtimes and call sites"
echo "  then: scripts/optimize.sh — write .kostai/optimizations.md plan"
echo "  then: scripts/proof.sh    — emit a proof-of-savings one-pager"
