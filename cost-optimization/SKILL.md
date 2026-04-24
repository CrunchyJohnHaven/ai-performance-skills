---
name: cost-optimization
description: Use when the user says "AI Performance", "reduce LLM cost", "lower my AI bill", "cut Claude Code spend", "optimize my LLM calls", "route to cheaper models", "am I wasting tokens", "prove my LLM savings", or mentions Claude Code / Codex / Gemini CLI spend getting out of hand. Runs the KostAI toolchain (`@sapperjohn/kostai`) to scan, optimize, and emit a proof-of-savings artifact.
version: 0.2.0
allowed-tools: Bash
when_to_use: "Use when the active workspace has a Claude Code / Codex / Gemini CLI workflow and the user wants to reduce LLM spend or prove savings."
---

# AI Performance

User-facing catalog label: `AI Performance`.

Cut LLM spend on local-filesystem-heavy Claude Code, Codex, and Gemini CLI work without changing what the user asks for. Lead with better performance for the employee: faster responses, less waste, cleaner context, measurable savings. Target: 60–92% input-token reduction and a proof artifact an employee can show a manager or CIO.

## When to use

Trigger this skill when the user expresses any of:
- cost concern — "my Claude bill is too high", "we spent $X this week", "cut LLM cost"
- optimization intent — "route this to a cheaper model", "compress this prompt", "deduplicate this context"
- proof need — "show my manager the savings", "prove this to the CIO", "one-page receipt"
- setup intent — "install AI Performance", "install cost-optimization", "set up ai-cost", "configure kostai"
- waste signals — "am I wasting tokens", "why is this call so expensive", "find my most expensive prompts"
- field-rollout intent — "how do I update this skill", "how do I share results", "how do I send feedback back to the team"

Do not trigger on unrelated cost questions (cloud bill, vendor contracts) — this skill only addresses LLM call cost in desktop AI-coding tools.

## What this skill does

The skill delegates to the `ai-cost` (alias `kostai`) CLI, which implements 42 cost-reduction techniques across nine categories: model routing, context compression, waste detection, caching, shadow-mode A/B, local inference, batching and deliberation, budget governance, and observability. The CLI is the single source of truth; this skill orients Claude to invoke the right verbs in the right order.

Distribution detail: the user-facing label is `AI Performance`. In this public repo the folder is `cost-optimization/`; packaged npm builds ship the same contents under `skills/cost-optimization/`.

Full capability inventory is in `references/capabilities.md`. Savings-layer mechanics are in `references/savings-layers.md`. The CIO-grade proof workflow is in `references/verification.md`. Elastic-specific deployment notes are in `references/elastic-notes.md`. For Elastic pilot work shaped by Adnan's 2026-04-22 ask, load `references/adnan-pilot.md` before recommending expansion.

## Workflow

Execute steps in order. Each step is a single CLI call wrapped by a script in `scripts/`. Read the script before invoking if the user has non-default config.

### 1. Install

Run `scripts/install.sh` (or `npx @sapperjohn/kostai init` directly). This one-click bootstrap writes `ai-cost.config.json`, applies safe starter patches (Anthropic prompt caching, prose compression, expensive-model gate), and refreshes the savings plan. Idempotent — re-running is safe.

The install step never exfiltrates code or prompts. Capture mode defaults to `metadata_only` (hashes and token counts, no body). The user can opt into `redacted_body` or `full_body` for local debugging by editing `ai-cost.config.json`.

### 2. Scan

Run `scripts/scan.sh` to detect local LLM runtimes (Ollama, LM Studio, OpenAI-compat) and enumerate which repo files contain LLM call sites. Output lists free local compute that can absorb non-frontier work, plus the exact source locations the optimize step will target.

### 3. Optimize

Run `scripts/optimize.sh` to run `kostai scan`, which outputs LLM call sites and runtime detections to stdout. The calling agent reviews the scan output and applies high-savings changes manually. Do not batch-apply — one patch per commit so savings can be attributed per technique.

