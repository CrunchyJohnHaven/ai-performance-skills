# Capabilities

KostAI currently implements 42 cost-reduction techniques across nine categories. The canonical inventory lives in `src/capabilities/registry.ts` and is rendered by the CLI.

## How to read the current list

Never paraphrase this list from memory — it drifts. The authoritative capability inventory is in `src/capabilities/registry.ts`. To inspect it:

```bash
npx kostai scan                   # detect active capabilities and local runtimes
npx kostai doctor                 # check which capabilities are enabled in this project
npx kostai --help                 # full CLI surface
```

The scan output groups every detected opportunity by category and tells the user how to invoke it (flag, config key, wrapper call, or automatic).

## Categories

Each category solves a different class of waste:

| Category | What it does | Typical savings lever |
| --- | --- | --- |
| `model-routing` | Classifies each call and routes to the cheapest sufficient tier | Kills silent frontier-model calls for trivial tasks |
| `context-compression` | Shrinks input tokens before they hit the frontier | Prose compressor, tool-result compression, local preprocess, DVP |
| `waste-detection` | Scores every call against patterns that indicate waste | Surfaces oversized system prompts, redundant history, over-generation |
| `caching` | Reuses prior computation when semantics match | Anthropic prompt cache (~90% discount on cached input), semantic cache |
| `shadow-mode` | Runs baseline + optimized in parallel, logs the delta | Generates the comparison ledger that powers `kostai report` |
| `local-inference` | Routes eligible calls to Ollama / LM Studio / local endpoints | Local is $0/token — only electricity cost |
| `batching-deliberation` | LLM Council and review-ready passes with consensus short-circuit | Preserves quality while collapsing spend across multiple reviewers |
| `budget-governance` | Per-wave and per-task hard dollar caps | Prevents runaway cost on orchestrated agent runs |
| `observability` | Dashboard + proof-of-savings artifacts + Kibana bundle | Turns the ledger into something a CIO or manager can read |

## When each category applies

- Long system prompt / memory file → **context-compression** (prose compressor, local preprocess)
- Repeated system block across calls → **caching** (Anthropic prompt cache via `cachedSystem`)
- Simple task hitting an expensive model → **model-routing** (rule-based or classifier v2 router)
- Shell output / file dump in the prompt → **context-compression** (tool-result compression)
- Agent loop with long output → **context-compression** (Draft-Verify-Patch)
- Drafting and reviewing → **batching-deliberation** (LLM Council, review-ready)
- Running CI or overnight orchestration → **budget-governance** (budget gate)
- Proving savings to a non-technical stakeholder → **observability** (`kostai report`)

## Status tags

Every capability carries a status tag:

- `ga` — production-ready, default-on when the install step enables it
- `beta` — functional but evolving; opt in with a config flag
- `experimental` — behind a feature flag; do not recommend to external users without verification

Do not surface `experimental` capabilities in a CIO-facing artifact or customer proof. Filter by running:

```bash
npx kostai report --json | jq '.capabilities[] | select(.status == "ga")'
```

## Adding a new capability

See the header comment in `src/capabilities/registry.ts` for invariants. In short: kebab-case stable ID, source file path, one-line description, category, invoke mode, status. If a new waste-category constant is added under `src/core/score/*.ts`, add the matching capability row at the same time so the feature list never drifts from the detectors.

## Available CLI Commands (v0.5.1)

Verified from `npx @sapperjohn/kostai --help` on 2026-04-22. Use this list as the authoritative CLI surface — do not invent commands not shown here.

| Command | Description |
| --- | --- |
| `init` | Initialize ai-cost configuration in the current project |
| `connect` | Auto-stamp `ai-cost.config.json`, generate bridge token, detect Tailscale peers |
| `dashboard` | Start the local ai-cost dashboard |
| `report` | Print a markdown summary report (replaces any prior `proof` command) |
| `export` | Export event data |
| `doctor` | Check ai-cost configuration and prerequisites |
| `reset` | Clear all stored event data |
| `ingest` | Pull token usage from Claude Code, Codex, and Ollama into the event store |
| `agent` | Stream token usage from this host to a central kostai bridge |
| `scan` | Detect local LLM runtimes and LLM usage in the current repo |
| `mcp` | Start the ai-cost MCP server (JSON-RPC over stdio) |
| `proxy` | Start an OpenAI-compatible HTTP proxy that observes, routes, or shadows |
| `bridge` | Run / inspect the cross-machine MCP bridge (HTTP + SSE with bearer auth) |
| `queue` | Inspect or drive the 24-hour task queue (escalate / delegate / handoff) |
| `compare` | Summarize shadow-mode comparisons (baseline vs. optimized) |
| `evidence` | Reproducible evidence harness: benchmarks, receipts, reports, verification |
| `compress` | Compress a markdown / text file in place (backs up original as `FILE.original.md`) |
| `help` | Display help for a command |

**Commands that do NOT exist in v0.5.1** (do not reference these):
- `proof` — replaced by `report`
- `optimize` — use `scan` to detect optimization candidates
- `install` — use `init` to initialize a project
- `open` — use `dashboard` to launch the local UI
- `capabilities` — documented in source (`src/capabilities/registry.ts`); not a CLI command in v0.5.1
