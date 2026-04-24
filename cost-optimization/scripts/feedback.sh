#!/usr/bin/env bash
# Build an opt-in, privacy-safe feedback packet from the proof-of-savings data.
# No automatic send. The packet contains aggregate savings and pilot gates only.

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
    --help|-h)
      cat <<'EOF'
Usage: scripts/feedback.sh [flags]

Recognized flags:
  --audience <name>    deliverables folder prefix (default: elastic-pilot)
  --date <YYYY-MM-DD>  date suffix for the deliverables folder (default: today)
  --note <text>        optional free-text note appended to the feedback packet
  --last <period>      time window forwarded to `kostai proof` (30d, 90d, all)
  --rate <decimal>     pass-through pricing rate forwarded to `kostai proof`

Examples:
  scripts/feedback.sh
  scripts/feedback.sh --audience elastic-pilot --date 2026-04-22
  scripts/feedback.sh --last 30d --note "Pilot week 1 results"
EOF
      exit 0
      ;;
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
    --last)
      EXTRA_ARGS+=("--last" "$2")
      shift 2
      ;;
    --rate)
      EXTRA_ARGS+=("--rate" "$2")
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
  --json "$DELIV_DIR/proof.json" \
  --html "$DELIV_DIR/PROOF.html" \
  "${EXTRA_ARGS[@]}" \
  > "$DELIV_DIR/PROOF.md"

if [[ ! -s "$DELIV_DIR/proof.json" ]]; then
  echo "error: proof.json was not created. Run scripts/demo.sh or collect shadow-mode comparisons first." >&2
  exit 1
fi

FEEDBACK_JSON_PATH="$DELIV_DIR/proof.json" \
FEEDBACK_MD_PATH="$DELIV_DIR/FEEDBACK.md" \
FEEDBACK_SLACK_PATH="$DELIV_DIR/SLACK.md" \
FEEDBACK_MEMO_PATH="$DELIV_DIR/DAY_30_MEMO.md" \
FEEDBACK_NOTE="$NOTE" \
node <<'EOF'
const fs = require("node:fs");

const proofPath = process.env.FEEDBACK_JSON_PATH;
const mdPath = process.env.FEEDBACK_MD_PATH;
const slackPath = process.env.FEEDBACK_SLACK_PATH;
const memoPath = process.env.FEEDBACK_MEMO_PATH;
const note = (process.env.FEEDBACK_NOTE || "").trim();

const proof = JSON.parse(fs.readFileSync(proofPath, "utf8"));
const money = (n, digits = 2) => `$${Number(n || 0).toFixed(digits)}`;
const pct = (n) => `${Number(n || 0).toFixed(1)}%`;

const pairs = Number(proof.pairs || 0);
const savedPct = Number(proof.savedPct || 0);
const savedUsd = Number(proof.savedUsd || 0);
const qualityScore =
  typeof proof.avgQualityScore === "number" ? Number(proof.avgQualityScore) : null;
const qualityPct = qualityScore === null ? null : qualityScore <= 5 ? qualityScore * 20 : qualityScore;
const savingsGate = savedPct >= 20;
const qualityGate = qualityPct === null ? null : qualityPct >= 95;
const decision =
  pairs === 0
    ? "No decision - no measured comparisons yet."
    : savingsGate && qualityGate === true
      ? "Expand - measured savings and quality parity both cleared the pilot gate."
      : savingsGate && qualityGate === null
        ? "Hold - savings cleared the gate, but quality parity still needs verification."
        : savingsGate
          ? "Retune - savings cleared the gate, but quality parity did not."
          : "Walk away or hand off - measured savings did not clear the pilot gate.";

const mechanismLines = Array.isArray(proof.mechanisms) && proof.mechanisms.length
  ? proof.mechanisms
      .map((row) => `- ${row.tag}: ${money(row.savedUsd, 4)} Measured (${pct(row.pctOfTotal)} of attributed savings)`)
      .join("\n")
  : "- None measured yet";

