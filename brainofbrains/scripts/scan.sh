#!/usr/bin/env bash
# List the brains currently installed in this workspace.
# Reads evidence/brain/brains.json and prints name, role, formula, threshold,
# value, and status per brain. Also surfaces the last-tick timestamp from
# evidence/brain/STATE.json so the operator can see how fresh the data is.

set -euo pipefail

WORKSPACE="$(pwd)"
REGISTRY="$WORKSPACE/evidence/brain/brains.json"
STATE="$WORKSPACE/evidence/brain/STATE.json"

if [[ ! -f "$REGISTRY" ]]; then
  # Registry missing — check whether bin/brain is present as a fallback hint.
  if [[ -x "$WORKSPACE/bin/brain" ]]; then
    echo "[brainofbrains] registry not found; attempting to regenerate via bin/brain"
    "$WORKSPACE/bin/brain" registry "$@" || true
    exit 0
  fi
  echo "error: brain registry not found at $REGISTRY" >&2
  echo "  run scripts/install.sh first to bootstrap the brain substrate." >&2
  exit 1
fi

if [[ -x "$WORKSPACE/bin/brain" ]]; then
  echo "[brainofbrains] scanning brain registry via bin/brain"
  "$WORKSPACE/bin/brain" registry "$@"
  echo
  "$WORKSPACE/bin/brain" status || true
  exit 0
fi

echo "[brainofbrains] bin/brain not found — run scripts/install.sh to enable full scan; falling back to registry JSON dump"
if command -v jq >/dev/null 2>&1; then
  jq '.summary as $s | "total=\($s.total) inBand=\($s.inBand) breach=\($s.breach) awaiting=\($s.awaitingData) unwired=\($s.unwired)"' "$REGISTRY"
  jq -r '.brains[] | "  \(.name | tostring)\t\(.role)\tvalue=\(.value // "—")\t\(.status)"' "$REGISTRY"
else
  cat "$REGISTRY"
fi

if [[ -f "$STATE" ]]; then
  echo
  echo "[brainofbrains] last tick:"
  if command -v jq >/dev/null 2>&1; then
    jq -r '.lastTick.ts // "unknown"' "$STATE"
  else
    cat "$STATE"
  fi
fi
