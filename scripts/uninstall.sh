#!/usr/bin/env bash
# Remove ai-performance-skills from ~/.claude/skills/.
# Usage: scripts/uninstall.sh [--dry-run]
set -euo pipefail

SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
DRY_RUN="no"
SKILLS=("cost-optimization" "brainofbrains" "elasticjudge")

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN="yes"; shift ;;
    --help|-h) sed -n '2,4p' "$0"; exit 0 ;;
    *) shift ;;
  esac
done

for skill in "${SKILLS[@]}"; do
  target="$SKILLS_DIR/$skill"
  if [[ -d "$target" ]]; then
    if [[ "$DRY_RUN" == "yes" ]]; then
      echo "  would remove: $target"
    else
      rm -rf "$target"
      echo "  removed: $target"
    fi
  else
    echo "  not installed: $target"
  fi
done

if [[ "$DRY_RUN" == "no" ]]; then
  echo
  echo "Done. Restart Claude Code to apply changes."
fi
