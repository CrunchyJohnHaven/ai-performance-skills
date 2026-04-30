#!/usr/bin/env bash
# Refresh the SURGE skill from the latest published KostAI package or from a
# checked-out source folder.
# Safe default behavior:
# - symlink install: update the global npm package only
# - copied skill outside a git worktree: sync files in place
# - repo checkout / git worktree: do not overwrite local files; print the
#   copy command instead so local development changes are never clobbered

set -euo pipefail

PKG="${SURGE_PKG:-@sapperjohn/kostai}"
SOURCE_DIR="${SURGE_SOURCE_DIR:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REQUIRED_FILES=(
  "SKILL.md"
  "assets/install-message.md"
  "agents/openai.yaml"
  "references/tracker-schema.md"
  "references/workflow.md"
  "references/elastic-notes.md"
  "scripts/install.sh"
  "scripts/scan.sh"
  "scripts/surge.sh"
  "scripts/update.sh"
  "scripts/lib/surge.mjs"
)

validate_source_dir() {
  local dir="$1"
  local source_label="$2"
  local skill_name="$3"
  shift 3

  local missing=()
  local rel
  for rel in "$@"; do
    if [[ ! -s "$dir/$rel" ]]; then
      missing+=("$rel")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    return 0
  fi

  echo "error: $source_label is missing expected $skill_name skill files: $dir" >&2
  for rel in "${missing[@]}"; do
    echo "  - $rel" >&2
  done
  if [[ "$source_label" == *_SOURCE_DIR ]]; then
    echo "  point $source_label at the $skill_name skill root, not a parent directory." >&2
  fi
  exit 1
}

if ! command -v npm >/dev/null 2>&1; then
  echo "error: npm not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

if [[ -n "$SOURCE_DIR" ]]; then
  if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "error: SURGE_SOURCE_DIR does not exist: $SOURCE_DIR" >&2
    exit 1
  fi
  validate_source_dir \
    "$SOURCE_DIR" \
    "SURGE_SOURCE_DIR" \
    "surge" \
    "${REQUIRED_FILES[@]}"
  echo "[surge] refreshing from local source: $SOURCE_DIR"
else
  if ! npm view "$PKG" version >/dev/null 2>&1; then
    echo "error: npm package $PKG is not published." >&2
    echo "  set SURGE_SOURCE_DIR=/path/to/ai-performance-skills/skills/surge" >&2
    echo "  or refresh this skill via catalog republish." >&2
    exit 1
  fi

  echo "[surge] refreshing $PKG"
  npm install -g "${PKG}@latest"

  GLOBAL_ROOT="$(npm root -g)"
  SOURCE_DIR="$GLOBAL_ROOT/$PKG/skills/surge"

  if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "error: updated skill files not found at $SOURCE_DIR" >&2
    echo "  the published package may not ship the skills/ directory yet." >&2
    echo "  set SURGE_SOURCE_DIR=/path/to/ai-performance-skills/skills/surge" >&2
    echo "  or refresh this skill via catalog republish." >&2
    exit 1
  fi

  validate_source_dir \
    "$SOURCE_DIR" \
    "updated package contents" \
    "surge" \
    "${REQUIRED_FILES[@]}"
fi

if [[ -L "$SKILL_DIR" ]]; then
  echo
  echo "[surge] symlink install detected."
  echo "  source location is already authoritative; no in-place copy needed."
  exit 0
fi

if git -C "$SKILL_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
  echo
  echo "[surge] git worktree detected; refusing to overwrite local files."
  echo "  copy manually if desired:"
  echo "  cp -R \"$SOURCE_DIR\" \"\$HOME/.claude/skills/surge\""
  exit 0
fi

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$SOURCE_DIR/" "$SKILL_DIR/"
else
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  cp -R "$SOURCE_DIR/." "$TMP_DIR/"
  find "$SKILL_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  cp -R "$TMP_DIR/." "$SKILL_DIR/"
fi

echo
echo "[surge] skill files refreshed in $SKILL_DIR"