### 4. Verify

Run `scripts/proof.sh` after at least one shadow-mode comparison has landed in `.ai-cost-data/comparisons.jsonl`. This writes:
- `deliverables/<audience>-<date>/PROOF.md` — markdown one-pager
- `deliverables/<audience>-<date>/PROOF.html` — browser-ready one-pager
- `deliverables/<audience>-<date>/proof.json` — machine-readable proof payload

The proof shows measured savings per technique, total dollars saved, quality signal from the evaluator, and the 10%-pass-through pricing math. Every numeric claim is labeled Measured, Modeled, or Needs verification. See `references/verification.md` for how to read it and what to say to a CIO.

### 5. Share feedback back to the rollout team (optional)

Run `scripts/feedback.sh` to generate a privacy-safe local feedback packet from the same proof data. This emits:
- `deliverables/<audience>-<date>/FEEDBACK.md` — share-ready markdown summary
- `deliverables/<audience>-<date>/SLACK.md` — short message an employee can paste into Slack or email
- `deliverables/<audience>-<date>/DAY_30_MEMO.md` — pilot decision memo with expand / hand off / walk away posture

This step never sends data automatically. It only prepares an opt-in packet the employee may choose to share. Prompt and response bodies stay local; the packet is aggregate counts, savings totals, mechanism breakdown, and optional user notes.

For Adnan-facing pilots, the feedback packet must preserve shadow-only posture until the owner-approved quality gate clears. The default gates are at least 20% Measured savings and at least 95% quality parity; see `references/adnan-pilot.md`.

### 6. Update the skill (optional)

Run `scripts/update.sh` when the skill was installed from npm or copied into a local skills directory and a refresh is needed. The update path:
- refreshes the globally installed `@sapperjohn/kostai` package
- preserves symlink installs automatically
- refreshes copied skill folders when they live outside a git worktree
- avoids mutating a checked-out repo skill folder unless the operator chooses to re-copy manually

This is the intended v1 update path for employees before a richer catalog-managed update surface exists.

### 7. Demonstrate (optional)

For first-time users or demo walkthroughs, run `scripts/demo.sh` to seed a deterministic before/after workload. The demo is a ten-question test that reproducibly shows a 92% savings swing (Measured on the reference hardware; Modeled for other workloads). Use this when the user says "show me a demo" or "run the KostAI demo".

## Which models this covers

All of them. The skill is provider-agnostic:
- Anthropic (Claude Sonnet, Opus, Haiku)
- OpenAI (GPT-4, GPT-5, o-series)
- Google (Gemini Pro, Flash, local Gemma variants)
- Ollama / LM Studio / OpenAI-compat local endpoints
- Any provider the workspace's SDK wrapper can reach

The router does not gate which model the user can call. It either downgrades the default to a cheaper tier when the classifier is confident, or emits an auditable elevation record when a pricier tier is justified.

## Which tasks this covers

Most Claude Code / Codex / Gemini CLI tasks that touch local files. Specifically effective on:
- long system prompts and memory files (prose compressor drops ~46% input tokens)
- repeated prompts across sessions (prompt cache replays at ~90% discount)
- large tool output (shell dumps, file reads, API bodies — tool-result compression)
- agent loops with moderate input and long output (Draft-Verify-Patch collapses output tokens)
- workloads where a local model can draft and the frontier only validates (local preprocess)

Tasks that stay on the frontier because they must: OCR-heavy multimodal, novel reasoning over large contexts, final-stage judge passes. The skill does not force downgrades that hurt quality — the shadow-mode evaluator prevents "cheaper but worse" regressions.

## Safety and data posture

