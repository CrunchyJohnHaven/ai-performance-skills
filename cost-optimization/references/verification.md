# Verification

How to produce and defend a proof-of-savings artifact suitable for a manager, CIO, or external customer.

## Produce the proof

After real workload data has landed in `.ai-cost-data/events.jsonl` and shadow-mode comparisons have populated `.ai-cost-data/comparisons.jsonl`, run:

```bash
# From the target workspace root
npx kostai proof --html deliverables/<audience>-<YYYY-MM-DD>/PROOF.html
npx kostai proof --json deliverables/<audience>-<YYYY-MM-DD>/proof.json
npx kostai proof > deliverables/<audience>-<YYYY-MM-DD>/PROOF.md
```

Flags:
- `--rate <decimal>` — pass-through SaaS pricing rate (default `0.10` = 10% of savings)
- `--last <30d|90d|all>` — time window (default `all`)

Store outputs under `deliverables/<audience>-<topic>-<date>/` — that is the repo convention for exec artifacts and keeps `~/Downloads/` clear.

## What the proof contains

Every proof artifact renders the same five blocks in order:

1. **Executive summary** — one sentence, one savings-rate percentage, one dollar figure
2. **Measured savings** — baseline vs optimized token counts and dollars, across the time window
3. **Mechanism breakdown** — savings attributed per technique (router, compression, cache, DVP, local preprocess)
4. **Quality signal** — evaluator score, so the reader knows the optimization did not degrade output
5. **Pricing frame** — pass-through math at the configured rate (e.g., "saved $X, a managed service at 10% would be $Y")

## Required labels

Every numeric claim in any output sent to an exec must carry one of three labels:

- **Measured** — value came from the shadow-mode ledger, verifiable by re-running
- **Modeled** — value extrapolated from a sample (e.g., projected annual savings from a 30-day window)
- **Needs verification** — value depends on a number the user supplied but the system has not validated (e.g., "assume $40M annual Anthropic spend")

This labeling is not optional. Unlabeled numbers in a CIO artifact are a fireable-level discipline break. See `feedback_exec_pitch_discipline.md` in project memory.

## What to say when briefing a stakeholder

Lead with the business state, not the file path:

- "On a ten-question workload, we measured an 86% input-token reduction and a 92% cost reduction."
- "The pass-through math at 10% would price this at $Y per month for the same workload."
- "Every savings claim is backed by a side-by-side shadow-mode comparison in `.ai-cost-data/comparisons.jsonl`."

Do not open with implementation detail. The CIO wants to know whether the savings are real, whether quality degrades, and what it costs to scale — in that order.

## Handling "how do I know the savings are real?"

Point at three evidence surfaces:

1. **The ledger** — `.ai-cost-data/comparisons.jsonl` is append-only JSONL. Every row is a baseline/optimized pair with token counts, dollars, and quality score.
2. **The dashboard** — `npx kostai dashboard` shows the same data as a time-series. Non-technical reviewers can see the trend.
3. **The benchmarks** — `tests/integration/` has deterministic benchmarks that reproduce headline numbers on demand.

If the ledger is empty (new install), say so and run `scripts/demo.sh` to seed deterministic demo data. Never invent numbers — the system will not let you, and a fabricated claim invalidates the whole artifact.

## Handling "what about quality?"

The shadow-mode evaluator grades each optimized response against the baseline on heuristic and (optionally) LLM-judge axes. Proof artifacts surface the average quality delta. If quality degraded, the proof will say so — do not suppress it. The correct response is to retune router rules or compression aggressiveness, not to hide the signal.

## Handling "what about privacy / surveillance?"

The capture mode controls what gets stored:

- `metadata_only` — hashes and token counts only. No prompt or response body. Default.
- `redacted_body` — partial body with secrets redacted. Local debugging only.
- `full_body` — unredacted body. Off by default; manually opted in via config.

Nothing leaves the user's machine. No MCP server is installed by default. The proof artifact does not contain any prompt or response content — only aggregated counts and dollars.

## Refresh cadence

For ongoing pitches, re-run `kostai proof` after any run of meaningful workload volume (>=100 calls on recent work). Date-stamp the artifact filename. Do not reuse a stale proof — the ledger is cumulative and the numbers will have moved.