const qualityLine = qualityScore === null
  ? "- Quality parity: Needs verification. Agree on the workflow owner's rubric before production routing."
  : `- Quality parity: ${qualityGate ? "PASS" : "REVIEW"} - ${pct(qualityPct)} Measured-equivalent from average quality score ${qualityScore.toFixed(2)}.`;

const feedback = [
  "# AI Performance feedback packet",
  "",
  "## Summary",
  "",
  `- Window: ${proof.window || "all"} Measured`,
  `- Paired comparisons: ${pairs} Measured`,
  `- Baseline cost: ${money(proof.baselineCostUsd, 4)} Measured`,
  `- Optimized cost: ${money(proof.optimizedCostUsd, 4)} Measured`,
  `- Savings: ${money(savedUsd, 4)} Measured (${pct(savedPct)} Measured)`,
  qualityLine,
  "",
  "## Top mechanisms",
  "",
  mechanismLines,
  "",
  "## Pilot gates",
  "",
  `- Savings gate >=20% on real workflow traffic: ${savingsGate ? "PASS" : "REVIEW"} (${pct(savedPct)} Measured)`,
  qualityLine,
  "- Production routing: HOLD. Pilot remains shadow-only until the workflow owner signs off.",
  "- Security/compliance: Needs verification by the sponsor's normal review path.",
  "",
  "## Decision posture",
  "",
  decision,
  "",
  "## Privacy",
  "",
  "- Aggregate packet only",
  "- No prompt or response bodies included",
  "- No automatic send performed",
  "- Default capture mode remains metadata_only",
  "",
];

if (note) {
  feedback.push("## Employee note", "", note, "");
}

feedback.push(
  "## Share guidance",
  "",
  "Paste this packet into Slack or email only if choosing to share results back with the rollout team.",
  "",
);

fs.writeFileSync(mdPath, feedback.join("\n"), "utf8");

const slack = [
  "AI Performance pilot results",
  "",
  `Measured savings: ${money(savedUsd, 2)} (${pct(savedPct)}) over ${pairs} paired calls.`,
  `Quality: ${qualityScore === null ? "needs verification" : `${pct(qualityPct)} measured-equivalent`}.`,
  `Decision posture: ${decision}`,
  "Privacy: aggregate metrics only, no prompt bodies, no automatic send.",
];
if (note) slack.push(`Note: ${note}`);
fs.writeFileSync(slackPath, slack.join("\n"), "utf8");

const memo = [
  "# Day-30 pilot decision memo",
  "",
  "## Decision",
  "",
  decision,
  "",
  "## Evidence",
  "",
  `- Paired comparisons: ${pairs} Measured`,
  `- Baseline cost: ${money(proof.baselineCostUsd, 4)} Measured`,
  `- Optimized cost: ${money(proof.optimizedCostUsd, 4)} Measured`,
  `- Savings: ${money(savedUsd, 4)} Measured (${pct(savedPct)} Measured)`,
  qualityLine,
  "",
  "## Open checks",
  "",
  "- Named next owner: TBD",
  "- Security/compliance blocker: Needs verification",
  "- Adjacent Elastic owner or duplicate effort: Needs verification",
  "- Production routing approval: Not approved by default",
  "",
  "## Next action",
  "",
  savingsGate && qualityGate === true
    ? "Name the next owner and expand to one additional workflow."
    : "Retune or hand off before expanding. Do not move from shadow mode to production routing yet.",
  "",
];

fs.writeFileSync(memoPath, memo.join("\n"), "utf8");
EOF

echo
echo "[cost-optimization] feedback artifacts:"
echo "  $DELIV_DIR/PROOF.md"
echo "  $DELIV_DIR/PROOF.html"
echo "  $DELIV_DIR/proof.json"
echo "  $DELIV_DIR/FEEDBACK.md"
echo "  $DELIV_DIR/SLACK.md"
echo "  $DELIV_DIR/DAY_30_MEMO.md"
