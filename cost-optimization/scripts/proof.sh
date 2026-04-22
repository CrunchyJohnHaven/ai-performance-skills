#!/usr/bin/env bash
# Emit a one-page proof of savings from the shadow-mode ledger.
# Produces markdown on stdout, plus optional HTML and JSON deliverables.
# Usage:
#   scripts/proof.sh                                    # markdown to stdout
#   scripts/proof.sh --audience adnan-cio --date 2026-04-22
#   scripts/proof.sh --rate 0.10 --last 30d             # pass-through flags
#
# Any unrecognized flags are forwarded to `kostai proof`.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

AUDIENCE=""
DATE=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --audience)
      AUDIENCE="$2"
      shift 2
      ;;
    --date)
      DATE="$2"
      shift 2
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ -n "$AUDIENCE" ]]; then
  if [[ -z "$DATE" ]]; then
    DATE="$(date +%Y-%m-%d)"
  fi
  DELIV_DIR="deliverables/${AUDIENCE}-${DATE}"
  mkdir -p "$DELIV_DIR"

  echo "[cost-optimization] writing proof to $DELIV_DIR"
  npx --yes @sapperjohn/kostai proof \
    --html "$DELIV_DIR/PROOF.html" \
    --json "$DELIV_DIR/proof.json" \
    "${EXTRA_ARGS[@]}" \
    > "$DELIV_DIR/PROOF.md"

  echo
  echo "[cost-optimization] proof artifacts:"
  echo "  $DELIV_DIR/PROOF.md"
  echo "  $DELIV_DIR/PROOF.html"
  echo "  $DELIV_DIR/proof.json"
else
  npx --yes @sapperjohn/kostai proof "${EXTRA_ARGS[@]}"
fi
