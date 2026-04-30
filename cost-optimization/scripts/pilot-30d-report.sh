#!/usr/bin/env bash
# After ~30 days of normal use (ledger in a real repo), emit aggregate savings
# for pilot coordinators. Opt-in, local-only — same privacy posture as feedback.sh.

set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Usage: pilot-30d-report.sh [--help]

Writes: deliverables/elastic-pilot-30d-<DATE>/FEEDBACK.md (+ SLACK.md, PILOT_ROLLUP.json, proof.json, …)

Environment:
  PILOT_LEDGER_ROOT   Directory that contains .ai-cost-data/ (default: current cwd).
                      Example: PILOT_LEDGER_ROOT=$HOME/src/my-app ./scripts/pilot-30d-report.sh
  RUN_DATE            YYYY-MM-DD suffix for the deliverables folder (default: today).

Requires: bash, Node 18+, npx. Run from the skill tree so scripts/feedback.sh resolves,
or invoke with absolute path to this script after cd into PILOT_LEDGER_ROOT.
EOF
  exit 0
fi

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LEDGER_ROOT="${PILOT_LEDGER_ROOT:-$PWD}"
RUN_DATE="${RUN_DATE:-$(date +%Y-%m-%d)}"

if [[ ! -d "$LEDGER_ROOT/.ai-cost-data" ]]; then
  echo "error: no .ai-cost-data under PILOT_LEDGER_ROOT: $LEDGER_ROOT" >&2
  echo "hint: cd to the repo where you use Claude/Codex with KostAI, or set PILOT_LEDGER_ROOT." >&2
  exit 1
fi

(
  cd "$LEDGER_ROOT"
  bash "$SKILL_ROOT/scripts/feedback.sh" \
    --audience elastic-pilot-30d \
    --date "$RUN_DATE" \
    --last 30d \
    --note "Elastic pilot — 30-day measured window"
)

echo ""
echo "[pilot-30d-report] done — attach for coordinators:"
echo "  $LEDGER_ROOT/deliverables/elastic-pilot-30d-$RUN_DATE/FEEDBACK.md"
