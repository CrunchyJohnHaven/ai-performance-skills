---
name: brainofbrains
description: This skill should be used when the user asks for "Brain Orchestration", "brain orchestration", "install brains", "brainofbrains", "BrainOfBrains", "call the expert", "ask an expert brain", "specialist brains", "route this to the right brain", "agent-to-agent install", "bootstrap brains into this workspace", "set up specialist brains", or mentions needing a synthesized answer from multiple expert views. Wraps the BrainOfBrains substrate (remote MCP at brainofbrains.ai/mcp, local `bin/brain` CLI, and the `brains.json` registry) to bootstrap specialist brains into the workspace, route expert questions to the right brain, run BIV tick loops, and return synthesized answers. No data egress without explicit opt-in. No MCP server installed by default.
version: 0.1.0
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
2. **Remote** — the BrainOfBrains MCP at `brainofbrains.ai/mcp` with three agent-callable tools: `quote(stack_description)`, `provision(payment_token, stack_spec)`, `health_check(install_id)`. Remote is opt-in and only touched for the A2A install flow.

Distribution detail: the user-facing label is `Brain Orchestration`. The repo path is `skills/brainofbrains/`. The skill is one of three shipped in the public repo at https://github.com/CrunchyJohnHaven/cost-optimization-skill.

Substrate mechanics are in `references/capabilities.md`. A2A install and payment flow mechanics are in `references/architecture.md`. Verification discipline is in `references/verification.md`. Elastic-specific deployment notes are in `references/elastic-notes.md`.

## Workflow

Execute steps in order. Each step is a single call wrapped by a script in `scripts/`. Read the script before invoking if the user has non-default config.

### 1. Install

Run `scripts/install.sh` to bootstrap the brain substrate into the current workspace. The script prefers `curl -fsSL https://brainofbrains.ai/install | bash` and falls back to `npx --yes @sapperjohn/brainofbrains install` if the remote installer is unreachable. The installer writes `bin/brain`, `evidence/brain/` (with seeded `STATE.json`, `brains.json`, and initial `closet-*.aaak` files), and a `scripts/brain/` dispatcher set. Idempotent — re-running refreshes files in place and never deletes user data.

The install step never exfiltrates code or prompts. Closets stay local. No MCP server is installed. The only outbound request is the install script download itself.

### 2. Scan

Run `scripts/scan.sh` to list the brains that now live in the workspace. Output reads from `evidence/brain/brains.json` and shows each brain's name, role (`substrate` / `specialist` / `product`), formula, threshold, last value, and status (`in-band`, `breach`, `awaiting-data`, `unwired`). Use this to confirm the install populated the registry and to pick which brain to query next.

### 3. Ask

Run `scripts/ask.sh "<question>"` to route an expert question through the substrate. The script delegates to `bin/brain query --query "<question>"`, which builds a layered (L0/L1/L2) context from the relevant closets and returns a synthesized answer along with the citations. The calling agent reads the answer, not the closet paths.

The router picks which specialist brain(s) answer based on the question's routing keys (stakeholder names, product names, meeting IDs). If the question does not match a specialist, the substrate brain answers with a cross-closet synthesis.

### 4. Tick (optional, background)

Run `bin/brain tick` directly (or wire it to a launchd plist — the installer offers to set this up) to run one always-on iteration. Each tick refreshes closets, recomputes BIV, checks thresholds, and writes a new `STATE.json` snapshot. The landing-page promise of "a plain-English email each week" is powered by the aggregate of these ticks; the tick loop is the engine behind every subsequent query.

This step is optional for one-shot use. A workspace that is only asked questions occasionally can skip always-on ticks and run `bin/brain tick` on demand before a query.

### 5. Verify

Run `scripts/health.sh` to prove the brains are alive. The script first tries the remote `health_check(install_id)` MCP tool if an install ID is recorded under `evidence/brain/install.json`; otherwise it reads the local `STATE.json` and `brains.json` and prints PASS/FAIL per brain along with the last-tick timestamp. Any brain in `breach` or `unwired` prints the remediation hint from the registry.

