#!/usr/bin/env bash
# Refresh the Brain Orchestration skill from the latest published package.
# Safe default behavior:
# - symlink install: update the global npm package only
# - copied skill outside a git worktree: sync files in place
# - repo checkout / git worktree: do not overwrite local files; print the
#   copy command instead so local development changes are never clobbered

set -euo pipefail

PKG="@sapperjohn/brainofbrains"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if ! command -v npm >/dev/null 2>&1; then
  echo "error: npm not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

echo "[brainofbrains] refreshing $PKG"
npm install -g "${PKG}@latest"

GLOBAL_ROOT="$(npm root -g)"
SOURCE_DIR="$GLOBAL_ROOT/@sapperjohn/brainofbrains/skills/brainofbrains"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "error: updated skill files not found at $SOURCE_DIR" >&2
  exit 1
fi

if [[ -L "$SKILL_DIR" ]]; then
  echo
  echo "[brainofbrains] symlink install detected."
  echo "  global package updated; no further action needed."
  exit 0
fi

if git -C "$SKILL_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
  echo
  echo "[brainofbrains] git worktree detected; refusing to overwrite local files."
  echo "  copy manually if desired:"
  echo "  cp -R \"$SOURCE_DIR\" \"\$HOME/.claude/skills/brainofbrains\""
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
echo "[brainofbrains] skill files refreshed in $SKILL_DIR"
