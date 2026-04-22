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
npx --yes @sapperjohn/kostai report "${EXTRA_ARGS[@]}" \
  > "$DELIV_DIR/PROOF.md"
npx --yes @sapperjohn/kostai export \
  --format json \
  --output "$DELIV_DIR/feedback.json" \
  "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"

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

const events = JSON.parse(fs.readFileSync(jsonPath, "utf8"));
const money = (n, digits = 2) => `$${Number(n || 0).toFixed(digits)}`;
const pct = (n) => `${Number(n || 0).toFixed(1)}%`;

// Aggregate from raw event array (kostai export --format json)
const baseline = events.filter((e) => e.shadowRole === "baseline");
const optimized = events.filter((e) => e.shadowRole && e.shadowRole !== "baseline");
const baselineCostUsd = baseline.reduce((s, e) => s + (e.costUsd || 0), 0);
const optimizedCostUsd = optimized.reduce((s, e) => s + (e.costUsd || 0), 0);
const savedUsd = Math.max(0, baselineCostUsd - optimizedCostUsd);
const savedPct = baselineCostUsd > 0 ? (savedUsd / baselineCostUsd) * 100 : 0;
const pairs = new Set(events.map((e) => e.comparisonId).filter(Boolean)).size;
const qualityScores = events.map((e) => e.qualityScore).filter((q) => typeof q === "number");
const avgQualityScore = qualityScores.length ? qualityScores.reduce((s, q) => s + q, 0) / qualityScores.length : null;
const quality = avgQualityScore !== null ? avgQualityScore.toFixed(2) : "n/a";

// Mechanism breakdown from tags
const tagCosts = {};
for (const e of optimized) {
  const saving = (baseline.find((b) => b.comparisonId === e.comparisonId)?.costUsd || 0) - (e.costUsd || 0);
  for (const tag of (e.tags || [])) {
    tagCosts[tag] = (tagCosts[tag] || 0) + Math.max(0, saving / Math.max(1, (e.tags || []).length));
  }
}
const mechanisms = Object.entries(tagCosts)
  .sort(([, a], [, b]) => b - a)
  .slice(0, 3)
  .map(([tag, usd]) => ({ tag, savedUsd: usd, pctOfTotal: savedUsd > 0 ? (usd / savedUsd) * 100 : 0 }));
const mechLines = mechanisms.length
  ? mechanisms.map((row) => `- ${row.tag}: ${money(row.savedUsd, 4)} (${pct(row.pctOfTotal)})`).join("\n")
  : "- None";

const timestamps = events.map((e) => e.ts).filter(Boolean).sort();
const window = timestamps.length >= 2
  ? `${timestamps[0].slice(0, 10)} to ${timestamps[timestamps.length - 1].slice(0, 10)}`
  : timestamps.length === 1 ? timestamps[0].slice(0, 10) : "n/a";

const lines = [
  "# AI Performance feedback packet",
  "",
  "## Summary",
  "",
  `- Window: ${window}`,
  `- Paired comparisons: ${pairs}`,
  `- Baseline cost: ${money(baselineCostUsd, 4)}`,
  `- Optimized cost: ${money(optimizedCostUsd, 4)}`,
  `- Measured savings: ${money(savedUsd, 4)} (${pct(savedPct)})`,
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
  `Measured savings: ${money(savedUsd, 2)} (${pct(savedPct)}) over ${pairs} paired calls.`,
  `Baseline: ${money(baselineCostUsd, 2)} -> Optimized: ${money(optimizedCostUsd, 2)}.`,
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
