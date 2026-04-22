#!/usr/bin/env bash
# Ask the right specialist brain. Routes the question through the substrate
# via `bin/brain query` and returns a synthesized answer with citations.
# Usage:
#   scripts/ask.sh "<question>"
#   scripts/ask.sh --json "<question>"
#   scripts/ask.sh "<question>" [--deep]       # include L2 closet excerpts
#
# Any unrecognized flags are forwarded to `bin/brain query`.

set -euo pipefail

WORKSPACE="$(pwd)"
BRAIN="$WORKSPACE/bin/brain"

if [[ ! -x "$BRAIN" ]]; then
  echo "error: bin/brain not found or not executable at $BRAIN" >&2
  echo "  run scripts/install.sh first." >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  echo "usage: scripts/ask.sh \"<question>\" [flags]" >&2
  echo "  example: scripts/ask.sh \"what does the Jesse brain say about Q3?\"" >&2
  exit 2
fi

QUESTION=""
PASSTHROUGH=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json|--deep|--trace)
      PASSTHROUGH+=("$1")
      shift
      ;;
    --*)
      PASSTHROUGH+=("$1")
      if [[ $# -ge 2 && "${2:-}" != --* ]]; then
        PASSTHROUGH+=("$2")
        shift 2
      else
        shift
      fi
      ;;
    *)
      if [[ -z "$QUESTION" ]]; then
        QUESTION="$1"
      else
        PASSTHROUGH+=("$1")
      fi
      shift
      ;;
  esac
done

if [[ -z "$QUESTION" ]]; then
  echo "error: missing question" >&2
  echo "usage: scripts/ask.sh \"<question>\" [flags]" >&2
  exit 2
fi

echo "[brainofbrains] routing question to the substrate"
"$BRAIN" query --query "$QUESTION" "${PASSTHROUGH[@]}"