- No data leaves the user's machine unless the user explicitly enables a remote endpoint. All capture is local JSONL + SQLite under `.ai-cost-data/`.
- No secrets are persisted. `src/privacy/redact.ts` is a TABOO path — its redaction correctness gates every capture mode.
- No MCP server is installed by default. MCP is available as an optional integration but carries a token tax and can read as surveillance; default is off. Users can opt in with `ai-cost mcp`.
- No expensive operations run without the user's consent. Budget gates in `ai-cost.config.json` hard-cap per-task and per-wave spend.
- No background telemetry is sent to a central service. The optional feedback step is manual, opt-in, and emits local aggregate artifacts only.

## Escalation and fallback

If a step fails, the CLI emits structured errors. Report the error to the user verbatim, check `docs/BUG_LEDGER.md` for known issues, and fall back to:
- `npx kostai doctor` — diagnoses config and prerequisites
- `npx kostai scan` — lists detected local runtimes and LLM call sites
- `npx kostai --help` — full CLI surface

Never fabricate savings numbers. If the ledger is empty (new install), say so and run the demo step to seed data. If the shadow-mode comparisons show negative savings, surface that — do not suppress.

## Bundled resources

Scripts (`scripts/`):
- `install.sh` — one-click bootstrap (wraps `kostai init`)
- `scan.sh` — detect local runtimes and LLM call sites
- `optimize.sh` — wraps `kostai scan` → stdout call-site + runtime report
- `proof.sh` — wraps `kostai proof` → writes PROOF.md, PROOF.html, and proof.json
- `feedback.sh` — build an opt-in aggregate feedback packet for sharing
- `update.sh` — refresh the shipped skill from the latest npm package
- `demo.sh` — seed deterministic before/after for demos

References (`references/`):
- `capabilities.md` — full list of 42 techniques, grouped by category
- `savings-layers.md` — dedup, compression, routing, caching, arbitrage mechanics
- `verification.md` — how to read the proof artifact and brief a CIO
- `elastic-notes.md` — Elastic Agent Builder integration + 2026-04-22 CIO meeting commitments
- `adnan-pilot.md` — pilot gates, guardrails, and day-30 decision criteria

Assets (`assets/`):
- `install-message.md` — copy-paste bootstrap message an employee drops into Claude Code or Codex to trigger the full workflow

Agent metadata (`agents/`):
- `openai.yaml` — catalog-facing display name, short description, and default prompt metadata

## Gotchas

1. The CLI version matters — run `npx @sapperjohn/kostai --version` first. Commands differ between versions.
2. `scripts/optimize.sh` outputs to stdout, not a file — pipe or redirect if you want to save the output.
3. `scripts/proof.sh` requires prior data in `.ai-cost-data/` — run `scripts/demo.sh` first if the repo is fresh.
4. The `--audience` flag on `proof.sh` and `feedback.sh` creates a `deliverables/` directory in the current working directory — run from the repo root.
5. Do not trigger on cloud infrastructure cost questions (AWS bill, Kubernetes spend) — this skill only addresses LLM call cost in AI coding tools.

## Quick reference

```bash
# Full workflow (from the target repo's root)
npx @sapperjohn/kostai init        # one-click bootstrap
npx kostai scan                    # detect local runtimes + call sites (also generates optimization plan)
npx kostai proof --html docs/PROOF.html    # emit one-pager after real data lands
npx kostai proof --json docs/proof.json    # machine-readable proof payload
npx kostai dashboard               # open the local dashboard

# Skill lifecycle helpers
scripts/feedback.sh --audience elastic-pilot     # local, opt-in share packet
scripts/update.sh                                # refresh installed skill files

# Introspection
npx kostai doctor                  # diagnose config and prerequisites
npx kostai --help                  # full CLI surface
```

## Pass-through pricing note

If the user asks "what does this cost me?" — the CLI is free and local. If the user asks "what would a managed version cost?" — default pricing is 10% of measured savings, configurable via `--rate` on the `proof` command. The proof artifact renders the pass-through math so an employee can justify an enterprise rollout to their CIO without hand-waving.
