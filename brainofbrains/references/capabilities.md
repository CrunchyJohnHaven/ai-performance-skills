# Capabilities

The BrainOfBrains substrate is a layered, tick-driven, closet-backed specialist-brain system. This file describes what the substrate contains after a standard install and how queries route through it.

## How to read the current state

Never paraphrase this list from memory — the registry drifts as specialist brains are added or retired. Always run:

```bash
bin/brain registry            # human-readable rollup
bin/brain registry --json     # machine-readable; pipe to jq
bin/brain status              # headline metrics + last tick
```

The output groups every brain by role (`substrate`, `specialist`, `product`), reports its formula and threshold, surfaces its current value and status, and links to the STATE file that powers it.

## Layered context (L0 / L1 / L2)

Every query resolves against three layers. The layers are the reason a synthesized answer beats a plain closet dump:

| Layer | What it holds | Typical size | When it fires |
| --- | --- | --- | --- |
| **L0** | headline state — BIV score, BSV, last-tick timestamp, breach flags | ~200 tokens | always, first |
| **L1** | specialist-brain summaries — one compressed paragraph per relevant brain, routed by keywords in the question | ~1–2k tokens | when the question mentions a known stakeholder, product, or meeting |
| **L2** | full closet excerpts — AAAK-compressed evidence, citations, and raw quotes | 4–16k tokens | only when the L1 answer is insufficient and the caller asks for depth |

`bin/brain query` composes these in order. The calling agent sees a single answer blob with inline citations back to closet paths. L2 is not loaded unless the question or config explicitly requests it, keeping typical queries cheap.

## BIV tick loop

BIV — Brain Information Velocity — is the substrate's master composite metric. It is the weighted geometric mean of five factors:

- `liveTokenLeverage` — how much useful context is produced per token spent
- `retrievalQuality` — R@K score on the regression fixture
- `layeredCompression` — how aggressively closets compress raw evidence without losing signal
- `freshness` — age of the newest signal in the closet
- `selfCorrection` — rate at which the substrate catches and fixes its own errors across ticks

Each tick:

1. Ingests any new signals (meeting transcripts, commits, messages, artifacts)
2. Rebuilds affected closets
3. Runs the regression fixture to recompute `retrievalQuality`
4. Recomputes all specialist-brain formulas
5. Writes a new `STATE.json` snapshot
6. Flags threshold breaches as `breach` status in `brains.json`

Tick cadence defaults to on-demand. A workspace that wants continuous updates installs a launchd plist (the installer offers this) to run `bin/brain tick` on a schedule. The tick loop is intentionally idempotent — a missed tick is absorbed by the next run.

## Closet knowledge bases (AAAK format)

Closets are the substrate's long-term memory. Each closet is a single `.aaak` file (Aggregated, Analyzed, Attributed, Knowledge) containing:

- compressed raw evidence (quotes, commits, artifacts) with provenance
- derived claims and counter-claims linked to their evidence
- routing keys (stakeholder names, product names, meeting IDs)
- a lineage header that tells the next tick which signals are new versus carried-over

Standard closets after install:

- `closet-memory.aaak` — persistent personal / operational memory
- `closet-humans.aaak` — human-brain-per-stakeholder rollups
- `closet-meetings.aaak` — meeting transcripts and decisions
- `closet-kb.aaak` — knowledge-base research outputs
- `closet-locallm.aaak` — local-inference telemetry and quality probes

Additional closets appear when specialist brains are added (one closet per significant routing key — e.g., a new customer, a new product line, a new research thread).

Closet rebuilds are driven by `bin/brain closet` and run automatically inside every tick. Hand-editing a closet is never correct — the next tick overwrites hand edits. Signal belongs in the source artifacts (commits, meetings, messages); the closet builder lifts it.

## Specialist-brain templates

Specialist brains are template-instantiated. Each has a fixed shape:

- `name` — stable ID, kebab or PascalCase
- `role` — `substrate`, `specialist`, or `product`
- `formula` — the math that produces the brain's value from telemetry
- `thresholdLabel` — human-readable health gate
- `statePath` — where the brain's STATE file lives
- `watcherResult` — optional cross-reference to an external watcher

Stock templates:

- **substrate** — BIV (master composite)
- **per-stakeholder** — human-brain template keyed by stakeholder name; rollups live in `closet-humans.aaak`
- **per-product** — product-brain template keyed by product name; rollups live in `closet-<product>.aaak`
- **LocalLeverage** — `local_share × quality_retention × frontier_$_avoided`; powered by the same telemetry the cost-optimization skill emits
- **HumanSignal** — `(signals × quality) / engagement_min`; rewards dense human feedback over long, low-value threads
- **RevenueVelocity** — `MRR × install_success / John-minutes-per-install`; tracks the A2A economics

A new specialist brain is added by extending the stack_description passed to `provision(stack_spec)` or to the local installer. The compiler generates the STATE file, the tick-script entry, and the closet slot. Do not hand-write these.

## The `brains.json` registry

`evidence/brain/brains.json` is the source of truth for "which brains live here". After install it looks like:

```json
{
  "schema": 1,
  "generatedAt": "2026-04-22T19:18:23.148Z",
  "summary": { "total": 9, "inBand": 1, "breach": 5, "awaitingData": 2, "unwired": 1 },
  "brains": [
    {
      "name": "BIV",
      "role": "substrate",
      "formula": "weighted_geometric_mean(...) × 100",
      "thresholdLabel": "BIV ≥ 60",
      "value": 81.4,
      "status": "in-band",
      "statePath": "evidence/brain/STATE.json",
      "watcherResult": null
    }
  ]
}
```

The registry is rebuilt every tick. `scripts/scan.sh` reads it directly. Do not hand-edit — the next tick overwrites.

## Query routing

`bin/brain query --query "<question>"` executes in four phases:

1. **Parse** — extract routing keys (stakeholder names, product names, meeting IDs, explicit `@brain` tags)
2. **Route** — match routing keys against `brains.json`; select the matching specialists, fall back to substrate if none match
3. **Compose** — assemble L0 headline + selected L1 summaries; load L2 only if requested
4. **Synthesize** — return a single answer with inline citations to the contributing closets

The router is deterministic. The same question at the same tick produces the same answer. That determinism is what lets `scripts/ask.sh` be used inside agent loops without variance surprises.

## What the substrate does not do

- It does not replace the frontier. The synthesized answer shapes frontier input; the frontier still runs when the question warrants.
- It does not ingest data it has not been given. The closet builder reads commits, meeting transcripts, KB artifacts, and explicit messages — not the user's screen, not the user's browser history, not the user's keystrokes.
- It does not mutate its own substrate during a query. Queries are read-only against the last STATE snapshot. Only ticks mutate state.
