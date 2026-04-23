#!/usr/bin/env bash
# Prove the brains installed in this workspace are alive.
# By default, reads local evidence/brain/STATE.json and evidence/brain/brains.json
# and prints a local status snapshot plus per-brain labels and the last-tick timestamp.
# Pass --remote to additionally call the health_check MCP tool using the
# install ID recorded in evidence/brain/install.json.

set -euo pipefail

WORKSPACE="$(pwd)"
STATE="$WORKSPACE/evidence/brain/STATE.json"
REGISTRY="$WORKSPACE/evidence/brain/brains.json"
INSTALL="$WORKSPACE/evidence/brain/install.json"
MCP_ENDPOINT="https://brainofbrains.ai/mcp"
REMOTE="no"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)
      REMOTE="yes"
      shift
      ;;
    --endpoint)
      MCP_ENDPOINT="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ ! -f "$REGISTRY" ]]; then
  echo "FAIL: brain registry not found at $REGISTRY" >&2
  echo "  run scripts/install.sh first." >&2
  exit 1
fi

echo "[brainofbrains] local health snapshot"

if [[ -x "$WORKSPACE/bin/brain" ]]; then
  "$WORKSPACE/bin/brain" status
  echo
else
  echo "[brainofbrains] bin/brain not available; reading STATE + registry directly"
  if [[ -f "$STATE" ]]; then
    if command -v jq >/dev/null 2>&1; then
      jq '{lastTick: .lastTick.ts, biv: .lastTick.bivScore, delta: .lastTick.bivDelta}' "$STATE"
    else
      cat "$STATE"
    fi
  else
    echo "FAIL: $STATE not present — no tick has run yet." >&2
    exit 1
  fi
fi

echo "[brainofbrains] per-brain status"
if command -v jq >/dev/null 2>&1; then
  jq -r '.brains[] | "  \(.name | tostring) [\(.role)]: \(.status) (value=\(.value // "—"), threshold=\(.thresholdLabel // "—"))"' "$REGISTRY"
  echo
  FAIL_COUNT="$(jq '[.brains[] | select(.status == "breach" or .status == "unwired")] | length' "$REGISTRY")"
  OK_COUNT="$(jq '[.brains[] | select(.status == "in-band")] | length' "$REGISTRY")"
  TOTAL="$(jq '.summary.total' "$REGISTRY")"
  echo "[brainofbrains] summary: $OK_COUNT in-band, $FAIL_COUNT needing attention, $TOTAL total"
else
  cat "$REGISTRY"
fi

if [[ "$REMOTE" != "yes" ]]; then
  echo
  echo "[brainofbrains] local check complete."
  echo "  pass --remote to additionally poll $MCP_ENDPOINT/health_check (requires install.json)."
  exit 0
fi

if [[ ! -f "$INSTALL" ]]; then
  echo "FAIL: $INSTALL not found; cannot call remote health_check without an install ID." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "FAIL: curl not available; cannot reach remote MCP." >&2
  exit 1
fi

INSTALL_ID=""
if command -v jq >/dev/null 2>&1; then
  INSTALL_ID="$(jq -r '.install_id // empty' "$INSTALL")"
fi

if [[ -z "$INSTALL_ID" ]]; then
  echo "FAIL: install_id missing from $INSTALL." >&2
  exit 1
fi

echo
echo "[brainofbrains] calling remote health_check for install_id=$INSTALL_ID"
curl -fsS --max-time 30 \
  -H "Content-Type: application/json" \
  -d "{\"install_id\": \"$INSTALL_ID\"}" \
  "$MCP_ENDPOINT/health_check"
echo
