#!/usr/bin/env bash
# Add or update one canonical row in the SURGE deliverables tracker.
#
# Usage:
# scripts/surge.sh --what "Deliverable" --by "2026-04-23" --pages "2" --audience "Exec review" --format "2-page brief"
#   Add or update one canonical SURGE row.
#
# scripts/surge.sh --priority P0 --what "Deliverable" --by "TBD" --pages "TBD" --audience "TBD" --format "deck" --owner "John" --status "blocked" --source "deliverables/foo.md" --notes "Waiting on canonical path"
#   Add richer metadata while preserving TBD markers for fields that still need clarification.

set -euo pipefail

PRIORITY="P2"
WHAT=""
BY=""
PAGES=""
AUDIENCE=""
FORMAT=""
OWNER=""
STATUS=""
SOURCE=""
NOTES=""

usage() {
  printf '%s\n' \
    "Usage:" \
    "  scripts/surge.sh --what \"Deliverable\" --by \"2026-04-23\" --pages \"2\" --audience \"Exec review\" --format \"2-page brief\"" \
    "" \
    "Add or update one canonical SURGE row." \
    "" \
    "scripts/surge.sh --priority P0 --what \"Deliverable\" --by \"TBD\" --pages \"TBD\" --audience \"TBD\" --format \"deck\" --owner \"John\" --status \"blocked\" --source \"deliverables/foo.md\" --notes \"Waiting on canonical path\"" \
    "  Add richer metadata while preserving TBD markers for fields that still need clarification."
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    --priority)
      PRIORITY="$2"
      shift 2
      ;;
    --what)
      WHAT="$2"
      shift 2
      ;;
    --by)
      BY="$2"
      shift 2
      ;;
    --pages)
      PAGES="$2"
      shift 2
      ;;
    --audience)
      AUDIENCE="$2"
      shift 2
      ;;
    --format)
      FORMAT="$2"
      shift 2
      ;;
    --owner)
      OWNER="$2"
      shift 2
      ;;
    --status)
      STATUS="$2"
      shift 2
      ;;
    --source)
      SOURCE="$2"
      shift 2
      ;;
    --notes)
      NOTES="$2"
      shift 2
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "${BASH_SOURCE[0]%/*}" && pwd)"
HELPER="$SCRIPT_DIR/lib/surge.mjs"
TRACKER_JSON="${SURGE_TRACKER_JSON:-deliverables/SURGE_TRACKER.json}"
TRACKER_MD="${SURGE_TRACKER_MD:-deliverables/SURGE_TRACKER.md}"

if [[ -z "$WHAT" ]]; then
  echo 'error: pass --what "Deliverable"' >&2
  exit 2
fi

if ! command -v node >/dev/null 2>&1; then
  echo "error: node not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

node "$HELPER" upsert \
  --tracker-json "$TRACKER_JSON" \
  --tracker-md "$TRACKER_MD" \
  --priority "$PRIORITY" \
  --what "$WHAT" \
  --by "$BY" \
  --pages "$PAGES" \
  --audience "$AUDIENCE" \
  --format "$FORMAT" \
  --owner "$OWNER" \
  --status "$STATUS" \
  --source "$SOURCE" \
  --notes "$NOTES" >/dev/null

echo "[surge] tracker updated:"
echo "  - $TRACKER_JSON"
echo "  - $TRACKER_MD"
echo "  row: $WHAT"
