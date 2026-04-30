#!/usr/bin/env bash
# Build elastic-ai-performance-skill-pilot.zip for employee pilot distribution.
# Output: dist/elastic-ai-performance-skill-pilot.zip (repo root) unless --out is set.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
DEFAULT_ZIP="$REPO_ROOT/dist/elastic-ai-performance-skill-pilot.zip"
OUT_ZIP="$DEFAULT_ZIP"
README_SRC="$SKILL_DIR/assets/PILOT_README.txt"
PROMPT_SRC="$SKILL_DIR/assets/elastic-pilot-participant-prompt.txt"
START_HERE_SRC="$SKILL_DIR/assets/START_HERE.txt"

usage() {
  sed -n '1,22p' <<'EOF'
Usage: package-elastic-pilot-zip.sh [--out <path.zip>] [--help]

  --out <path>   Write the zip here (default: <repo>/dist/elastic-ai-performance-skill-pilot.zip)
  -h, --help     Show this help

Requires: zip(1). Run from any cwd.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --out)
      OUT_ZIP="${2:?--out requires a path}"
      shift 2
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v zip >/dev/null 2>&1; then
  echo "error: zip(1) not found. Install zip or use another archiver." >&2
  exit 1
fi

if [[ ! -f "$README_SRC" ]]; then
  echo "error: missing $README_SRC" >&2
  exit 1
fi

if [[ ! -f "$PROMPT_SRC" ]]; then
  echo "error: missing $PROMPT_SRC" >&2
  exit 1
fi

if [[ ! -f "$START_HERE_SRC" ]]; then
  echo "error: missing $START_HERE_SRC" >&2
  exit 1
fi

if [[ ! -f "$SKILL_DIR/SKILL.md" ]]; then
  echo "error: skill root missing SKILL.md at $SKILL_DIR" >&2
  exit 1
fi

TMP="$(mktemp -d "${TMPDIR:-/tmp}/elastic-pilot-zip.XXXXXX")"
cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT

mkdir -p "$TMP/stage"
cp "$START_HERE_SRC" "$TMP/stage/START_HERE.txt"
cp "$README_SRC" "$TMP/stage/PILOT_README.txt"
cp "$PROMPT_SRC" "$TMP/stage/ELASTIC_PILOT_PROMPT.txt"
cp -R "$SKILL_DIR" "$TMP/stage/cost-optimization"

mkdir -p "$(dirname "$OUT_ZIP")"
(
  cd "$TMP/stage"
  zip -r -q "$OUT_ZIP" START_HERE.txt PILOT_README.txt ELASTIC_PILOT_PROMPT.txt cost-optimization -x "*.DS_Store" -x "*/.git/*"
)

echo "[package-elastic-pilot-zip] wrote $(wc -c <"$OUT_ZIP" | tr -d ' ') bytes -> $OUT_ZIP"
unzip -tqq "$OUT_ZIP" >/dev/null
echo "[package-elastic-pilot-zip] zip integrity check OK"
