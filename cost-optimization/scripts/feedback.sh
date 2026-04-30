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

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[cost-optimization] building local feedback packet in $DELIV_DIR"
if [[ ${#EXTRA_ARGS[@]} -eq 0 ]]; then
  npx --yes @sapperjohn/kostai@^0.5.2 proof \
    --json "$DELIV_DIR/proof.json" \
    --html "$DELIV_DIR/PROOF.html" \
    > "$DELIV_DIR/PROOF.md"
else
  npx --yes @sapperjohn/kostai@^0.5.2 proof \
    --json "$DELIV_DIR/proof.json" \
    --html "$DELIV_DIR/PROOF.html" \
    "${EXTRA_ARGS[@]}" \
    > "$DELIV_DIR/PROOF.md"
fi

if [[ ! -s "$DELIV_DIR/proof.json" ]]; then
  echo "error: proof.json was not created. Run scripts/demo.sh or collect shadow-mode comparisons first." >&2
  exit 1
fi

FEEDBACK_JSON_PATH="$DELIV_DIR/proof.json" \
FEEDBACK_MD_PATH="$DELIV_DIR/FEEDBACK.md" \
FEEDBACK_SLACK_PATH="$DELIV_DIR/SLACK.md" \
FEEDBACK_MEMO_PATH="$DELIV_DIR/DAY_30_MEMO.md" \
FEEDBACK_NOTE="$NOTE" \
FEEDBACK_SKILL_ROOT="$SKILL_ROOT" \
FEEDBACK_WORKING_DIR="$(pwd)" \
FEEDBACK_ELAPSED_SEC="${FEEDBACK_ELAPSED_SEC:-}" \
FEEDBACK_SCAN_WORKSPACE_LABEL="${FEEDBACK_SCAN_WORKSPACE_LABEL:-}" \
FEEDBACK_SCAN_ROOT="${FEEDBACK_SCAN_ROOT:-}" \
node <<'EOF'
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { execSync } = require("node:child_process");

const proofPath = process.env.FEEDBACK_JSON_PATH;
const mdPath = process.env.FEEDBACK_MD_PATH;
const slackPath = process.env.FEEDBACK_SLACK_PATH;
const memoPath = process.env.FEEDBACK_MEMO_PATH;
const note = (process.env.FEEDBACK_NOTE || "").trim();
const skillRoot = process.env.FEEDBACK_SKILL_ROOT || "";
const workingDir = process.env.FEEDBACK_WORKING_DIR || process.cwd();
const elapsedRaw = process.env.FEEDBACK_ELAPSED_SEC || "";
const scanWsLabel = (process.env.FEEDBACK_SCAN_WORKSPACE_LABEL || "").trim();
const scanRootRaw = (process.env.FEEDBACK_SCAN_ROOT || "").trim();
const scanRootResolved = scanRootRaw.length ? path.resolve(scanRootRaw) : "";
const delivDir = path.dirname(mdPath);

function scanSnapshotStats(snapDir) {
  const p = path.join(snapDir, "SCAN_SNAPSHOT.txt");
  if (!fs.existsSync(p)) {
    return { present: false, lines: 0, bytes: 0 };
  }
  const raw = fs.readFileSync(p, "utf8");
  return {
    present: true,
    lines: raw.split("\n").length,
    bytes: Buffer.byteLength(raw, "utf8"),
  };
}

function kostaiCliVersion() {
  try {
    return execSync("npx --yes @sapperjohn/kostai@^0.5.2 --version", {
      encoding: "utf8",
      timeout: 120000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
  } catch {
    return "unknown";
  }
}

const kostaiVer = kostaiCliVersion();
const cwdMatchesSkill =
  skillRoot.length > 0 &&
  path.resolve(workingDir) === path.resolve(skillRoot);

function readCaptureMode(dir) {
  try {
    const cfgPath = path.join(dir, "ai-cost.config.json");
    if (!fs.existsSync(cfgPath)) return null;
    const cfg = JSON.parse(fs.readFileSync(cfgPath, "utf8"));
    if (cfg && typeof cfg.captureMode === "string") return cfg.captureMode;
  } catch {
    /* ignore malformed config */
  }
  return null;
}

function optimizationPlanStats(root) {
  const p = path.join(root, ".kostai", "optimizations.md");
  if (!fs.existsSync(p)) {
    return { present: false, lines: 0, bytes: 0, safeHints: 0, reviewHints: 0 };
  }
  const raw = fs.readFileSync(p, "utf8");
  const lines = raw.split("\n").length;
  const bytes = Buffer.byteLength(raw, "utf8");
  const safeHints = (raw.match(/\[SAFE\]/gi) || []).length;
  const reviewHints = (raw.match(/\[REVIEW\]/gi) || []).length;
  return { present: true, lines, bytes, safeHints, reviewHints };
}

const proof = JSON.parse(fs.readFileSync(proofPath, "utf8"));
const scanSnap = scanSnapshotStats(delivDir);
const captureModeSkill =
  readCaptureMode(workingDir) || "unknown (no readable ai-cost.config.json here)";
const captureModeScan =
  scanRootResolved.length > 0 && scanRootResolved !== path.resolve(workingDir)
    ? readCaptureMode(scanRootResolved)
    : null;
const captureMode =
  captureModeScan != null
    ? `${captureModeSkill} (skill cwd); ${captureModeScan} (scan workspace)`
    : captureModeSkill;
const methodology =
  typeof proof.methodology === "string" && proof.methodology.trim().length > 0
    ? proof.methodology.trim()
    : null;
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

const wf = (w) => {
  const s = String(w ?? "untagged");
  return s.length > 56 ? `${s.slice(0, 53)}…` : s;
};

const topSavingsLines =
  Array.isArray(proof.topSavings) && proof.topSavings.length > 0
    ? proof.topSavings.slice(0, 5).map(
        (row) =>
          `- ${wf(row.workflow)}: ${row.baselineModel} → ${row.optimizedModel} · saved ${money(row.savedUsd, 4)} (${pct(
            row.savedPct,
          )} Measured)`,
      )
    : ["- (none in window)"];

const economicsLines =
  pairs === 0
    ? ["- Deferred until paired comparisons exist in the ledger."]
    : [
        `- Pass-through rate used in proof: ${pct((typeof proof.rate === "number" ? proof.rate : 0.1) * 100)} (from proof run)`,
        `- Pass-through value for this window (saved × rate): ${money(Number(proof.subscriptionValueUsd || 0), 4)} (arithmetic on Measured savings)`,
        `- Annualized pass-through value (extrapolated from proof window): ${money(Number(proof.annualizedSubscriptionValueUsd || 0), 2)}/year **Modeled** (not a forward revenue guarantee)`,
      ];

const qualityLine = qualityScore === null
  ? "- Quality parity: Needs verification. Agree on the workflow owner's rubric before production routing."
  : `- Quality parity: ${qualityGate ? "PASS" : "REVIEW"} - ${pct(qualityPct)} Measured-equivalent from average quality score ${qualityScore.toFixed(2)}.`;

const planSkill = optimizationPlanStats(workingDir);
const planScan =
  scanRootResolved.length > 0 && scanRootResolved !== path.resolve(workingDir)
    ? optimizationPlanStats(scanRootResolved)
    : null;

const planLine = (label, st) =>
  st.present
    ? `- ${label}: present · ${st.lines} lines · ${st.bytes} bytes · ${st.safeHints} [SAFE] · ${st.reviewHints} [REVIEW] (rollup)`
    : `- ${label}: not found — run \`npx kostai scan\` in that repo when you want a prioritized plan (rollup)`;

const feedback = [
  "# AI Performance feedback packet",
  "",
  "Thanks for taking part — you already did the hard part. Everything below is **aggregate-only** and safe to forward; nothing was auto-uploaded.",
  "",
  "## What your packet powers (for the team building KostAI)",
  "",
  "- **Savings** — paired-call economics, mechanisms, and workload roll-up show where spend actually moved in this window.",
  "- **Implementation signal** — optimization-plan **counts only** (lines plus [SAFE] vs [REVIEW] tags); no plan body or repo paths.",
  scanSnap.present
    ? `- **Scan capture** — \`SCAN_SNAPSHOT.txt\` in this folder (${scanSnap.lines} lines, rollup size) helps engineers reproduce what the scan saw on stacks like yours.`
    : "- **Scan capture** — no `SCAN_SNAPSHOT.txt` in this folder for this run (normal if you ran `feedback.sh` without `pilot-complete.sh`).",
  "- **Machine-readable extras** — `PILOT_ROLLUP.json` and `proof.json` in this folder let us rank pilots and plan sprints without scheduling more interviews.",
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
  "## Where the money went (workload roll-up)",
  "",
  ...topSavingsLines,
  "",
  "## Pass-through economics (pricing math)",
  "",
  ...economicsLines,
  "",
  ...(methodology
    ? [
        "## Methodology (from proof bundle)",
        "",
        methodology,
        "",
      ]
    : []),
  "## Local configuration surface (non-sensitive)",
  "",
  `- ai-cost.config.json captureMode (if present): ${captureMode} (rollup)`,
  `- Quality-graded pairs: ${Number(proof.qualityGradedPairs ?? 0)} Measured`,
  "",
  "## Implementation surface (rollup only — no repo paths or plan body)",
  "",
  "_Shows whether a KostAI optimization plan exists, how large it is, and how much is tagged auto-applicable **[SAFE]** vs needs sign-off **[REVIEW]** — that split is the main backlog signal for implementation velocity._",
  "",
  planLine(`skill cwd (${path.basename(workingDir)})`, planSkill),
  ...(planScan ? [planLine(`scan workspace (${scanWsLabel || path.basename(scanRootResolved)})`, planScan)] : []),
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
  "## Pilot environment (non-sensitive)",
  "",
  `- platform: ${os.platform()} (rollup)`,
  `- arch: ${os.arch()} (rollup)`,
  `- OS release: ${os.release()} (rollup)`,
  `- Node.js: ${process.version} (rollup)`,
  `- KostAI CLI (local invoke): ${kostaiVer} (rollup)`,
  `- pilot cwd matches skill root: ${cwdMatchesSkill ? "yes" : "no"} (rollup)`,
  `- pilot-complete elapsed seconds: ${elapsedRaw.length ? `${elapsedRaw} (rollup)` : "n/a (direct feedback.sh run)"}`,
  ...(scanWsLabel.length
    ? [`- kostai scan workspace (basename only): ${scanWsLabel} (rollup)`]
    : []),
  "",
  "## Privacy",
  "",
  "- Aggregate packet only",
  "- No prompt or response bodies included",
  "- No automatic send performed",
  `- Capture mode from local config (when readable): ${captureMode}`,
  "",
];

if (note) {
  feedback.push("## Employee note", "", note, "");
}

feedback.push(
  "## Raw engineering payload",
  "",
  "- `proof.json` in this folder is the full structured ProofReport for KostAI engineering (mechanisms, top savings rows, window timestamps, methodology). FEEDBACK.md is the executive slice; ingest `proof.json` or `PILOT_ROLLUP.json` for dashboards, sprint prioritization, and **SAFE vs REVIEW** optimization-plan rollups (no plan body).",
  "",
  "## You are done — thank you",
  "",
  "- This run stayed on your machine — nothing was auto-uploaded.",
  "- Sending **FEEDBACK.md** alone fully closes the loop — you are not behind if that is all you attach.",
  "- If you also include **PILOT_ROLLUP.json** and the first ~80 lines of **proof.json**, you skip a whole round of follow-ups for the product team (same privacy rules).",
  "- **SCAN_SNAPSHOT.txt** (when it exists in this folder) is the fastest way for engineers to validate findings against real codebases — keep it next to the other files when you can.",
  "",
);

feedback.push(
  "## Share guidance",
  "",
  "If you choose to share results with the rollout team, paste this packet into Slack or email — or attach the files from this folder. Either way, thank you for the signal.",
  "",
);

fs.writeFileSync(mdPath, feedback.join("\n"), "utf8");

const rollupRate = typeof proof.rate === "number" ? proof.rate : 0.1;
const rollup = {
  schema: "kostai.elasticPilotRollup.v1",
  schemaExtensions: [
    "economics-v1",
    "workload-top5-v1",
    "captureMode-v1",
    "implementation-plan-v1",
    "implementation-review-tags-v1",
    "scan-snapshot-rollup-v1",
    "methodology-v1",
  ],
  generatedAt: new Date().toISOString(),
  pairs,
  savedPct,
  savedUsd,
  baselineCostUsd: Number(proof.baselineCostUsd || 0),
  optimizedCostUsd: Number(proof.optimizedCostUsd || 0),
  rate: rollupRate,
  subscriptionValueUsd: Number(proof.subscriptionValueUsd || 0),
  annualizedSubscriptionValueUsd: Number(proof.annualizedSubscriptionValueUsd || 0),
  avgQualityScore: qualityScore,
  qualityGradedPairs: Number(proof.qualityGradedPairs ?? 0),
  mechanisms: Array.isArray(proof.mechanisms) ? proof.mechanisms : [],
  topSavings: Array.isArray(proof.topSavings)
    ? proof.topSavings.slice(0, 5).map((row) => ({
        ...row,
        workflow:
          String(row.workflow ?? "").length > 64
            ? `${String(row.workflow).slice(0, 61)}…`
            : row.workflow,
      }))
    : [],
  captureMode,
  captureModeSkillCwd: captureModeSkill,
  captureModeScanWorkspace: captureModeScan,
  captureModeRollupLine: captureMode,
  methodologySnippet:
    methodology && methodology.length > 400
      ? `${methodology.slice(0, 397)}…`
      : methodology,
  optimizationPlanSkillCwd: planSkill,
  optimizationPlanScanWorkspace: planScan,
  scanSnapshot: scanSnap,
  savingsGatePass: savingsGate,
  qualityGatePass: qualityGate,
  decision,
  platform: os.platform(),
  arch: os.arch(),
  osRelease: os.release(),
  nodeVersion: process.version,
  kostaiCliVersion: kostaiVer,
  cwdMatchesSkillRoot: cwdMatchesSkill,
  pilotElapsedSec: elapsedRaw.length ? Number(elapsedRaw) : null,
  proofWindow: proof.window || "all",
  scanWorkspaceBasename: scanWsLabel.length ? scanWsLabel : null,
};
fs.writeFileSync(path.join(delivDir, "PILOT_ROLLUP.json"), `${JSON.stringify(rollup, null, 2)}\n`, "utf8");

const topMech = Array.isArray(proof.mechanisms) && proof.mechanisms[0] ? proof.mechanisms[0].tag : "n/a";
const annRoll = Number(proof.annualizedSubscriptionValueUsd || 0);
const implRollup =
  planSkill.present || (planScan && planScan.present)
    ? `Implementation (rollup): skill ${planSkill.safeHints} SAFE / ${planSkill.reviewHints} REVIEW${
        planScan && planScan.present
          ? ` · scan workspace ${planScan.safeHints} SAFE / ${planScan.reviewHints} REVIEW`
          : ""
      }.`
    : "Implementation (rollup): no optimization plan file detected yet — run scan in your main repo when you can.";
const scanRollup = scanSnap.present
  ? `Scan snapshot: ${scanSnap.lines} lines in packet (helps eng repro).`
  : "Scan snapshot: not in this folder for this run.";
const slack = [
  "AI Performance pilot results",
  "",
  `Measured savings: ${money(savedUsd, 2)} (${pct(savedPct)}) over ${pairs} paired calls.`,
  `Quality: ${qualityScore === null ? "needs verification" : `${pct(qualityPct)} measured-equivalent`}.`,
  `Largest savings driver (tag): ${topMech}. Annualized pass-through @ proof rate: ${money(annRoll, 2)}/yr (Modeled from window).`,
  implRollup,
  scanRollup,
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
echo "  $DELIV_DIR/PILOT_ROLLUP.json"
echo "  $DELIV_DIR/SLACK.md"
echo "  $DELIV_DIR/DAY_30_MEMO.md"
