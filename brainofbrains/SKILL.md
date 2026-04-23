---
name: brainofbrains
description: Use when the user says "Brain Orchestration", "install brains", "brainofbrains", "call the expert", "ask an expert brain", "specialist brains", "route this to the right brain", "agent-to-agent install", "set up specialist brains", or mentions needing a synthesized answer from multiple expert views. Bootstraps specialist brains into the workspace, routes expert questions to the right brain, and returns synthesized answers. No data egress without explicit opt-in.
version: 0.1.0
allowed-tools: Bash
when_to_use: "Use when the user wants to query or install specialist context brains in the current workspace."
---

# Brain Orchestration

User-facing catalog label: `Brain Orchestration`.

Route expert questions to the right specialist brain and return synthesized answers. Lead with the employee benefit: ask one question, get an answer shaped by every specialist that already knows the relevant stakeholder, product, meeting, or codebase — without opening a second tab or reposting context.

## When to use

Trigger this skill when the user expresses any of:
- orchestration intent — "ask the expert brain", "route this to the right specialist", "which brain should answer this", "synthesize an answer across brains"
- install intent — "bootstrap brains into this workspace", "install brainofbrains", "set up specialist brains", "give this repo a brain substrate"
- provisioning intent — "quote me for an install", "provision brains for my stack", "agent-to-agent install", "buy the managed install"
- query intent — "what does the Jesse brain know about X", "pull the product brain's take on Y", "layered context for Z"
- verification intent — "are my brains working", "is the tick loop alive", "show me the BIV score"
- catalog intent — "brain orchestration skill", "add Brain Orchestration to my agent"

Do not trigger on unrelated orchestration questions (workflow engines, generic multi-agent frameworks) — this skill only addresses the BrainOfBrains specialist-brain substrate.

## What this skill does

The skill delegates to two surfaces and does not reimplement either:

1. **Local** — the `bin/brain` CLI (ships inside the target workspace after install). Handles queries, tick loops, closet rebuilds, BIV metric emission, and brain-to-brain claims. All state stays on the machine.
2. **Remote** — the optional hosted BrainOfBrains endpoints under `brainofbrains.ai`. The bundled wrapper targets a quote step that takes `stack_description`, a provision step that reuses that same `stack_description` plus an optional payment token header, and a `health_check(install_id)` path. Remote is opt-in and only touched for managed install or explicit remote health checks.

Distribution detail: the user-facing label is `Brain Orchestration`. In this source repo the folder is `brainofbrains/`; packaged builds commonly nest the same folder under `skills/brainofbrains/`. The skill is one of three shipped in the public repo at https://github.com/CrunchyJohnHaven/ai-performance-skills.

Substrate mechanics are in `references/capabilities.md`. A2A install and payment flow mechanics are in `references/architecture.md`. Verification discipline is in `references/verification.md`. Elastic-specific deployment notes are in `references/elastic-notes.md`.

## Workflow

Execute steps in order. Each step is a single call wrapped by a script in `scripts/`. Read the script before invoking if the user has non-default config.

### 1. Install

Run `scripts/install.sh` to bootstrap the brain substrate into the current workspace. The script prefers `curl -fsSL https://brainofbrains.ai/install | bash` and falls back to `npx --yes @sapperjohn/brainofbrains install` if the remote installer is unreachable. The installer writes `bin/brain`, `evidence/brain/brains.json`, and the initial closet set. The first `STATE.json` arrives after `bin/brain tick`. If `bin/brain` already exists, the wrapper exits as a safe no-op; use `scripts/update.sh` or an explicit remove-and-reinstall when you actually want a refresh.

The install wrapper may contact the hosted installer URL or the package registry, but it does not upload workspace data or stand up a local MCP server. Closets stay local.

### 2. Scan

Run `scripts/scan.sh` to list the brains that now live in the workspace. Output reads from `evidence/brain/brains.json` and shows each brain's name, role (`substrate` / `specialist` / `product`), formula, threshold, last value, and status (`in-band`, `breach`, `awaiting-data`, `unwired`). Use this to confirm the install populated the registry and to pick which brain to query next.

### 3. Ask

