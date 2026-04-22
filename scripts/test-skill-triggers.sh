#!/usr/bin/env bash
# Test skill trigger activation using claude -p (non-interactive mode).
# Requires: claude CLI in PATH, skills installed in ~/.claude/skills/
# Note: claude -p does not load user skills from ~/.claude/skills/ by default.
# These tests verify INTENT matching — whether Claude's response indicates the
# skill would be relevant — not actual skill execution.

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

PASS=0
FAIL=0
SKIP=0

log_result() {
    local status="$1"
    local label="$2"
    local detail="$3"
    printf "%-8s %s\n         %s\n" "${status}" "${label}" "${detail}"
}

# Check for claude in PATH before running any tests
if ! command -v claude >/dev/null 2>&1; then
    echo "SKIP  claude not found in PATH — install the Claude CLI and retry."
    echo "      https://docs.anthropic.com/claude/reference/claude-cli"
    exit 0
fi

echo "AI Performance Skills — skill trigger intent tests"
echo "==================================================="
echo "Mode  : intent matching via 'claude -p' (non-interactive)"
echo "claude: $(command -v claude)"
echo ""

# ---------------------------------------------------------------------------
# Test runner
# ---------------------------------------------------------------------------

run_test() {
    local label="$1"
    local prompt="$2"
    local keywords="$3"   # pipe-separated, e.g. "cost|optimize|LLM"

    local result
    result=$(claude -p "${prompt}" --no-session-persistence 2>&1 | head -5) || {
        log_result "FAIL" "${label}" "claude -p exited non-zero; prompt='${prompt}'"
        FAIL=$((FAIL + 1))
        return
    }

    # Case-insensitive match against the keyword alternatives
    local matched=false
    local IFS_SAVED="${IFS}"
    IFS='|'
    for kw in ${keywords}; do
        IFS="${IFS_SAVED}"
        if echo "${result}" | grep -qi "${kw}"; then
            matched=true
            break
        fi
    done
    IFS="${IFS_SAVED}"

    if "${matched}"; then
        log_result "PASS" "${label}" "prompt='${prompt}'"
        PASS=$((PASS + 1))
    else
        log_result "FAIL" "${label}" "prompt='${prompt}' | expected one of: ${keywords} | got: $(echo "${result}" | tr '\n' ' ' | cut -c1-120)"
        FAIL=$((FAIL + 1))
    fi
}

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

# 1. cost-optimization — waste signal
run_test \
    "cost-opt: token waste signal" \
    "am I wasting tokens?" \
    "cost|optimize|LLM"

# 2. cost-optimization — bill reduction
run_test \
    "cost-opt: lower AI bill" \
    "lower my AI bill" \
    "cost|LLM|savings"

# 3. brainofbrains — expert query
run_test \
    "brainofbrains: ask expert brain" \
    "ask the expert brain" \
    "brain|substrate|BIV"

# 4. elasticjudge — pre-send quality gate
run_test \
    "elasticjudge: judge memo before send" \
    "judge this memo before I send it" \
    "judge|quality|Elastic"

# 5. brainofbrains — BIV score query
run_test \
    "brainofbrains: BIV score query" \
    "what is the BIV score?" \
    "brain|BIV|substrate"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "==================================================="
echo "Results: ${PASS} passed, ${FAIL} failed, ${SKIP} skipped"
echo ""

if [ "${FAIL}" -gt 0 ]; then
    echo "Note: FAIL means Claude's first 5 lines did not mention an expected"
    echo "keyword. The skill may still activate; this harness tests INTENT only."
    echo "Run the prompt interactively in Claude Code for full skill validation."
    exit 1
fi

exit 0
