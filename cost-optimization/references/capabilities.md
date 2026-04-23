# Capabilities

KostAI exposes multiple cost-reduction techniques across routing, compression, caching, shadow-mode comparison, local inference, budget governance, and observability. The installed CLI plus the wrapper scripts in this skill are the public source of truth.

## How to read the current list

Never paraphrase this list from memory — it drifts. Inspect the public surfaces on the target machine:

```bash
scripts/scan.sh                             # detect local runtimes and candidate savings levers
npx --yes @sapperjohn/kostai doctor         # diagnose config and prerequisites
npx --yes @sapperjohn/kostai --help         # full CLI surface for the installed version
```

The scan output groups detected opportunities by category and tells the user how to invoke them (wrapper script, CLI flag, config key, or automatic behavior). If you are maintaining the upstream product repo rather than using an installed skill, inspect the source-tree registry there too.

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
Check the installed CLI or scan output on the target machine before making a stakeholder-facing claim about availability.

## Maintainer note

If you are editing the upstream product repo, keep the capability registry aligned with the detectors that feed it. Installed-skill users can ignore the source-tree internals.

## Wrapper-backed command surface

This skill bundle relies on a small stable wrapper surface:

- `scripts/install.sh` — wraps `kostai init`
- `scripts/scan.sh` — wraps `kostai scan`
- `scripts/proof.sh` — wraps `kostai report`
- `scripts/feedback.sh` — builds share-ready output from the local proof data
- `scripts/update.sh` — refreshes the installed skill bundle from the published package

Before documenting any additional subcommand or flag, verify it against `npx --yes @sapperjohn/kostai --help` on the target machine instead of copying an old command table.