Run `scripts/ask.sh "<question>"` to route an expert question through the substrate. The script delegates to `bin/brain query --query "<question>"`, which builds a layered (L0/L1/L2) context from the relevant closets and returns a synthesized answer along with the citations. The calling agent reads the answer, not the closet paths.

The router picks which specialist brain(s) answer based on the question's routing keys (stakeholder names, product names, meeting IDs). If the question does not match a specialist, the substrate brain answers with a cross-closet synthesis.

### 4. Tick (optional, background)

Run `bin/brain tick` directly (or wire it to a launchd plist — the installer offers to set this up) to run one always-on iteration. Each tick refreshes closets, recomputes BIV, checks thresholds, and writes a new `STATE.json` snapshot. The tick loop is the freshness engine behind later scan, query, and health calls.

This step is optional for one-shot use. A workspace that is only asked questions occasionally can skip always-on ticks and run `bin/brain tick` on demand before a query.

### 5. Verify

Run `scripts/health.sh` to prove the brains are alive. By default it prints a local status snapshot (via `bin/brain status` when available) plus per-brain labels such as `in-band`, `breach`, `awaiting-data`, and `unwired`. Add `--remote` only if you explicitly want to call the hosted `health_check(install_id)` endpoint.

See `references/verification.md` for how to label numeric claims (Measured / Modeled / Needs verification) when reporting status to a stakeholder.

### 6. Provision (optional, A2A)

Run `scripts/provision.sh` to kick off the managed install flow when the hosted path is available. The script posts `stack_description` to the quote endpoint, prints the returned response, waits for confirmation, then posts the same `stack_description` to the provision endpoint with an optional payment token header. The hosted service determines the exact response format and follow-on install instructions. If the hosted path is unavailable, the script falls back to the manual page it prints.

This step is opt-in. The free install path (step 1) remains fully functional. Provision is only invoked when an agent-to-agent purchase flow is explicitly requested.

### 7. Update the skill (optional)

Run `scripts/update.sh` when the skill was installed from npm or copied into a local skills directory and a refresh is needed. The update path mirrors the cost-optimization pattern:
- refreshes the globally installed `@sapperjohn/brainofbrains` package
- preserves symlink installs automatically
- refreshes copied skill folders when they live outside a git worktree
- avoids mutating a checked-out repo skill folder unless the operator chooses to re-copy manually

## Which brains this covers

Every brain registered in `brains.json` after install. The stock template seeds:
- a substrate brain (BIV — Brain Information Velocity, the master composite)
- specialist brains per stakeholder (human-brain-per-stakeholder pattern)
- any additional specialist or product brains the installed substrate exposes
- a `LocalLeverage` brain (local-vs-frontier share, quality retention, dollars avoided)
- a `HumanSignal` brain ((signals × quality) / engagement_min)

The installed brain set is service-defined. Use `scripts/scan.sh` or `evidence/brain/brains.json` as the source of truth instead of assuming a fixed topology. New brains are added through the underlying installer or managed provision flow, not by hand-editing the substrate files. Do not hand-edit the substrate.

## Which questions this covers

Any question that benefits from layered context synthesized across closets. Specifically effective on:
- stakeholder-specific questions ("what does Jesse care about this quarter")
- product-specific questions ("what is the BoilTheOcean roadmap status")
- meeting-follow-up questions ("what did we commit to in the review last week")
- cross-cutting questions that touch multiple closets ("how does the KostAI rollout interact with Elastic's Agent Builder catalog")

Questions that do not benefit: generic world knowledge, novel reasoning unrelated to the stack, anything a plain frontier call already answers well. The substrate does not claim to replace the frontier — it shapes the frontier's input.

## Safety and data posture

- Normal query, tick, and local health flows stay on the machine. The install wrapper may contact the installer URL or package registry, and remote provision or remote health calls only happen when the user explicitly requests them.
- No secrets are persisted in closets. The closet builder redacts known secret patterns before write; the redactor is a TABOO path and gates every closet rebuild.
- No MCP server is installed by default. The remote MCP at `brainofbrains.ai/mcp` is agent-callable but nothing in the default install runs a local MCP process. Default-MCP reads as surveillance-adjacent in large orgs; default is off.
- No background telemetry is sent to a central service. Ticks are local. Health checks only call the remote MCP if the user explicitly runs `scripts/health.sh --remote`.
- No expensive frontier calls run without consent. The substrate's router prefers the lowest-tier sufficient model for every internal query; the frontier is only engaged when a question explicitly demands it.

