#!/usr/bin/env bash
# One-shot Elastic pilot run from the skill root (directory containing SKILL.md).
# Emits demo proof, elastic-pilot feedback packet, SCAN_SNAPSHOT.txt, and PILOT_ROLLUP.json.

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Usage: pilot-complete.sh [--help]

Run from the cost-optimization skill root (folder with SKILL.md and scripts/).
Uses RUN_DATE=YYYY-MM-DD (default: today) for deliverables folder names.

Environment:
  PILOT_WORKSPACE   Directory for `kostai scan` snapshot (default: skill root).
                    Set to your main git repo for meaningful next steps, e.g.:
                    PILOT_WORKSPACE=$HOME/ws/my-app ./scripts/pilot-complete.sh

Writes under deliverables/elastic-pilot-<RUN_DATE>/:
  FEEDBACK.md, SLACK.md, DAY_30_MEMO.md, proof.json, PROOF.md, PROOF.html,
  SCAN_SNAPSHOT.txt, PILOT_ROLLUP.json

Also writes deliverables/demo-<RUN_DATE>/ from proof.sh --audience demo.

Requires: bash, Node 18+, npx, tee.
EOF
  exit 0
fi

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SKILL_ROOT"

if [[ ! -f "$SKILL_ROOT/SKILL.md" ]]; then
  echo "error: run from skill root — SKILL.md not found at $SKILL_ROOT/SKILL.md" >&2
  exit 1
fi

WORKSPACE="${PILOT_WORKSPACE:-$SKILL_ROOT}"
if [[ ! -d "$WORKSPACE" ]]; then
  echo "error: PILOT_WORKSPACE is not a directory: $WORKSPACE" >&2
  exit 1
fi

RUN_DATE="${RUN_DATE:-$(date +%Y-%m-%d)}"
DELIV="deliverables/elastic-pilot-$RUN_DATE"

mkdir -p "$DELIV"

START="$(date +%s)"

echo "[pilot-complete] skill root: $SKILL_ROOT"
echo "[pilot-complete] scan workspace: $WORKSPACE"
echo "[pilot-complete] RUN_DATE=$RUN_DATE"
echo "[pilot-complete] tip: first \`npx\` download can take 1–2 minutes — this is normal."

echo "[pilot-complete] 1/4 — demo seed + baseline workflow"
bash "$SKILL_ROOT/scripts/demo.sh"

echo "[pilot-complete] 2/4 — scan snapshot (saved for coordinator triage)"
( cd "$WORKSPACE" && bash "$SKILL_ROOT/scripts/scan.sh" ) 2>&1 | tee "$DELIV/SCAN_SNAPSHOT.txt"

echo "[pilot-complete] 3/4 — demo audience proof packet"
bash "$SKILL_ROOT/scripts/proof.sh" --audience demo --date "$RUN_DATE"

PRE_FEEDBACK="$(date +%s)"
export FEEDBACK_ELAPSED_SEC=$((PRE_FEEDBACK - START))
export FEEDBACK_SCAN_WORKSPACE_LABEL="${WORKSPACE##*/}"
export FEEDBACK_SCAN_ROOT="$WORKSPACE"

echo "[pilot-complete] 4/4 — elastic-pilot feedback packet (FEEDBACK.md + PILOT_ROLLUP.json from KostAI)"
bash "$SKILL_ROOT/scripts/feedback.sh" --audience elastic-pilot --date "$RUN_DATE" --note "pilot-complete one-shot"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo " PILOT COMPLETE — thank you, this helps us ship faster"
echo "═══════════════════════════════════════════════════════════"
echo "  $SKILL_ROOT/$DELIV/FEEDBACK.md   (required return)"
echo "  $SKILL_ROOT/$DELIV/SLACK.md     (rollup blurb)"
echo "  $SKILL_ROOT/$DELIV/DAY_30_MEMO.md"
echo "  $SKILL_ROOT/$DELIV/PILOT_ROLLUP.json  (machine-ingestible)"
echo "  $SKILL_ROOT/$DELIV/SCAN_SNAPSHOT.txt"
echo "  $SKILL_ROOT/deliverables/demo-$RUN_DATE/PROOF.md"
echo "═══════════════════════════════════════════════════════════"
