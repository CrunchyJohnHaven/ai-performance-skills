#!/usr/bin/env bash
# Build an opt-in, privacy-safe feedback packet from local proof data.
# No automatic send. The packet is intended for manual sharing back to the
# rollout team and contains aggregate savings metrics only.

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "error: npx not found. install Node.js (>=18) and try again." >&2
  exit 1
fi

AUDIENCE="elastic-pilot"
DATE="$(date +%Y-%m-%d)"
NOTE=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --audience)
      AUDIENCE="$2"
      shift 2
      ;;
    --date)
      DATE="$2"
      shift 2
      ;;
    --note)
      NOTE="$2"
      shift 2
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

DELIV_DIR="deliverables/${AUDIENCE}-${DATE}"
mkdir -p "$DELIV_DIR"

echo "[cost-optimization] building local feedback packet in $DELIV_DIR"
npx --yes @sapperjohn/kostai proof \
  --json "$DELIV_DIR/feedback.json" \
  "${EXTRA_ARGS[@]}" \
  > "$DELIV_DIR/PROOF.md"

FEEDBACK_JSON_PATH="$DELIV_DIR/feedback.json" \
FEEDBACK_MD_PATH="$DELIV_DIR/FEEDBACK.md" \
FEEDBACK_SLACK_PATH="$DELIV_DIR/SLACK.md" \
FEEDBACK_NOTE="$NOTE" \
node <<'EOF'
const fs = require("node:fs");

const jsonPath = process.env.FEEDBACK_JSON_PATH;
const mdPath = process.env.FEEDBACK_MD_PATH;
const slackPath = process.env.FEEDBACK_SLACK_PATH;
const note = (process.env.FEEDBACK_NOTE || "").trim();

const report = JSON.parse(fs.readFileSync(jsonPath, "utf8"));
const money = (n, digits = 2) => `$${Number(n || 0).toFixed(digits)}`;
const pct = (n) => `${Number(n || 0).toFixed(1)}%`;
const quality =
  typeof report.avgQualityScore === "number"
    ? report.avgQualityScore.toFixed(2)
    : "n/a";
const mechanisms = Array.isArray(report.mechanisms) ? report.mechanisms.slice(0, 3) : [];
const mechLines = mechanisms.length
  ? mechanisms.map((row) => `- ${row.tag}: ${money(row.savedUsd, 4)} (${pct(row.pctOfTotal)})`).join("\n")
  : "- None";

const lines = [
  "# AI Performance feedback packet",
  "",
  "## Summary",
  "",
  `- Window: ${report.window}`,
  `- Paired comparisons: ${report.pairs}`,
  `- Baseline cost: ${money(report.baselineCostUsd, 4)}`,
  `- Optimized cost: ${money(report.optimizedCostUsd, 4)}`,
  `- Measured savings: ${money(report.savedUsd, 4)} (${pct(report.savedPct)})`,
  `- Quality signal: ${quality}`,
  "",
  "## Top mechanisms",
  "",
  mechLines,
  "",
  "## Privacy",
  "",
  "- Aggregate packet only",
  "- No prompt or response bodies included",
  "- No automatic send performed",
  "",
];

if (note) {
  lines.push("## Employee note", "", note, "");
}

lines.push("## Share guidance", "", "Paste this packet into Slack or email only if choosing to share results back with the rollout team.", "");

fs.writeFileSync(mdPath, lines.join("\n"), "utf8");

const slackLines = [
  "AI Performance results",
  "",
  `Measured savings: ${money(report.savedUsd, 2)} (${pct(report.savedPct)}) over ${report.pairs} paired calls.`,
  `Baseline: ${money(report.baselineCostUsd, 2)} -> Optimized: ${money(report.optimizedCostUsd, 2)}.`,
  mechanisms.length
    ? `Top drivers: ${mechanisms.map((row) => `${row.tag} ${pct(row.pctOfTotal)}`).join(", ")}.`
    : "Top drivers: none yet.",
  "Privacy: aggregate metrics only, no prompt bodies.",
];

if (note) {
  slackLines.push(`Note: ${note}`);
}

fs.writeFileSync(slackPath, slackLines.join("\n"), "utf8");
EOF

echo
echo "[cost-optimization] feedback artifacts:"
echo "  $DELIV_DIR/FEEDBACK.md"
echo "  $DELIV_DIR/SLACK.md"
echo "  $DELIV_DIR/feedback.json"