## Escalation and fallback

If a step fails, the CLI emits structured errors. Report the error to the user verbatim, check `docs/BUG_LEDGER.md` for known issues, and fall back to:
- `bin/brain status` — last tick, BIV score, registry rollup
- `bin/brain registry --json` — machine-readable brain list
- `bin/brain --help` — full CLI surface

Never fabricate a synthesized answer. If closets are empty (new install, no ticks run yet), say so and run `bin/brain tick` to populate. If a brain's status is `awaiting-data` or `breach`, surface that in the answer — do not pretend the brain is healthy.

## Bundled resources

Scripts (`scripts/`):
- `install.sh` — bootstrap the brain substrate into the current workspace
- `scan.sh` — list discovered brains, specialist types, last-tick timestamps
- `ask.sh` — the primary "ask the expert" verb (wraps `bin/brain query`)
- `provision.sh` — agent-to-agent provisioning flow via the remote MCP
- `health.sh` — local status snapshot plus per-brain labels (with optional remote health check)
- `update.sh` — refresh the shipped skill from the latest npm package

References (`references/`):
- `capabilities.md` — L0/L1/L2 layers, BIV tick loops, closet (AAAK) format, specialist-brain templates
- `architecture.md` — managed-install posture, payment concepts, and current wrapper behavior
- `verification.md` — how to prove the brains are working; Measured / Modeled / Needs verification labeling
- `elastic-notes.md` — Elastic Agent Builder catalog metadata, no-MCP-default posture, employee-benefit framing

Assets (`assets/`):
- `install-message.md` — copy-paste bootstrap message an employee drops into Claude Code or Codex to trigger the full workflow

Agent metadata (`agents/`):
- `openai.yaml` — catalog-facing display name, short description, and default prompt metadata

## Gotchas

1. `bin/brain` does not exist until `scripts/install.sh` has run successfully — run the install step first, then use `scripts/health.sh` to verify the result.
2. Closets are rebuilt every tick — do not hand-edit `.aaak` files; the next tick overwrites manual changes.
3. BIV scores in `breach` status mean thresholds were not met, not that the system is broken — run `scripts/health.sh` for the full picture.
4. The remote MCP at `brainofbrains.ai/mcp` is only needed for opt-in provisioning or explicit remote health checks — normal queries are fully local.
5. Do not confuse with generic agent orchestration (LangChain, multi-agent frameworks) — this skill only addresses the BrainOfBrains specialist-brain substrate.

## Quick reference

All paths below are relative to the workspace root (the repo you cloned or the directory you ran `scripts/install.sh` from).

`bin/brain` is the local CLI installed by `scripts/install.sh`. It does not exist until that script has run successfully.

```bash
# Full workflow (from the target repo's root)
scripts/install.sh                  # bootstrap brain substrate — writes bin/brain + evidence/brain/
scripts/scan.sh                     # list installed brains + status (reads evidence/brain/brains.json)
scripts/ask.sh "<question>"         # route an expert question and return a synthesized answer
bin/brain tick                      # one iteration (refresh closets, recompute BIV) — requires bin/brain
scripts/health.sh                   # local status snapshot + per-brain labels (add --remote for hosted check)

# Agent-to-agent managed install (opt-in)
scripts/provision.sh "<stack description>"   # quote → confirm → provision via MCP

# Introspection (all require bin/brain — run scripts/install.sh first)
bin/brain status                    # last tick + registry rollup
bin/brain registry --json           # machine-readable brain list
bin/brain --help                    # full CLI surface

# Skill lifecycle
scripts/update.sh                   # refresh installed skill files from latest npm package
```

## Pricing note

If the user asks "what does this cost me?" — the free install path is free. The brains run entirely on the local machine; the only thing the user pays for is whatever frontier model they choose to route through (and the cost-optimization skill handles minimizing that).

If the user asks "what does the managed install cost?" — exact pricing for an A2A install is returned by the hosted `quote` MCP tool at provision time when available. Do not quote a number from memory. Ship the artifact the tool returns.
