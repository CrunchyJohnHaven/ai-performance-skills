#!/usr/bin/env bash
# Build the SURGE discovery inbox from the current workspace.
#
# Usage:
# scripts/scan.sh
#   Write deliverables/SURGE_DISCOVERY.md from build packets, deliverable
#   README files, send queues, and meeting-note tracker tables.
#
# scripts/scan.sh --root /path/to/workspace
#   Scan a different workspace root and write the discovery inbox there.

set -euo pipefail

usage() {
  printf '%s\n' \
    "Usage:" \
    "  scripts/scan.sh" \
    "" \
    "Write deliverables/SURGE_DISCOVERY.md from build packets, deliverable README files, send queues, and meeting-note tracker tables." \
    "" \
    "scripts/scan.sh --root /path/to/workspace" \
    "  Scan a different workspace root and write the discovery inbox there."
}

ROOT="$(pwd)"
DISCOVERY_MD="${SURGE_DISCOVERY_MD:-deliverables/SURGE_DISCOVERY.md}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    --root)
      ROOT="$2"
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

if ! command -v node >/dev/null 2>&1; then
  echo "error: node not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

mkdir -p "$ROOT/deliverables"

node "$HELPER" scan \
  --root "$ROOT" \
  --out "$DISCOVERY_MD" >/dev/null

OUT_DISPLAY="$DISCOVERY_MD"
if [[ "$OUT_DISPLAY" != /* ]]; then
  OUT_DISPLAY="$ROOT/$OUT_DISPLAY"
fi

echo "[surge] discovery inbox refreshed:"
echo "  - $OUT_DISPLAY"
echo
echo "[surge] next:"
echo "  read deliverables/SURGE_DISCOVERY.md"
echo "  promote confirmed rows with scripts/surge.sh"
