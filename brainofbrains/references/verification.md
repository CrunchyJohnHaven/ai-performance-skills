# Verification

How to prove the brains installed in this workspace are actually working, and how to report brain health to a stakeholder without overclaiming.

## How to prove the substrate is working

Three tiers of verification, in increasing depth. Run them in order; stop when the tier answers your question.

**Tier (a) — Local STATE.json check via `scripts/health.sh`**

```bash
scripts/health.sh
```

This is the fastest check. The script reads `evidence/brain/STATE.json` and `evidence/brain/brains.json` locally — no network call, no external dependency. It emits per-brain PASS/FAIL and the BIV headline. If a brain shows `breach` or `unwired`, the substrate is alive but that brain needs attention. If the script cannot find `STATE.json`, the install did not complete; run `scripts/install.sh` and then `bin/brain tick` to seed the state.

**Tier (b) — Live query test via `scripts/ask.sh`**

```bash
scripts/ask.sh "what is the BIV score"
```

This exercises the full local query path: routing, closet retrieval, L0/L1/L2 context assembly, and synthesis. A successful response returns a synthesized answer that cites at least one closet path. If the response is empty or contains no citations, closets are stale — run `bin/brain tick` and retry. If the response cites closets but the BIV number differs from `STATE.json`, the tick loop has run since the last `ask` call; that is expected and healthy.

**Tier (c) — Tick freshness check**

```bash
bin/brain status
```

Read the `last-tick timestamp` in the output. It should be within 24 hours of the current time. A timestamp older than 24 hours means the tick loop has stalled: restart with `bin/brain tick` (manual) or check the launchd plist if one was installed (`launchctl list | grep brain`). Do not present synthesized answers as current if the last tick is more than 24 hours old — say the substrate is stale and offer to re-tick before the briefing.

## Produce a health snapshot

After an install has run and at least one tick has landed, run:

```bash
# From the workspace root
scripts/health.sh                           # local PASS/FAIL per brain
scripts/health.sh --remote                  # include remote health_check MCP call
bin/brain status                            # headline metrics + last tick + registry rollup
bin/brain registry --json > evidence/brain/registry-snapshot.json
```

Flags:
- `--remote` — calls the `health_check(install_id)` MCP tool in addition to reading local STATE; use only when proving reliability to a buyer
- `--json` — emit machine-readable output for piping into other tools

Store any exec-facing snapshot under `deliverables/<audience>-<topic>-<date>/` — that is the repo convention and it keeps `~/Downloads/` clear.

## What a healthy snapshot contains

Every health snapshot should render the same five blocks in order:

1. **Headline** — BIV score out of 100, delta vs previous tick, last-tick timestamp
2. **Registry rollup** — total brains, in-band / breach / awaiting-data / unwired counts
3. **Per-brain status** — each brain's name, role, value, threshold, status
4. **Tick telemetry** — signal density, closet rebuild flag, regression fixture R@K
5. **Interpretation** — short natural-language notes the tick loop appended

A brain in `breach` or `unwired` status is not a failure mode — it is a signal that the brain's underlying threshold or data source needs attention. The snapshot reports it faithfully; the operator decides whether to act.

## Required labels

Every numeric claim in any output sent to a stakeholder must carry one of three labels:

- **Measured** — value came from the local STATE file or the remote `health_check` response, verifiable by re-running the same command
- **Modeled** — value extrapolated from a sample (for example, projected weekly BIV trajectory from a 24-hour window)
- **Needs verification** — value depends on a number the user supplied but the substrate has not validated (for example, "assume 40 customers installed" when the registry has not been polled)

This labeling is not optional. Unlabeled numbers in a stakeholder-facing artifact are a fireable-level discipline break. See `feedback_exec_pitch_discipline.md` in project memory and the `cost-optimization` skill's `verification.md` for the canonical wording.

Brain-metric examples:

| Claim | Label | Reason |
|---|---|---|
| BIV score of 81 (from STATE.json) | **Measured** | Read directly from the local STATE file produced by the last tick; re-runnable via `scripts/health.sh` |
| R@5 retrieval quality of 0.91 | **Measured** | Output of `bin/brain eval` against the frozen regression fixture |
| Estimated $230/day savings from local routing | **Modeled** | Extrapolated from a 24-hour token-cost sample; assumes steady-state usage volume |
| "Nine brains installed across Elastic's SE team" | **Needs verification** | Registry has not been polled across installs; headcount is an estimate supplied by the user |
| Projected weekly BIV trajectory | **Modeled** | Trend line from the last 7 daily STATE snapshots; actual trajectory depends on tick cadence and new signal volume |

## What to say when briefing a stakeholder

Lead with the business state, not the file path:

