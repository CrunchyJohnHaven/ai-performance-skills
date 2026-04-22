#!/usr/bin/env bash
# Agent-to-agent provisioning flow for a managed BrainOfBrains install.
# Steps:
#   1. POST stack_description to the remote MCP `quote` tool
#   2. Print the returned price and spec; wait for confirmation
#   3. POST payment_token + stack_spec to the remote MCP `provision` tool
#   4. Download signed tarball + install.sh
#
# Opt-in only. The free install path (scripts/install.sh) remains available
# and does not require this flow. If no MCP client is available, prints the
# manual URL the operator can open in a browser instead.

set -euo pipefail

# json_str <value> — emit a JSON-encoded string, no external dependencies required
json_str() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$1" | jq -Rs .
  else
    printf '"%s"' "${1//\"/\\\"}"
  fi
}

MCP_ENDPOINT="https://brainofbrains.ai/mcp"
QUOTE_URL="$MCP_ENDPOINT/quote"
PROVISION_URL="$MCP_ENDPOINT/provision"
FALLBACK_PAGE="https://brainofbrains.ai/"

STACK_DESCRIPTION=""
AUTO_CONFIRM="no"
PAYMENT_TOKEN="${BRAINOFBRAINS_PAYMENT_TOKEN:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y)
      AUTO_CONFIRM="yes"
      shift
      ;;
    --payment-token)
      PAYMENT_TOKEN="$2"
      shift 2
      ;;
    --endpoint)
      MCP_ENDPOINT="$2"
      QUOTE_URL="$MCP_ENDPOINT/quote"
      PROVISION_URL="$MCP_ENDPOINT/provision"
      shift 2
      ;;
    *)
      if [[ -z "$STACK_DESCRIPTION" ]]; then
        STACK_DESCRIPTION="$1"
      else
        STACK_DESCRIPTION="$STACK_DESCRIPTION $1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$STACK_DESCRIPTION" ]]; then
  echo "usage: scripts/provision.sh \"<stack description>\" [--yes] [--payment-token TOKEN]" >&2
  echo "  example: scripts/provision.sh \"elastic VE org, one stakeholder brain per AE, one product brain per offering\"" >&2
  exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "error: curl not available and no MCP client bundled." >&2
  echo "  open $FALLBACK_PAGE in a browser to purchase and install manually." >&2
  exit 1
fi

echo "[brainofbrains] requesting quote from $QUOTE_URL"
QUOTE_RESPONSE="$(curl -fsS --max-time 30 \
  -H "Content-Type: application/json" \
  -d "{\"stack_description\": $(json_str "$STACK_DESCRIPTION")}" \
  "$QUOTE_URL" || true)"

if [[ -z "$QUOTE_RESPONSE" ]]; then
  echo "[brainofbrains] quote endpoint unreachable or not yet deployed."
  echo "  fallback: open $FALLBACK_PAGE in a browser to purchase and install manually."
  exit 1
fi

echo
echo "[brainofbrains] quote:"
echo "$QUOTE_RESPONSE"
echo

if [[ "$AUTO_CONFIRM" != "yes" ]]; then
  printf "[brainofbrains] proceed with provision? (y/N) "
  read -r REPLY
  case "$REPLY" in
    y|Y|yes|YES) ;;
    *)
      echo "[brainofbrains] provisioning cancelled."
      exit 0
      ;;
  esac
fi

if [[ -z "$PAYMENT_TOKEN" ]]; then
  echo "[brainofbrains] no payment token supplied; the remote MCP may return an x402 challenge."
  echo "  set BRAINOFBRAINS_PAYMENT_TOKEN or pass --payment-token TOKEN to complete payment."
fi

echo "[brainofbrains] calling provision on $PROVISION_URL"
PROVISION_RESPONSE="$(curl -fsS --max-time 60 \
  -H "Content-Type: application/json" \
  -H "X-Payment-Token: ${PAYMENT_TOKEN:-}" \
  -d "{\"stack_description\": $(json_str "$STACK_DESCRIPTION")}" \
  "$PROVISION_URL" || true)"

if [[ -z "$PROVISION_RESPONSE" ]]; then
  echo "error: provision endpoint unreachable." >&2
  exit 1
fi

echo
echo "[brainofbrains] provision response:"
echo "$PROVISION_RESPONSE"
echo
echo "[brainofbrains] follow install.sh in the response to complete installation."
echo "  after install, run scripts/health.sh --remote to verify the first BIV tick."
