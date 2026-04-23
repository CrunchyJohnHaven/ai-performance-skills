#!/usr/bin/env bash
# Bootstrap the BrainOfBrains substrate into the current workspace.
# Prefers the remote installer at https://brainofbrains.ai/install; falls back
# to the npm package @sapperjohn/brainofbrains if the remote is unreachable.
# Idempotent: safe no-op when already installed. Refresh requires an explicit
# remove-and-reinstall or a package-backed update path.
# Never stands up a local MCP server. May contact the installer URL or package
# registry, but does not upload workspace data.

set -euo pipefail

REMOTE_INSTALL_URL="https://brainofbrains.ai/install"
PKG="@sapperjohn/brainofbrains"
WORKSPACE="$(pwd)"

echo "[brainofbrains] bootstrapping brain substrate into $WORKSPACE"

# Idempotency check: skip install if bin/brain already exists and is executable.
if [[ -x "$WORKSPACE/bin/brain" ]]; then
  echo "[brainofbrains] bin/brain already installed at $WORKSPACE/bin/brain — skipping install."
  echo "  to force a refresh, remove bin/brain and re-run this script."
  exit 0
fi

if command -v curl >/dev/null 2>&1; then
  if curl -fsSL --max-time 20 -o /dev/null -I "$REMOTE_INSTALL_URL" 2>/dev/null; then
    echo "[brainofbrains] using remote installer: $REMOTE_INSTALL_URL"
    # WARNING: This runs a remote install script. Review at https://brainofbrains.ai/install before running.
    curl -fsSL "$REMOTE_INSTALL_URL" | bash -s -- "$@"
  else
    echo "[brainofbrains] remote installer unreachable; falling back to npm package"
    if ! command -v npx >/dev/null 2>&1; then
      echo "error: npx not found and remote installer unreachable." >&2
      echo "  install Node.js (>=18) or retry when $REMOTE_INSTALL_URL is reachable." >&2
      exit 1
    fi
    npx --yes "$PKG" install "$@"
  fi
else
  echo "[brainofbrains] curl not available; using npm package"
  if ! command -v npx >/dev/null 2>&1; then
    echo "error: neither curl nor npx available. install Node.js (>=18) and try again." >&2
    exit 1
  fi
  npx --yes "$PKG" install "$@"
fi

echo
echo "[brainofbrains] done."
echo "  brains live under: $WORKSPACE/evidence/brain/"
echo "  CLI entry point:   $WORKSPACE/bin/brain"
echo "  registry:          $WORKSPACE/evidence/brain/brains.json"
echo
echo "  next: scripts/scan.sh                  — list installed brains + status"
echo "  then: scripts/ask.sh \"<question>\"       — ask the right specialist brain"
echo "  then: scripts/health.sh                — local status snapshot + per-brain labels"
