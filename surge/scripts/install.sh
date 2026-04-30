#!/usr/bin/env bash
# Initialize the canonical SURGE tracker surfaces in the current workspace.
#
# Usage:
# scripts/install.sh
#   Create deliverables/SURGE_TRACKER.json, deliverables/SURGE_TRACKER.md, and
#   deliverables/SURGE_DISCOVERY.md if they do not already exist.

set -euo pipefail

usage() {
  printf '%s\n' \
    "Usage:" \
    "  scripts/install.sh" \
    "" \
    "Create deliverables/SURGE_TRACKER.json, deliverables/SURGE_TRACKER.md, and deliverables/SURGE_DISCOVERY.md if they do not already exist."
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

SCRIPT_DIR="$(cd "${BASH_SOURCE[0]%/*}" && pwd)"
HELPER="$SCRIPT_DIR/lib/surge.mjs"
TRACKER_JSON="${SURGE_TRACKER_JSON:-deliverables/SURGE_TRACKER.json}"
TRACKER_MD="${SURGE_TRACKER_MD:-deliverables/SURGE_TRACKER.md}"
DISCOVERY_MD="${SURGE_DISCOVERY_MD:-deliverables/SURGE_DISCOVERY.md}"

if ! command -v node >/dev/null 2>&1; then
  echo "error: node not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

node "$HELPER" init \
  --tracker-json "$TRACKER_JSON" \
  --tracker-md "$TRACKER_MD" \
  --discovery-md "$DISCOVERY_MD" >/dev/null

echo "[surge] initialized canonical tracker surfaces:"
echo "  - $TRACKER_JSON"
echo "  - $TRACKER_MD"
echo "  - $DISCOVERY_MD"
echo
echo "[surge] next:"
echo "  scripts/scan.sh    — discover candidate deliverables and due/status hints"
echo "  scripts/surge.sh   — add or update canonical rows"
