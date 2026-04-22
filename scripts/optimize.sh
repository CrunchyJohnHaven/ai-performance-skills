#!/usr/bin/env bash
# Scan the current repo and emit a prioritized optimization plan at
# .kostai/optimizations.md. Each entry names the call site, the technique,
# the expected savings, and the patch snippet. The calling Claude agent reads
# the plan and applies patches in order — one patch per commit so savings can
# be attributed per technique.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

echo "[cost-optimization] writing .kostai/optimizations.md"
npx --yes @sapperjohn/kostai optimize "$@"

if [[ -f .kostai/optimizations.md ]]; then
  echo
  echo "[cost-optimization] plan written to .kostai/optimizations.md"
  echo "  review the file, then apply patches top-down."
  echo "  highest-savings entries are listed first."
fi