See `references/verification.md` for how to label numeric claims (Measured / Modeled / Needs verification) when reporting status to a stakeholder.

### 6. Provision (optional, A2A)

Run `scripts/provision.sh` to kick off the agent-to-agent provisioning flow for a managed install. The script calls the remote MCP `quote(stack_description)` tool, prints the returned price and spec, waits for confirmation, then calls `provision(payment_token, stack_spec)` and emits a signed install tarball plus install.sh. Payment is x402 (agent-native HTTP 402) by default with a Stripe Checkout fallback.

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
- specialist brains per product (one per product line the stack_description names)
- a `LocalLeverage` brain (local-vs-frontier share, quality retention, dollars avoided)
- a `HumanSignal` brain ((signals × quality) / engagement_min)

New brains are added by extending the stack_description and re-running install. The compiler generates the matching STATE file, tick script, and closet entry. Do not hand-edit the substrate — use the compiler.

## Which questions this covers

Any question that benefits from layered context synthesized across closets. Specifically effective on:
- stakeholder-specific questions ("what does Jesse care about this quarter")
- product-specific questions ("what is the BoilTheOcean roadmap status")
- meeting-follow-up questions ("what did we commit to in the review last week")
- cross-cutting questions that touch multiple closets ("how does the KostAI rollout interact with Elastic's Agent Builder catalog")

Questions that do not benefit: generic world knowledge, novel reasoning unrelated to the stack, anything a plain frontier call already answers well. The substrate does not claim to replace the frontier — it shapes the frontier's input.

## Safety and data posture

- No data leaves the machine unless the user explicitly enables a remote endpoint. Closets, STATE files, and query results all stay local.
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
- `health.sh` — PASS/FAIL per brain (remote MCP or local STATE fallback)
- `update.sh` — refresh the shipped skill from the latest npm package

References (`references/`):
- `capabilities.md` — L0/L1/L2 layers, BIV tick loops, closet (AAAK) format, specialist-brain templates
- `architecture.md` — A2A distribution, x402 payment, signed-tarball delivery, local-only operation posture
- `verification.md` — how to prove the brains are working; Measured / Modeled / Needs verification labeling
- `elastic-notes.md` — Elastic Agent Builder catalog metadata, no-MCP-default posture, employee-benefit framing

Assets (`assets/`):
- `install-message.md` — copy-paste bootstrap message an employee drops into Claude Code or Codex to trigger the full workflow

Agent metadata (`agents/`):
- `openai.yaml` — catalog-facing display name, short description, and default prompt metadata

## Quick reference

```bash
# Full workflow (from the target repo's root)
scripts/install.sh                  # bootstrap brain substrate into this workspace
scripts/scan.sh                     # list installed brains + status
scripts/ask.sh "<question>"         # route an expert question and return a synthesized answer
bin/brain tick                      # one iteration (refresh closets, recompute BIV)
scripts/health.sh                   # PASS/FAIL per brain

# Agent-to-agent managed install (opt-in)
scripts/provision.sh "<stack description>"   # quote → confirm → provision via MCP

# Introspection
bin/brain status                    # last tick + registry rollup
bin/brain registry --json           # machine-readable brain list
bin/brain --help                    # full CLI surface

# Skill lifecycle
scripts/update.sh                   # refresh installed skill files
```

## Pricing note

If the user asks "what does this cost me?" — the free install path is free. The brains run entirely on the local machine; the only thing the user pays for is whatever frontier model they choose to route through (and the cost-optimization skill handles minimizing that).

If the user asks "what does the managed install cost?" — v0 pricing on the public page is Individual/Startup $100 one-time setup; Enterprise custom. Exact pricing for an A2A install is returned by the `quote` MCP tool at provision time; do not quote a number from memory. Ship the artifact the tool returns.
