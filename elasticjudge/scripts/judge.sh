#!/usr/bin/env bash
# Submit an artifact to the ElasticJudge cloud API for a full verdict.
# Produces a markdown summary plus structured JSON under
# deliverables/<audience>-<date>/.
#
# Usage:
#   scripts/judge.sh path/to/ARTIFACT.md
#   scripts/judge.sh --text "Elastic is the world's leading..."
#   scripts/judge.sh --audience adnan-cio --date 2026-04-22 path/to/MEMO.md
#
# Environment:
#   ELASTICJUDGE_API_KEY   optional bearer token; forwarded as Authorization
#   ELASTICJUDGE_URL       override base URL (default https://elasticjudge.com)
#
# The endpoint path /v1/evaluate is an educated guess and is marked
# NEEDS-VERIFICATION against the live API docs at https://elasticjudge.com/.
# Update this script and references/verification.md in the same commit when
# the operator publishes the canonical path.

set -euo pipefail

if ! command -v curl >/dev/null 2>&1; then
  echo "error: curl not found. install curl and try again." >&2
  exit 1
fi

BASE_URL="${ELASTICJUDGE_URL:-https://elasticjudge.com}"
ENDPOINT="${BASE_URL}/v1/evaluate"

AUDIENCE="judge-run"
DATE="$(date +%Y-%m-%d)"
ARTIFACT_PATH=""
INLINE_TEXT=""

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
    --text)
      INLINE_TEXT="$2"
      shift 2
      ;;
    --help|-h)
      sed -n '2,20p' "$0"
      exit 0
      ;;
    *)
      ARTIFACT_PATH="$1"
      shift
      ;;
  esac
done

if [[ -z "$ARTIFACT_PATH" && -z "$INLINE_TEXT" ]]; then
  echo "error: pass a file path or --text \"<inline>\"" >&2
  exit 2
fi

DELIV_DIR="deliverables/${AUDIENCE}-${DATE}"
mkdir -p "$DELIV_DIR"

PAYLOAD_PATH="$(mktemp -t elasticjudge-payload.XXXXXX.json)"
trap 'rm -f "$PAYLOAD_PATH"' EXIT

if [[ -n "$ARTIFACT_PATH" ]]; then
  if [[ ! -f "$ARTIFACT_PATH" ]]; then
    echo "error: artifact not found: $ARTIFACT_PATH" >&2
    exit 2
  fi
  BODY_SHA="$(shasum -a 256 "$ARTIFACT_PATH" | awk '{print $1}')"
  PAYLOAD_JSON="$(
    ELASTICJUDGE_SOURCE="file" \
    ELASTICJUDGE_PATH="$ARTIFACT_PATH" \
    ELASTICJUDGE_SHA="$BODY_SHA" \
    node <<'EOF'
const fs = require("node:fs");
const body = fs.readFileSync(process.env.ELASTICJUDGE_PATH, "utf8");
const payload = {
  source: process.env.ELASTICJUDGE_SOURCE,
  path: process.env.ELASTICJUDGE_PATH,
  sha256: process.env.ELASTICJUDGE_SHA,
  body,
};
process.stdout.write(JSON.stringify(payload));
EOF
  )"
else
  BODY_SHA="$(printf '%s' "$INLINE_TEXT" | shasum -a 256 | awk '{print $1}')"
  PAYLOAD_JSON="$(
    ELASTICJUDGE_SOURCE="inline" \
    ELASTICJUDGE_BODY="$INLINE_TEXT" \
    ELASTICJUDGE_SHA="$BODY_SHA" \
    node <<'EOF'
const payload = {
  source: process.env.ELASTICJUDGE_SOURCE,
  sha256: process.env.ELASTICJUDGE_SHA,
  body: process.env.ELASTICJUDGE_BODY,
};
process.stdout.write(JSON.stringify(payload));
EOF
  )"
fi

printf '%s' "$PAYLOAD_JSON" > "$PAYLOAD_PATH"

