#!/usr/bin/env bash
# Install all three ai-performance-skills into ~/.claude/skills/
#
# Idempotent — safe to re-run. Existing installs are copied in-place; removed
# upstream files may linger until manually cleaned.
# Usage: bash scripts/install-all.sh [--dry-run]

set -euo pipefail

SKILLS_DIR="${HOME}/.claude/skills"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS=(cost-optimization brainofbrains elasticjudge)

# Parse flags
DRY_RUN=false
for arg in "$@"; do
    case "${arg}" in
        --dry-run) DRY_RUN=true ;;
        *) echo "Unknown flag: ${arg}" >&2; exit 1 ;;
    esac
done

echo "AI Performance Skills — installer"
echo "=================================="
echo "Source : ${REPO_ROOT}"
echo "Dest   : ${SKILLS_DIR}"
if "${DRY_RUN}"; then
    echo "Mode   : DRY RUN — nothing will be written"
fi
echo ""

# Ensure destination exists (skip in dry-run)
if ! "${DRY_RUN}"; then
    mkdir -p "${SKILLS_DIR}"
fi

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

    if "${DRY_RUN}"; then
        echo "Would install ${skill}"
        echo "  source : ${src}"
        echo "  dest   : ${dst}"
        echo "  → /${skill}"
    else
        echo "Installing ${skill} ..."
        cp -R "${src}" "${SKILLS_DIR}/"

        # Make any scripts inside the installed skill executable
        if [ -d "${dst}/scripts" ]; then
            find "${dst}/scripts" -name "*.sh" -exec chmod +x {} \;
        fi

        echo "  -> ${dst}"
        echo "  → /${skill}"
    fi
    installed+=("${skill}")
done

echo ""
echo "=================================="
if "${DRY_RUN}"; then
    echo "Dry run complete — no files were copied."
else
    echo "Done."
fi
echo ""

if [ ${#installed[@]} -gt 0 ]; then
    if "${DRY_RUN}"; then
        echo "Would install (${#installed[@]}):"
    else
        echo "Installed (${#installed[@]}):"
    fi
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

if ! "${DRY_RUN}"; then
    echo ""
    echo "Next steps:"
    echo "  1. Restart your Claude Code session so it picks up the new skills."
    echo "  2. Ask Claude: 'Run AI Performance' to start the cost-optimization flow."
    echo "  3. Ask Claude: 'Run BrainOfBrains scan' to check your orchestration layer."
    echo "  4. Ask Claude: 'Run ElasticJudge on <file>' to score an artifact."
    echo ""
    echo "Session note:"
    echo "  Skills load at session start. If Claude Code is already running,"
    echo "  open a new session (Cmd+N) for the skills to appear."
fi
