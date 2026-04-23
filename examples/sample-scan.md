# Sample cost-optimization scan

This file shows the shape of `cost-optimization/scripts/scan.sh` output. It is illustrative only; detected runtimes, file paths, and recommended techniques vary by workspace.

## Local runtime detection

- Ollama: detected
- LM Studio: offline
- OpenAI-compatible endpoint: not detected

## Flagged call sites

| File | Surface | Signal | Recommended lever |
|---|---|---|---|
| `src/agents/review.ts` | Anthropic SDK wrapper | Repeated long system prompt | Prompt caching |
| `src/prompts/summarize.ts` | OpenAI Responses API | Large repeated context block | Prose compression |
| `scripts/nightly-docs.mjs` | Batch summarization | Same model used for draft and final pass | Cheaper first-draft route |

## Operator takeaway

- Start with prompt caching on the repeated review flow
- Compress the long memory/context blocks before frontier submission
- Move batch drafting to a cheaper or local model, then keep the final check on the frontier
