#!/usr/bin/env bash
# Install or refresh the AI Performance Claude skill under ~/.claude/skills.
# Default path: install the published KostAI package globally, then symlink
# the packaged skill into the user's Claude skills directory.

set -euo pipefail

PKG="@sapperjohn/kostai"
KOSTAI_VERSION_RANGE="${KOSTAI_VERSION_RANGE:-^0.5.2}"
KOSTAI_NPM_SPEC="${KOSTAI_NPM_SPEC:-${PKG}@${KOSTAI_VERSION_RANGE}}"
CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
TARGET_DIR="${CLAUDE_SKILLS_DIR}/cost-optimization"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COPY_MODE=0

if ! command -v npm >/dev/null 2>&1; then
  echo "error: npm not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --copy)
      COPY_MODE=1
      shift
      ;;
    --help|-h)
      cat <<'EOF'
Usage: scripts/install-claude-skill.sh [--copy]

Installs the published KostAI package globally, then makes the
AI Performance skill available to Claude Code under ~/.claude/skills.

Options:
  --copy   copy the skill directory instead of creating a symlink
EOF
      exit 0
      ;;
    *)
      echo "error: unknown flag: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -x "$SCRIPT_DIR/registry-gate.sh" ]]; then
  "$SCRIPT_DIR/registry-gate.sh"
fi

echo "[cost-optimization] installing $KOSTAI_NPM_SPEC"
npm install -g "$KOSTAI_NPM_SPEC"

GLOBAL_ROOT="${KOSTAI_GLOBAL_ROOT:-$(npm root -g)}"
SOURCE_DIR="$GLOBAL_ROOT/@sapperjohn/kostai/skills/cost-optimization"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "error: installed skill files not found at $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$CLAUDE_SKILLS_DIR"

if [[ -e "$TARGET_DIR" && ! -L "$TARGET_DIR" && $COPY_MODE -eq 0 ]]; then
  echo "error: $TARGET_DIR already exists and is not a symlink." >&2
  echo "rerun with --copy if you want to replace it with copied files." >&2
  exit 1
fi

if [[ $COPY_MODE -eq 1 ]]; then
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$SOURCE_DIR/" "$TARGET_DIR/"
  else
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    mkdir -p "$TARGET_DIR"
    cp -R "$SOURCE_DIR/." "$TMP_DIR/"
    find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    cp -R "$TMP_DIR/." "$TARGET_DIR/"
  fi
  echo
  echo "[cost-optimization] copied skill files to:"
  echo "  $TARGET_DIR"
  exit 0
fi

ln -sfn "$SOURCE_DIR" "$TARGET_DIR"

echo
echo "[cost-optimization] Claude skill installed:"
echo "  $TARGET_DIR -> $SOURCE_DIR"