- "The substrate emitted a fresh tick fourteen minutes ago. BIV is 81 out of 100."
- "Seven of nine specialist brains are in-band. Two are awaiting data because the stakeholder closets are less than a day old."
- "The regression fixture shows R@5 above 0.9 — synthesized answers are pulling the right closet on the first try."

Do not open with implementation detail. The stakeholder wants to know whether the substrate is alive, whether answers are trustworthy, and what action is indicated — in that order.

## Handling "how do I know the answers are real?"

Point at three evidence surfaces:

1. **The closets** — `evidence/brain/closet-*.aaak` are the evidence substrate. Every synthesized answer cites its contributing closets by path; the operator can open the citation and read the raw evidence.
2. **The STATE file** — `evidence/brain/STATE.json` is rebuilt every tick. It holds the last-run BIV score, the last regression-fixture result, and the per-brain values used at synthesis time.
3. **The regression fixture** — `bin/brain eval` runs a fixed set of questions against known-good answers and reports R@K. Quality regressions show up here before they show up in synthesized answers.

If closets are empty (new install, no ticks), say so and run `bin/brain tick` to populate. Never invent a synthesized answer when the substrate is empty — the answer will be shaped by nothing, and the user's trust evaporates.

## Handling "what about quality?"

The regression fixture (`bin/brain eval`) grades the substrate's retrieval and synthesis against a frozen benchmark. Health snapshots surface the latest R@K. If quality degrades, the snapshot will say so — do not suppress it. The correct response is to investigate (stale closets, broken routing, corrupted STATE) rather than hide the signal.

BIV captures quality as one of its five factors via `retrievalQuality`. A BIV drop driven by `retrievalQuality` is the loudest quality signal the substrate emits. Treat a `retrievalQuality` drop as the highest-priority investigation.

## Handling "what about privacy / surveillance?"

Point at what the substrate does and does not do:

- **Local operation** — every tick, query, and closet rebuild runs on the local machine. Nothing leaves the machine unless the user explicitly calls the remote `health_check` MCP.
- **No background telemetry** — the default install does not emit any telemetry to any central service. There is no "phone home" in the tick loop.
- **No local MCP server** — the default install does not stand up a local MCP server. The remote MCP at `brainofbrains.ai/mcp` is only touched for the buy-flow.
- **No data ingestion without opt-in** — the closet builder reads commits, meeting transcripts, KB artifacts, and explicit messages. It does not read the user's screen, browser history, or keystrokes.
- **Redaction** — the closet builder redacts known secret patterns before write; the redactor is a TABOO path and gates every closet rebuild.

## Handling "is the tick loop alive?"

Three checks, in order:

1. `bin/brain status` — if the last-tick timestamp is stale by more than the expected cadence, the loop has stalled
2. `scripts/health.sh` — per-brain PASS/FAIL surfaces which specific brain's health check is failing
3. `tail -n 100 evidence/brain/ticks.log` (if present) — the tick loop appends status to this log; a silent tick loop has a silent log

If the loop is dead, restart with `bin/brain tick` (manual) or restart the launchd plist if one was installed. Do not declare the substrate healthy if the loop has stalled — stale synthesized answers are worse than no answer.

## Refresh cadence for stakeholder-facing snapshots

Re-run `scripts/health.sh` immediately before any stakeholder-facing briefing. Do not reuse a stale snapshot — the substrate is a living system and the numbers will have moved. Date-stamp the artifact filename under `deliverables/<audience>-<topic>-<date>/` and cite the timestamp in the briefing so the stakeholder can see how fresh the data is.

## What to say to a CIO

Lead with posture and control, not mechanism. A CIO's first question is "what risk does this create for my org?" — answer that before they ask.

- **Local-only operation.** Every tick, query, and closet rebuild runs on the employee's machine. No data traverses the network unless the employee explicitly triggers the provisioning flow. There is no always-on outbound connection, no background sync, and no cloud dependency for normal use.
- **No surveillance posture.** The substrate reads artifacts the employee deliberately points it at — commits, meeting transcripts, KB files, explicit messages. It does not read screens, browser history, keystrokes, clipboard content, or any file outside the configured paths. Known secret patterns are redacted before any closet is written.
- **Employee controls the data.** The brains, closets, and STATE files live entirely on the employee's machine. The employer does not have visibility into individual employees' closets or synthesized answers. If an employee leaves or uninstalls, `rm -rf evidence/brain/` removes the substrate completely — no residue on any external service.
- **Adoption is voluntary.** The skill installs into Claude Code from the Agent Builder catalog — employees choose to install it, choose which artifacts to include, and choose whether to run the tick loop. There is no org-wide push, no silent enrollment, and no manager dashboard.
- **Aggregate-only sharing, if they choose.** If the org later wants to see aggregate health metrics (BIV distributions, routing quality trends across a team), that is a future opt-in flow. No individual's closet or query is ever part of an aggregate report without that employee's explicit consent. Default is: nothing shared, nothing visible to anyone but the employee.
