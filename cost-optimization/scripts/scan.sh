#!/usr/bin/env bash
# Detect local LLM runtimes (Ollama, LM Studio, OpenAI-compat) and enumerate
# LLM call sites in the current repo. Outputs free local compute that can
# absorb non-frontier work, plus the exact source locations the optimize step
# will target.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

echo "[cost-optimization] scanning local runtimes + repo call sites"
npx --yes @sapperjohn/kostai scan "$@"
