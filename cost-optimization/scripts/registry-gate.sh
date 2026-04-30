#!/usr/bin/env bash
# Check whether the npm release gate has cleared before public skill sync.

set -euo pipefail

KOSTAI_PACKAGE="${KOSTAI_PACKAGE:-@sapperjohn/kostai}"
KOSTAI_MIN_VERSION="${KOSTAI_MIN_VERSION:-0.5.2}"
KOSTAI_NPM_CACHE="${KOSTAI_NPM_CACHE:-${NPM_CONFIG_CACHE:-/tmp/kostai-npm-cache}}"
KOSTAI_NPM_FETCH_TIMEOUT_MS="${KOSTAI_NPM_FETCH_TIMEOUT_MS:-10000}"
KOSTAI_NPM_FETCH_RETRIES="${KOSTAI_NPM_FETCH_RETRIES:-0}"

if ! command -v npm >/dev/null 2>&1; then
  echo "error: npm not found. install Node.js (>=18) and try again." >&2
  exit 2
fi
if ! command -v node >/dev/null 2>&1; then
  echo "error: node not found. install Node.js (>=18) and try again." >&2
  exit 2
fi

LATEST="$(npm --cache="$KOSTAI_NPM_CACHE" --fetch-timeout="$KOSTAI_NPM_FETCH_TIMEOUT_MS" --fetch-retries="$KOSTAI_NPM_FETCH_RETRIES" view "$KOSTAI_PACKAGE" version 2>/dev/null || true)"
if [[ -z "$LATEST" ]]; then
  echo "blocked: unable to read npm registry version for $KOSTAI_PACKAGE." >&2
  echo "do not sync the public ai-performance-skills repo yet." >&2
  exit 2
fi

node - "$LATEST" "$KOSTAI_MIN_VERSION" <<'EOF'
const [latest, min] = process.argv.slice(2);

function parse(version) {
  const match = /^(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$/.exec(version);
  if (!match) {
    throw new Error(`invalid semver: ${version}`);
  }
  return match.slice(1).map(Number);
}

const [la, lb, lc] = parse(latest);
const [ma, mb, mc] = parse(min);
const ok = la > ma || (la === ma && (lb > mb || (lb === mb && lc >= mc)));

if (!ok) {
  console.error(`blocked: npm latest ${latest} is below required ${min}.`);
  console.error("do not sync the public ai-performance-skills repo yet.");
  process.exit(1);
}

console.log(`ok: npm latest ${latest} satisfies required ${min}.`);
console.log("public ai-performance-skills sync may proceed from a clean worktree.");
EOF
