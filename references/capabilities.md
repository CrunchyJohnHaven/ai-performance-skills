# Capabilities

KostAI currently implements 42 cost-reduction techniques across nine categories. The canonical inventory lives in `src/capabilities/registry.ts` and is rendered by the CLI.

## How to read the current list

Never paraphrase this list from memory — it drifts. Always run:

```bash
npx kostai capabilities           # human-readable grouped output
npx kostai capabilities --json    # machine-readable; pipe to jq
```

The output groups every capability by category, names its source file, and tells the user how to invoke it (flag, config key, wrapper call, or automatic).

## Categories

Each category solves a different class of waste:

| Category | What it does | Typical savings lever |
| --- | --- | --- |
| `model-routing` | Classifies each call and routes to the cheapest sufficient tier | Kills silent frontier-model calls for trivial tasks |
| `context-compression` | Shrinks input tokens before they hit the frontier | Prose compressor, tool-result compression, local preprocess, DVP |
| `waste-detection` | Scores every call against patterns that indicate waste | Surfaces oversized system prompts, redundant history, over-generation |
| `caching` | Reuses prior computation when semantics match | Anthropic prompt cache (~90% discount on cached input), semantic cache |
| `shadow-mode` | Runs baseline + optimized in parallel, logs the delta | Generates the comparison ledger that powers `kostai proof` |
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
- Proving savings to a non-technical stakeholder → **observability** (`kostai proof`)

## Status tags

Every capability carries a status tag:

- `ga` — production-ready, default-on when the install step enables it
- `beta` — functional but evolving; opt in with a config flag
- `experimental` — behind a feature flag; do not recommend to external users without verification

Do not surface `experimental` capabilities in a CIO-facing artifact or customer proof. Filter by running:

```bash
npx kostai capabilities --json | jq '.[] | select(.status == "ga")'
```

## Adding a new capability

See the header comment in `src/capabilities/registry.ts` for invariants. In short: kebab-case stable ID, source file path, one-line description, category, invoke mode, status. If a new waste-category constant is added under `src/core/score/*.ts`, add the matching capability row at the same time so the feature list never drifts from the detectors.