AUTH_HEADER=()
if [[ -n "${ELASTICJUDGE_API_KEY:-}" ]]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${ELASTICJUDGE_API_KEY}")
fi

VERDICT_JSON="$DELIV_DIR/verdict.json"
JUDGE_MD="$DELIV_DIR/JUDGE.md"

echo "[elasticjudge] submitting to $ENDPOINT"
HTTP_STATUS="$(
  curl -sS -o "$VERDICT_JSON" -w '%{http_code}' \
    -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    "${AUTH_HEADER[@]+"${AUTH_HEADER[@]}"}" \
    --data-binary "@${PAYLOAD_PATH}"
)"

if [[ "$HTTP_STATUS" != "200" ]]; then
  echo "error: ElasticJudge returned HTTP $HTTP_STATUS" >&2
  if [[ -f "$VERDICT_JSON" ]]; then
    echo "body:" >&2
    cat "$VERDICT_JSON" >&2 || true
  fi
  echo "" >&2
  echo "hint: the ElasticJudge cloud API lives at ${BASE_URL}." >&2
  echo "  If the site is not yet live, this call will fail until the operator publishes it." >&2
  echo "  Override the base URL with: ELASTICJUDGE_URL=<url> $0 ..." >&2
  echo "  See https://elasticjudge.com/ for status and documentation." >&2
  exit 1
fi

ELASTICJUDGE_VERDICT_JSON="$VERDICT_JSON" \
ELASTICJUDGE_JUDGE_MD="$JUDGE_MD" \
ELASTICJUDGE_ENDPOINT="$ENDPOINT" \
ELASTICJUDGE_SHA="$BODY_SHA" \
node <<'EOF'
const fs = require("node:fs");

const verdictPath = process.env.ELASTICJUDGE_VERDICT_JSON;
const outPath = process.env.ELASTICJUDGE_JUDGE_MD;
const endpoint = process.env.ELASTICJUDGE_ENDPOINT;
const sha = process.env.ELASTICJUDGE_SHA;

const report = JSON.parse(fs.readFileSync(verdictPath, "utf8"));
const verdict = report.verdict || "unknown";
const reasoning = report.reasoning || "(no reasoning returned)";
const axes = report.axes || {};
const critiques = Array.isArray(report.critiques) ? report.critiques : [];

const axisOrder = [
  "factual_correctness",
  "elastic_domain_accuracy",
  "brand_voice",
  "exec_readiness",
  "safety",
];
const axisLines = axisOrder.map((key) => {
  const row = axes[key];
  if (!row) return `- ${key}: (not scored)`;
  return `- ${key}: ${row.score}/5 — ${row.descriptor || ""}`.trim();
});

const critiqueLines = critiques.length
  ? critiques
      .slice(0, 20)
      .map((c) => `- [${c.axis || "axis?"}] ${c.locator || "line ?"}: ${c.reason || ""}`)
  : ["- (none surfaced)"];

const lines = [
  "# Quality Judge verdict",
  "",
  `- Verdict: **${verdict}**`,
  `- Reasoning: ${reasoning}`,
  `- Submitted SHA-256: \`${sha}\``,
  "",
  "## Axis scores",
  "",
  ...axisLines,
  "",
  "## Line-level critiques",
  "",
  ...critiqueLines,
  "",
  "## Reproducibility stub",
  "",
  "Re-run the same evaluation:",
  "",
  "```bash",
  `curl -sS -X POST "${endpoint}" \\`,
  "  -H \"Content-Type: application/json\" \\",
  "  -H \"Authorization: Bearer $ELASTICJUDGE_API_KEY\" \\",
  "  --data-binary @payload.json",
  "```",
  "",
  "Measured label applies when the same input reproduces the same verdict.",
  "Endpoint path NEEDS-VERIFICATION against https://elasticjudge.com/ live docs.",
  "",
];

fs.writeFileSync(outPath, lines.join("\n"), "utf8");
EOF

echo
echo "[elasticjudge] verdict artifacts:"
echo "  $JUDGE_MD"
echo "  $VERDICT_JSON"
