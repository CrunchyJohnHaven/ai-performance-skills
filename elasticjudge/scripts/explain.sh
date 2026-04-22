#!/usr/bin/env bash
# Re-run a prior verdict with ?explain=1 to retrieve line-level critiques.
# Takes the verdict JSON written by scripts/judge.sh and asks the API to
# expand the critique surface with specific sentence-level reason codes.
#
# Usage:
#   scripts/explain.sh deliverables/judge-run-2026-04-22/verdict.json
#
# Writes critiques.json next to the input file and prints a short markdown
# summary to stdout.

set -euo pipefail

if ! command -v curl >/dev/null 2>&1; then
  echo "error: curl not found. install curl and try again." >&2
  exit 1
fi

BASE_URL="${ELASTICJUDGE_URL:-https://elasticjudge.com}"
ENDPOINT="${BASE_URL}/v1/evaluate"

VERDICT_PATH="${1:-}"

if [[ -z "$VERDICT_PATH" ]]; then
  echo "usage: scripts/explain.sh <verdict.json>" >&2
  exit 2
fi

if [[ ! -f "$VERDICT_PATH" ]]; then
  echo "error: verdict file not found: $VERDICT_PATH" >&2
  exit 2
fi

PAYLOAD_PATH="$(mktemp -t elasticjudge-explain.XXXXXX.json)"
CRITIQUES_PATH="$(dirname "$VERDICT_PATH")/critiques.json"
trap 'rm -f "$PAYLOAD_PATH"' EXIT

ELASTICJUDGE_VERDICT="$VERDICT_PATH" \
node <<'EOF' > "$PAYLOAD_PATH"
const fs = require("node:fs");
const prior = JSON.parse(fs.readFileSync(process.env.ELASTICJUDGE_VERDICT, "utf8"));
process.stdout.write(JSON.stringify({
  mode: "explain",
  prior_verdict: prior,
  request_line_level: true,
}));
EOF

AUTH_HEADER=()
if [[ -n "${ELASTICJUDGE_API_KEY:-}" ]]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${ELASTICJUDGE_API_KEY}")
fi

echo "[elasticjudge] requesting line-level critiques"
HTTP_STATUS="$(
  curl -sS -o "$CRITIQUES_PATH" -w '%{http_code}' \
    -X POST "${ENDPOINT}?explain=1" \
    -H "Content-Type: application/json" \
    "${AUTH_HEADER[@]}" \
    --data-binary "@${PAYLOAD_PATH}"
)"

if [[ "$HTTP_STATUS" != "200" ]]; then
  echo "error: ElasticJudge returned HTTP $HTTP_STATUS" >&2
  if [[ -f "$CRITIQUES_PATH" ]]; then
    cat "$CRITIQUES_PATH" >&2 || true
  fi
  exit 1
fi

ELASTICJUDGE_CRITIQUES="$CRITIQUES_PATH" \
node <<'EOF'
const fs = require("node:fs");
const report = JSON.parse(fs.readFileSync(process.env.ELASTICJUDGE_CRITIQUES, "utf8"));
const critiques = Array.isArray(report.critiques) ? report.critiques : [];
console.log(`[elasticjudge] ${critiques.length} line-level critique(s)`);
for (const c of critiques.slice(0, 40)) {
  const axis = c.axis || "axis?";
  const locator = c.locator || "line ?";
  const reason = c.reason || "";
  console.log(`- [${axis}] ${locator}: ${reason}`);
}
EOF

echo
echo "[elasticjudge] wrote $CRITIQUES_PATH"
