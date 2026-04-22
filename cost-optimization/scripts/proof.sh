#!/usr/bin/env bash
# Emit a one-page proof of savings from the shadow-mode ledger.
# Produces a markdown report via `kostai report`.
# Usage:
#   scripts/proof.sh                                    # markdown to stdout
#   scripts/proof.sh --audience adnan-cio --date 2026-04-22
#   scripts/proof.sh --last 30d                         # pass-through flags
#
# Recognized flags:
#   --audience <name>   write output to deliverables/<name>-<date>/PROOF.md
#   --date <YYYY-MM-DD> date suffix for the deliverables folder (default: today)
#   --last <period>     time window forwarded to `kostai report` (e.g. 7d, 30d)
#
# Any unrecognized flags are forwarded to `kostai report`.

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
    --help|-h)
      cat <<'EOF'
Usage: scripts/proof.sh [flags] [pass-through-flags]

Recognized flags:
  --audience <name>    write output to deliverables/<name>-<date>/PROOF.md
  --date <YYYY-MM-DD>  date suffix for the deliverables folder (default: today)
  --last <period>      time window forwarded to `kostai report` (e.g. 7d, 30d)

Pass-through flags:
  Any unrecognized flag is forwarded directly to `kostai report`.

Examples:
  scripts/proof.sh
  scripts/proof.sh --audience adnan-cio --date 2026-04-22
  scripts/proof.sh --last 30d
EOF
      exit 0
      ;;
    --audience)
      AUDIENCE="$2"
      shift 2
      ;;
    --date)
      DATE="$2"
      shift 2
      ;;
    --last)
      EXTRA_ARGS+=("--last" "$2")
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
  npx --yes @sapperjohn/kostai report \
    "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}" \
    > "$DELIV_DIR/PROOF.md"

  echo
  echo "[cost-optimization] proof artifact:"
  echo "  $DELIV_DIR/PROOF.md"
else
  npx --yes @sapperjohn/kostai report "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"
fi
