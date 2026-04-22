#!/usr/bin/env bash
# Seed a deterministic before/after workload for demo walkthroughs.
# Ten-question benchmark; reproducibly shows a ~92% cost reduction on
# the reference hardware. Use this for first-time-user demos or when
# the ledger is empty.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

echo "[cost-optimization] seeding fresh-install demo (ten-question before/after)"
npx --yes @sapperjohn/kostai pitch "$@"

echo
echo "[cost-optimization] demo complete."
echo "  run: scripts/proof.sh --audience demo --date $(date +%Y-%m-%d)"
echo "  or:  npx kostai open   (live dashboard)"
