# Savings Layers

Six primary layers compose the bulk of observed savings on real Claude Code and Codex workloads. Each is independently enable-able, and each has a detector that surfaces candidate call sites.

## 1. Deduplication

Identical or near-identical requests (same system prompt, same tool definitions, same user message modulo whitespace) hit the frontier repeatedly across a session. The deduplicator canonicalizes the request, hashes it, and short-circuits the second call with the cached response.

- Implementation: semantic-cache inside `src/core/council.ts` and the proxy layer in `src/proxy/`
- Best on: repeated review passes, multi-agent loops with shared context, retry storms
- Typical savings: 30–60% on agent loops with repeated setup

## 2. Context Compression

Long system prompts, memory files, and tool output dominate input-token spend. Three compressors in ascending aggressiveness:

- **Prose compressor** (`src/core/prose-compress.ts`) — pure-TS deterministic rule-based; byte-exact on code/URLs/headings, idempotent. Drops ~46% input tokens on markdown memory files.
- **Tool-result compression** (`src/core/tool-compress.ts`) — summarizes large tool outputs with a local model before they hit the frontier. Cuts the dominant input-token source in agent loops.
- **Local preprocessor** (`src/core/preprocess.ts`) — runs a local model first to summarize history and draft an attempt. The frontier sees only the distilled prompt plus the draft.

Use prose compression on memory and system prompts. Use tool-result compression on shell/file/API dumps. Use local preprocess when a local model is already running (detected by `kostai scan`).

## 3. Model Right-Sizing

Most agent workflows default to the most expensive model because the SDK call names it explicitly. The router intercepts that and routes by complexity:

- **Rule-based router** (`src/core/router.ts`) — deterministic rules for trivial classification, simple edits, echoes, confirmations
- **Trained-classifier router v2** (`src/core/router/index.ts`) — ML short-circuit for high-confidence cheap-tier routes; +6.5pt accuracy vs v1 on the frozen bench
- **Expensive-model gate** (`src/core/router/expensive-models.ts`) — blocks calls silently reaching a costly model (configurable $/M-token threshold) unless elevation is justified
- **Elevation check** (`src/core/router/elevation.ts`) — when a higher tier IS required, emits an auditable justification rather than a silent upgrade

The gate is the single highest-impact default-on behavior for enterprise rollout. A forgotten `model:` string can burn $75/M output tokens without the gate.

## 4. Provider Arbitrage

Same capability, different prices across providers. The router can split eligible work:

- Anthropic prompt cache at ~90% discount for repeated system blocks
- OpenAI batch API for non-latency-critical work
- Google Gemini Flash / free Gemma variants for cheap-tier classification
- Ollama / LM Studio for $0/token local inference

Configure via `providers.*` in `ai-cost.config.json`. Arbitrage only fires when shadow-mode evaluation confirms quality is retained — there is no silent quality tradeoff.

## 5. Prompt Caching

Anthropic prompt caching (`src/providers/anthropic-cache.ts`) shapes system blocks with `cache_control` so repeat calls replay cached tokens at ~90% discount. The install step sets this as default for any Anthropic SDK the workspace uses.

Invoke via the wrapper:

```ts
import { cachedSystem } from "@sapperjohn/kostai/anthropic";

const system = cachedSystem(SYSTEM_PROMPT);
```

Cached tokens still count toward context window but cost ~10% of non-cached. Useful on any session with a stable system prompt, which is essentially every agent loop.

## 6. Batch, Defer, Negative Cache, Retrieval-First

Smaller but additive layers:

- **Batch** — OpenAI batch API for bulk async work (50% discount, 24h latency)
- **Defer** — queue non-urgent work for off-peak or batch runs
- **Negative cache** — remember "this prompt does not need a tool call / does not need an expensive model" so subsequent similar prompts skip the setup cost
- **Retrieval-first** — for any call whose answer is likely in the local KB, query the KB before going to the frontier

## Draft-Verify-Patch (output-side savings)

Input-side layers collapse the prompt. DVP (`src/core/draft-verify.ts`) collapses the output:

1. Local model drafts the answer
2. Frontier evaluates: APPROVE, PATCH, or REWRITE
3. On APPROVE, output tokens collapse to a token-level confirmation

Targets workloads where frontier pricing is 5× input — most code generation and long-form synthesis.

## Shadow-Mode Evaluation

Every optimization runs in shadow mode first:

- Baseline (unmodified) + Optimized (with savings layers) run in parallel
- Baseline is returned to the caller — no user-visible behavior change
- Delta is logged to `.ai-cost-data/comparisons.jsonl`
- Quality evaluator (`src/core/evaluator.ts`) grades optimized-vs-baseline so savings carry a quality signal

Shadow mode is the reason `kostai report` can claim measured savings without hand-waving — every number has a side-by-side comparison behind it.

## Waste detectors

Eleven detectors in `src/core/score/*.ts` identify specific waste categories on every captured call: oversized system prompts, redundant history, verbose output preambles, language-specific verbosity, repeated image attachments, model overkill, downshift opportunities, DVP candidates, unbounded streams, and metadata-only oversized calls. The `scan` command reads detector output to prioritize the plan.

## How savings are attributed

Each optimized call is tagged with the technique that saved the money. The ledger (`src/store/comparisons.ts`) powers the mechanism-breakdown table in `kostai report`, so a CIO artifact can say "$X saved via prose compression, $Y via router downgrade, $Z via prompt cache" rather than a single opaque total.
