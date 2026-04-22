#!/usr/bin/env bash
# Install all three ai-performance-skills into ~/.claude/skills/
#
# Idempotent — safe to re-run. Existing installs are overwritten in-place.
# Usage: bash scripts/install-all.sh

set -euo pipefail

SKILLS_DIR="${HOME}/.claude/skills"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS=(cost-optimization brainofbrains elasticjudge)

echo "AI Performance Skills — installer"
echo "=================================="
echo "Source : ${REPO_ROOT}"
echo "Dest   : ${SKILLS_DIR}"
echo ""

# Ensure destination exists
mkdir -p "${SKILLS_DIR}"

# Track outcomes
installed=()
skipped=()

for skill in "${SKILLS[@]}"; do
    src="${REPO_ROOT}/${skill}"
    dst="${SKILLS_DIR}/${skill}"

    if [ ! -d "${src}" ]; then
        echo "SKIP  ${skill} — source directory not found at ${src}"
        skipped+=("${skill}")
        continue
    fi

    echo "Installing ${skill} ..."
    cp -R "${src}" "${SKILLS_DIR}/"

    # Make any scripts inside the installed skill executable
    if [ -d "${dst}/scripts" ]; then
        find "${dst}/scripts" -name "*.sh" -exec chmod +x {} \;
    fi

    echo "  -> ${dst}"
    installed+=("${skill}")
done

echo ""
echo "=================================="
echo "Done."
echo ""

if [ ${#installed[@]} -gt 0 ]; then
    echo "Installed (${#installed[@]}):"
    for skill in "${installed[@]}"; do
        echo "  ${SKILLS_DIR}/${skill}"
    done
fi

if [ ${#skipped[@]} -gt 0 ]; then
    echo ""
    echo "Skipped (${#skipped[@]}) — source not found:"
    for skill in "${skipped[@]}"; do
        echo "  ${skill}"
    done
fi

echo ""
echo "Next steps:"
echo "  1. Restart your Claude Code session so it picks up the new skills."
echo "  2. Ask Claude: 'Run AI Performance' to start the cost-optimization flow."
echo "  3. Ask Claude: 'Run BrainOfBrains scan' to check your orchestration layer."
echo "  4. Ask Claude: 'Run ElasticJudge on <file>' to score an artifact."
