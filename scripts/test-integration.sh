#!/usr/bin/env bash
# Integration tests for all three skills.
# Requires: npx, @sapperjohn/kostai, Node.js >=18
# Run from repo root. Exits 0 if all pass, 1 if any fail.

set -uo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

PASS=0
FAIL=0
SKIP=0

# Colour codes (disabled when not a terminal)
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  GREEN='' RED='' YELLOW='' BOLD='' RESET=''
fi

_pass() {
  PASS=$((PASS + 1))
  printf "${GREEN}PASS${RESET}  %s\n" "$1"
}

_fail() {
  FAIL=$((FAIL + 1))
  printf "${RED}FAIL${RESET}  %s\n" "$1"
  if [ -n "${2:-}" ]; then
    printf "      %s\n" "$2"
  fi
}

_skip() {
  SKIP=$((SKIP + 1))
  printf "${YELLOW}SKIP${RESET}  %s — %s\n" "$1" "${2:-prerequisite not met}"
}

_header() {
  printf "\n${BOLD}%s${RESET}\n" "$1"
}

# Run a command, capture combined stdout+stderr, return exit code.
# Usage: _run <label> <cmd...>
_run() {
  local label="$1"; shift
  local output
  output="$("$@" 2>&1)" && local rc=0 || local rc=$?
  printf '%s' "$output"
  return $rc
}

# Resolve repo root (the directory that contains this script's parent).
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS=(cost-optimization brainofbrains elasticjudge)

# ---------------------------------------------------------------------------
# Counters per group
# ---------------------------------------------------------------------------
declare -A GROUP_PASS GROUP_FAIL
for g in A B C D; do
  GROUP_PASS[$g]=0
  GROUP_FAIL[$g]=0
done

g_pass() { GROUP_PASS[$1]=$((GROUP_PASS[$1] + 1)); _pass "$2"; PASS=$((PASS + 1)); }
g_fail() { GROUP_FAIL[$1]=$((GROUP_FAIL[$1] + 1)); _fail "$2" "${3:-}"; FAIL=$((FAIL + 1)); }
g_skip() { _skip "$2" "${3:-prerequisite not met}"; SKIP=$((SKIP + 1)); }

# ---------------------------------------------------------------------------
# Pre-flight: must run from repo root
# ---------------------------------------------------------------------------
if [ ! -f "${REPO_ROOT}/Makefile" ] || [ ! -d "${REPO_ROOT}/cost-optimization" ]; then
  echo "error: run this script from the repo root (the directory containing Makefile)." >&2
  echo "  e.g.  bash scripts/test-integration.sh" >&2
  exit 1
fi
cd "${REPO_ROOT}" || exit 1

# ---------------------------------------------------------------------------
# Group A — CLI availability
# ---------------------------------------------------------------------------
_header "Group A — CLI availability"

# A1: --version exits 0
VERSION_OUT="$(npx --yes @sapperjohn/kostai --version 2>&1)" && A1_OK=true || A1_OK=false
if $A1_OK; then
  g_pass A "npx @sapperjohn/kostai --version exits 0"
else
  g_fail A "npx @sapperjohn/kostai --version exits 0" "$VERSION_OUT"
fi

# A2: version is >=0.5.0
if $A1_OK; then
  # Extract the first semver-like token from the output.
  RAW_VER="$(printf '%s' "$VERSION_OUT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  if [ -z "$RAW_VER" ]; then
    g_fail A "version is >=0.5.0 (parse version)" "could not parse a version from: $VERSION_OUT"
  else
    MAJOR="$(printf '%s' "$RAW_VER" | cut -d. -f1)"
    MINOR="$(printf '%s' "$RAW_VER" | cut -d. -f2)"
    PATCH="$(printf '%s' "$RAW_VER" | cut -d. -f3)"
    # Compare: major>0 OR (major==0 AND minor>5) OR (major==0 AND minor==5 AND patch>=0)
    if [ "$MAJOR" -gt 0 ] || \
       { [ "$MAJOR" -eq 0 ] && [ "$MINOR" -gt 5 ]; } || \
       { [ "$MAJOR" -eq 0 ] && [ "$MINOR" -eq 5 ] && [ "$PATCH" -ge 0 ]; }; then
      g_pass A "version is >=0.5.0 (got ${RAW_VER})"
    else
      g_fail A "version is >=0.5.0 (got ${RAW_VER})" "upgrade: npm install -g @sapperjohn/kostai"
    fi
  fi
else
  g_skip A "version is >=0.5.0 (parse version)" "A1 failed"
fi

# A3: scan exits 0
SCAN_OUT="$(npx --yes @sapperjohn/kostai scan 2>&1)" && A3_OK=true || A3_OK=false
if $A3_OK; then
  g_pass A "npx @sapperjohn/kostai scan exits 0"
else
  g_fail A "npx @sapperjohn/kostai scan exits 0" "$(printf '%s' "$SCAN_OUT" | head -3)"
fi

