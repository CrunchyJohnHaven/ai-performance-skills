#!/usr/bin/env bash
# Scan the current repo for LLM call sites and report findings to stdout.
# Review the scan output to identify optimization opportunities (model
# selection, prompt caching, batching, etc.) and apply changes manually.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

echo "[cost-optimization] scanning for LLM call sites..."
npx --yes @sapperjohn/kostai scan "$@"

echo
echo "[cost-optimization] scan complete. output is above."
echo "  review the findings and apply changes manually."
echo "  common optimizations: model downgrade, prompt caching, batching."
