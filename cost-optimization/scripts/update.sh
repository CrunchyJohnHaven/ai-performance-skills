#!/usr/bin/env bash
# Refresh the AI Performance skill from the latest published KostAI package.
# Safe default behavior:
# - symlink install: update the global npm package only
# - copied skill outside a git worktree: sync files in place
# - repo checkout / git worktree: do not overwrite local files; print the
#   copy command instead so local development changes are never clobbered

set -euo pipefail

PKG="@sapperjohn/kostai"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if ! command -v npm >/dev/null 2>&1; then
  echo "error: npm not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      CURRENT=$(npx @sapperjohn/kostai --version 2>/dev/null || echo "not installed")
      LATEST=$(npm show @sapperjohn/kostai version 2>/dev/null || echo "unknown")
      echo "current: $CURRENT  latest: $LATEST"
      [[ "$CURRENT" == "$LATEST" ]] && echo "up to date" || echo "update available"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

echo "[cost-optimization] refreshing $PKG"
npm install -g "${PKG}@latest"

GLOBAL_ROOT="$(npm root -g)"
SOURCE_DIR="$GLOBAL_ROOT/@sapperjohn/kostai/skills/cost-optimization"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "error: updated skill files not found at $SOURCE_DIR" >&2
  exit 1
fi

if [[ -L "$SKILL_DIR" ]]; then
  echo
  echo "[cost-optimization] symlink install detected."
  echo "  global package updated; no further action needed."
  exit 0
fi

if git -C "$SKILL_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
  echo
  echo "[cost-optimization] git worktree detected; refusing to overwrite local files."
  echo "  copy manually if desired:"
  echo "  cp -R \"$SOURCE_DIR\" \"\$HOME/.claude/skills/cost-optimization\""
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
echo "[cost-optimization] skill files refreshed in $SKILL_DIR"