# A4: report exits 0 and produces non-empty output
REPORT_OUT="$(npx --yes @sapperjohn/kostai report 2>&1)" && A4_OK=true || A4_OK=false
if $A4_OK && [ -n "$REPORT_OUT" ]; then
  g_pass A "npx @sapperjohn/kostai report exits 0 and produces non-empty output"
elif $A4_OK && [ -z "$REPORT_OUT" ]; then
  g_fail A "npx @sapperjohn/kostai report exits 0 and produces non-empty output" "command exited 0 but produced no output"
else
  g_fail A "npx @sapperjohn/kostai report exits 0 and produces non-empty output" "$(printf '%s' "$REPORT_OUT" | head -3)"
fi

# ---------------------------------------------------------------------------
# Group B — Script behavior
# ---------------------------------------------------------------------------
_header "Group B — Script behavior"

# B1: cost-optimization/scripts/proof.sh exits 0 with no args (produces stdout)
PROOF_SH="${REPO_ROOT}/cost-optimization/scripts/proof.sh"
if [ -f "$PROOF_SH" ]; then
  PROOF_OUT="$(bash "$PROOF_SH" 2>&1)" && B1_OK=true || B1_OK=false
  if $B1_OK && [ -n "$PROOF_OUT" ]; then
    g_pass B "cost-optimization/scripts/proof.sh exits 0 with stdout"
  elif $B1_OK; then
    g_fail B "cost-optimization/scripts/proof.sh exits 0 with stdout" "exited 0 but produced no output"
  else
    g_fail B "cost-optimization/scripts/proof.sh exits 0 with stdout" "$(printf '%s' "$PROOF_OUT" | head -3)"
  fi
else
  g_fail B "cost-optimization/scripts/proof.sh exits 0 with stdout" "script not found at $PROOF_SH"
fi

# B2: cost-optimization/scripts/scan.sh exits 0
SCAN_SH="${REPO_ROOT}/cost-optimization/scripts/scan.sh"
if [ -f "$SCAN_SH" ]; then
  B2_OUT="$(bash "$SCAN_SH" 2>&1)" && B2_OK=true || B2_OK=false
  if $B2_OK; then
    g_pass B "cost-optimization/scripts/scan.sh exits 0"
  else
    g_fail B "cost-optimization/scripts/scan.sh exits 0" "$(printf '%s' "$B2_OUT" | head -3)"
  fi
else
  g_fail B "cost-optimization/scripts/scan.sh exits 0" "script not found at $SCAN_SH"
fi

# B3: brainofbrains/scripts/ask.sh with no args exits non-zero with an error message
ASK_SH="${REPO_ROOT}/brainofbrains/scripts/ask.sh"
if [ -f "$ASK_SH" ]; then
  B3_OUT="$(bash "$ASK_SH" 2>&1)" && B3_OK=true || B3_OK=false
  if ! $B3_OK && [ -n "$B3_OUT" ]; then
    g_pass B "brainofbrains/scripts/ask.sh with no args exits non-zero with error message"
  elif $B3_OK; then
    g_fail B "brainofbrains/scripts/ask.sh with no args exits non-zero with error message" "exited 0 (expected non-zero)"
  else
    g_fail B "brainofbrains/scripts/ask.sh with no args exits non-zero with error message" "exited non-zero but produced no error message"
  fi
else
  g_fail B "brainofbrains/scripts/ask.sh with no args exits non-zero with error message" "script not found at $ASK_SH"
fi

# B4: elasticjudge/scripts/judge.sh with no args exits non-zero with an error message
JUDGE_SH="${REPO_ROOT}/elasticjudge/scripts/judge.sh"
if [ -f "$JUDGE_SH" ]; then
  B4_OUT="$(bash "$JUDGE_SH" 2>&1)" && B4_OK=true || B4_OK=false
  if ! $B4_OK && [ -n "$B4_OUT" ]; then
    g_pass B "elasticjudge/scripts/judge.sh with no args exits non-zero with error message"
  elif $B4_OK; then
    g_fail B "elasticjudge/scripts/judge.sh with no args exits non-zero with error message" "exited 0 (expected non-zero)"
  else
    g_fail B "elasticjudge/scripts/judge.sh with no args exits non-zero with error message" "exited non-zero but produced no error message"
  fi
else
  g_fail B "elasticjudge/scripts/judge.sh with no args exits non-zero with error message" "script not found at $JUDGE_SH"
fi

# ---------------------------------------------------------------------------
# Group C — Skill structure (per-skill checks)
# ---------------------------------------------------------------------------
_header "Group C — Skill structure"

# Helper: extract script names listed in SKILL.md under the Scripts section.
# Looks for lines like: `- \`<script.sh>\``  or  `- <script.sh>`
_scripts_in_skill_md() {
  local skill_md="$1"
  grep -E "^\s*[-*]\s+\`?[a-zA-Z0-9_-]+\.sh\`?" "$skill_md" \
    | grep -oE "[a-zA-Z0-9_-]+\.sh" \
    | sort -u
}

