#!/usr/bin/env bash
# Print the installed version of @sapperjohn/kostai and related tooling.
# Usage: scripts/version.sh
set -euo pipefail

echo "[ai-performance-skills] version info"
echo ""

echo "kostai CLI:"
if command -v npx >/dev/null 2>&1; then
  npx --yes @sapperjohn/kostai --version 2>&1 || echo "  (not installed or unreachable)"
else
  echo "  npx not found — install Node.js 18+"
fi

echo ""
echo "Node.js:"
if command -v node >/dev/null 2>&1; then
  node --version
else
  echo "  not found — install Node.js 18+"
fi

echo ""
echo "Skill files:"
for skill in cost-optimization brainofbrains elasticjudge; do
  dir="$(pwd)/$skill"
  if [[ -f "$dir/SKILL.md" ]]; then
    ver="$(grep '^version:' "$dir/SKILL.md" 2>/dev/null | head -1 | sed 's/version: *//' || echo "(no version field)")"
    echo "  $skill: $ver"
  else
    echo "  $skill: NOT FOUND at $dir/SKILL.md"
  fi
done
