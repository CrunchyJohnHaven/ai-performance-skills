#!/usr/bin/env bash
# Ask the right specialist brain. Routes the question through the substrate
# via `bin/brain query` and returns a synthesized answer with citations.
# Usage:
#   scripts/ask.sh "<question>"
#   scripts/ask.sh --json "<question>"
#   scripts/ask.sh "<question>" [--deep]          # include L2 closet excerpts
#   scripts/ask.sh --depth l0|l1|l2 "<question>"  # closet depth (default: l1)
#   scripts/ask.sh --output <file> "<question>"   # save answer to file
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
DEPTH="l1"
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --depth)
      if [[ $# -lt 2 ]]; then
        echo "error: --depth requires a value (l0, l1, or l2)" >&2
        exit 2
      fi
      case "$2" in
        l0|l1|l2) DEPTH="$2" ;;
        *)
          echo "error: --depth must be l0, l1, or l2 (got: $2)" >&2
          exit 2
          ;;
      esac
      shift 2
      ;;
    --output)
      if [[ $# -lt 2 ]]; then
        echo "error: --output requires a file path" >&2
        exit 2
      fi
      OUTPUT_FILE="$2"
      shift 2
      ;;
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

# Probe whether bin/brain query supports --depth before passing it.
_BRAIN_QUERY_HELP="$("$BRAIN" query --help 2>&1)" || true
if echo "$_BRAIN_QUERY_HELP" | grep -q 'depth'; then
  PASSTHROUGH+=("--depth" "$DEPTH")
fi

echo "[brainofbrains] routing question to the substrate"

if [[ -n "$OUTPUT_FILE" ]]; then
  "$BRAIN" query --query "$QUESTION" "${PASSTHROUGH[@]}" > "$OUTPUT_FILE"
  echo "[brainofbrains] answer saved to $OUTPUT_FILE"
else
  "$BRAIN" query --query "$QUESTION" "${PASSTHROUGH[@]}"
fi