for skill in "${SKILLS[@]}"; do
  SKILL_DIR="${REPO_ROOT}/${skill}"
  SKILL_MD="${SKILL_DIR}/SKILL.md"

  # C1: SKILL.md exists
  if [ -f "$SKILL_MD" ]; then
    g_pass C "${skill}/SKILL.md exists"
  else
    g_fail C "${skill}/SKILL.md exists" "not found at $SKILL_MD"
    # Skip dependent checks if the file doesn't exist
    continue
  fi

  # C2: frontmatter contains name:, description:, allowed-tools:
  FRONTMATTER_LABEL="${skill}/SKILL.md contains name: description: allowed-tools: in frontmatter"
  FM_FAIL=false
  for field in "name:" "description:" "allowed-tools:"; do
    if ! grep -q "^${field}" "$SKILL_MD"; then
      g_fail C "$FRONTMATTER_LABEL" "missing frontmatter field: $field"
      FM_FAIL=true
      break
    fi
  done
  if ! $FM_FAIL; then
    g_pass C "$FRONTMATTER_LABEL"
  fi

  # C3: has a ## Gotchas section
  if grep -q "^## Gotchas" "$SKILL_MD"; then
    g_pass C "${skill}/SKILL.md has ## Gotchas section"
  else
    g_fail C "${skill}/SKILL.md has ## Gotchas section" "no '## Gotchas' heading found"
  fi

  # C4: all scripts listed in SKILL.md exist on disk
  SCRIPTS_LABEL="${skill}: all scripts listed in SKILL.md exist on disk"
  SCRIPTS_MISSING=()
  while IFS= read -r script_name; do
    [ -z "$script_name" ] && continue
    script_path="${SKILL_DIR}/scripts/${script_name}"
    if [ ! -f "$script_path" ]; then
      SCRIPTS_MISSING+=("$script_name")
    fi
  done < <(_scripts_in_skill_md "$SKILL_MD")

  if [ ${#SCRIPTS_MISSING[@]} -eq 0 ]; then
    g_pass C "$SCRIPTS_LABEL"
  else
    g_fail C "$SCRIPTS_LABEL" "missing: ${SCRIPTS_MISSING[*]}"
  fi
done

# ---------------------------------------------------------------------------
# Group D — Install
# ---------------------------------------------------------------------------
_header "Group D — Install"

# D1: scripts/install-all.sh --dry-run exits 0 and mentions all 3 skills
INSTALL_SH="${REPO_ROOT}/scripts/install-all.sh"
if [ -f "$INSTALL_SH" ]; then
  DRY_OUT="$(bash "$INSTALL_SH" --dry-run 2>&1)" && D1_OK=true || D1_OK=false
  if $D1_OK; then
    D1_MISSING=()
    for skill in "${SKILLS[@]}"; do
      if ! printf '%s' "$DRY_OUT" | grep -q "$skill"; then
        D1_MISSING+=("$skill")
      fi
    done
    if [ ${#D1_MISSING[@]} -eq 0 ]; then
      g_pass D "scripts/install-all.sh --dry-run exits 0 and mentions all 3 skills"
    else
      g_fail D "scripts/install-all.sh --dry-run exits 0 and mentions all 3 skills" \
        "not mentioned in output: ${D1_MISSING[*]}"
    fi
  else
    g_fail D "scripts/install-all.sh --dry-run exits 0 and mentions all 3 skills" \
      "$(printf '%s' "$DRY_OUT" | head -3)"
  fi
else
  g_fail D "scripts/install-all.sh --dry-run exits 0 and mentions all 3 skills" \
    "script not found at $INSTALL_SH"
fi

# D2: make check exits 0
MAKE_OUT="$(make -C "${REPO_ROOT}" check 2>&1)" && D2_OK=true || D2_OK=false
if $D2_OK; then
  g_pass D "make check exits 0"
else
  g_fail D "make check exits 0" "$(printf '%s' "$MAKE_OUT" | tail -5)"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
TOTAL_PASS=$PASS
TOTAL_FAIL=$FAIL

printf "\n${BOLD}%s${RESET}\n" "============================================================"
printf "${BOLD}%-12s  %-4s  %-4s${RESET}\n" "Group" "PASS" "FAIL"
printf "%-12s  %-4s  %-4s\n" "------------" "----" "----"
for g in A B C D; do
  label=""
  case $g in
    A) label="A — CLI" ;;
    B) label="B — Scripts" ;;
    C) label="C — Structure" ;;
    D) label="D — Install" ;;
  esac
  printf "%-12s  %-4s  %-4s\n" "$label" "${GROUP_PASS[$g]}" "${GROUP_FAIL[$g]}"
done
printf "%-12s  %-4s  %-4s\n" "------------" "----" "----"
printf "${BOLD}%-12s  %-4s  %-4s${RESET}\n" "Total" "$TOTAL_PASS" "$TOTAL_FAIL"
if [ "$SKIP" -gt 0 ]; then
  printf "(skipped: %d)\n" "$SKIP"
fi
printf '\n'

if [ "$TOTAL_FAIL" -gt 0 ]; then
  printf "${RED}%d test(s) failed.${RESET}\n" "$TOTAL_FAIL"
  exit 1
else
  printf "${GREEN}All %d tests passed.${RESET}\n" "$TOTAL_PASS"
  exit 0
fi
