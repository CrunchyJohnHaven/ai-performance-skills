#!/usr/bin/env bash
# Light variant of judge.sh — returns only the numeric per-axis scores as JSON.
# Designed for CI integration or shadow-mode evaluator use where the only
# question is whether an optimized response scored at or above the baseline.
#
# Usage:
#   scripts/score.sh path/to/ARTIFACT.md
#   scripts/score.sh --text "Elastic is the world's leading..."
#
# Writes nothing to disk by default; prints the scores JSON to stdout.
# Pass --out <path> to also write the scores JSON to a file.

set -euo pipefail

if ! command -v curl >/dev/null 2>&1; then
  echo "error: curl not found. install curl and try again." >&2
  exit 1
fi

BASE_URL="${ELASTICJUDGE_URL:-https://elasticjudge.com}"
ENDPOINT="${BASE_URL}/v1/evaluate"

ARTIFACT_PATH=""
INLINE_TEXT=""
OUT_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --text)
      INLINE_TEXT="$2"
      shift 2
      ;;
    --out)
      OUT_PATH="$2"
      shift 2
      ;;
    --help|-h)
      sed -n '2,13p' "$0"
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

PAYLOAD_PATH="$(mktemp -t elasticjudge-payload.XXXXXX.json)"
VERDICT_PATH="$(mktemp -t elasticjudge-verdict.XXXXXX.json)"
trap 'rm -f "$PAYLOAD_PATH" "$VERDICT_PATH"' EXIT

if [[ -n "$ARTIFACT_PATH" ]]; then
  if [[ ! -f "$ARTIFACT_PATH" ]]; then
    echo "error: artifact not found: $ARTIFACT_PATH" >&2
    exit 2
  fi
  BODY_SHA="$(shasum -a 256 "$ARTIFACT_PATH" | awk '{print $1}')"
  ELASTICJUDGE_SOURCE="file" \
  ELASTICJUDGE_PATH="$ARTIFACT_PATH" \
  ELASTICJUDGE_SHA="$BODY_SHA" \
  ELASTICJUDGE_MODE="score" \
  node <<'EOF' > "$PAYLOAD_PATH"
const fs = require("node:fs");
const body = fs.readFileSync(process.env.ELASTICJUDGE_PATH, "utf8");
process.stdout.write(JSON.stringify({
  source: process.env.ELASTICJUDGE_SOURCE,
  path: process.env.ELASTICJUDGE_PATH,
  sha256: process.env.ELASTICJUDGE_SHA,
  mode: process.env.ELASTICJUDGE_MODE,
  body,
}));
EOF
else
  BODY_SHA="$(printf '%s' "$INLINE_TEXT" | shasum -a 256 | awk '{print $1}')"
  ELASTICJUDGE_SOURCE="inline" \
  ELASTICJUDGE_BODY="$INLINE_TEXT" \
  ELASTICJUDGE_SHA="$BODY_SHA" \
  ELASTICJUDGE_MODE="score" \
  node <<'EOF' > "$PAYLOAD_PATH"
process.stdout.write(JSON.stringify({
  source: process.env.ELASTICJUDGE_SOURCE,
  sha256: process.env.ELASTICJUDGE_SHA,
  mode: process.env.ELASTICJUDGE_MODE,
  body: process.env.ELASTICJUDGE_BODY,
}));
EOF
fi

AUTH_HEADER=()
if [[ -n "${ELASTICJUDGE_API_KEY:-}" ]]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${ELASTICJUDGE_API_KEY}")
fi

HTTP_STATUS="$(
  curl -sS -o "$VERDICT_PATH" -w '%{http_code}' \
    -X POST "${ENDPOINT}?mode=score" \
    -H "Content-Type: application/json" \
    "${AUTH_HEADER[@]}" \
    --data-binary "@${PAYLOAD_PATH}"
)"

if [[ "$HTTP_STATUS" != "200" ]]; then
  echo "error: ElasticJudge returned HTTP $HTTP_STATUS" >&2
  if [[ -f "$VERDICT_PATH" ]]; then
    echo "body:" >&2
    cat "$VERDICT_PATH" >&2 || true
  fi
  echo "" >&2
  echo "hint: the ElasticJudge cloud API lives at ${BASE_URL}." >&2
  echo "  If the site is not yet live, this call will fail until the operator publishes it." >&2
  echo "  Override the base URL with: ELASTICJUDGE_URL=<url> $0 ..." >&2
  echo "  See https://elasticjudge.com/ for status and documentation." >&2
  exit 1
fi

ELASTICJUDGE_VERDICT_JSON="$VERDICT_PATH" \
node <<'EOF'
const fs = require("node:fs");
const report = JSON.parse(fs.readFileSync(process.env.ELASTICJUDGE_VERDICT_JSON, "utf8"));
const axes = report.axes || {};
const out = {};
for (const key of [
  "factual_correctness",
  "elastic_domain_accuracy",
  "brand_voice",
  "exec_readiness",
  "safety",
]) {
  out[key] = axes[key] && typeof axes[key].score === "number" ? axes[key].score : null;
}
out.verdict = report.verdict || null;
process.stdout.write(JSON.stringify(out) + "\n");
EOF

if [[ -n "$OUT_PATH" ]]; then
  cp "$VERDICT_PATH" "$OUT_PATH"
fi
