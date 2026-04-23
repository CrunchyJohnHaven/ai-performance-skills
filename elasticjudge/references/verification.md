# Verification

How to produce and defend a judge verdict to a manager, CIO, or external reviewer. Same labeling discipline as the cost-optimization skill's `verification.md` — every numeric or axis claim carries a Measured / Modeled / Needs-verification label.

## Produce the verdict

After an artifact is ready for review, run:

```bash
# From the target workspace root
scripts/judge.sh --audience <audience> --date <YYYY-MM-DD> path/to/ARTIFACT.md
```

This emits:

- `deliverables/<audience>-<date>/JUDGE.md` — human-readable markdown summary
- `deliverables/<audience>-<date>/verdict.json` — structured payload with per-axis scores
- `deliverables/<audience>-<date>/critiques.json` — line-level critiques written later when `scripts/explain.sh deliverables/<audience>-<date>/verdict.json` is run

Store outputs under `deliverables/<audience>-<date>/` — that is the folder shape the bundled scripts write today.

## What the verdict contains

Every verdict file renders the same blocks in order:

1. **Verdict** — `pass` / `needs-revision` / `reject` with one-sentence reasoning
2. **Axis scores** — five lines, each axis 0-5 with the descriptor language from `evaluation-axes.md`
3. **Line-level critiques** — specific sentences or blocks flagged with a reason code
4. **Reproducibility stub** — the exact curl command and the SHA-256 of the submitted body so any reviewer can re-run the call

The reproducibility stub is what turns a judge run into a Measured-label claim, but only after the current endpoint and auth requirements are verified against the live API. If the stub is missing, the verdict is Modeled at best.

## Required labels

When quoting a judge verdict in an artifact going to an exec, every numeric or axis claim must carry one of three labels:

- **Measured** — value came from a verdict the reviewer can reproduce by re-running the same curl call against the same input
- **Modeled** — value extrapolated from a sample of verdicts (e.g., "our decks typically score 4/5 on brand voice across the last N runs")
- **Needs verification** — value depends on a claim the judge itself has not validated (e.g., "assume the judge's rubric maps 1:1 to the customer's reviewer criteria")

This is the same labeling discipline used throughout this repo. Unlabeled claims in a CIO-facing artifact are a discipline break.

## What to say when briefing a stakeholder

Lead with the business state, not the axis names:

- "I ran this memo through the judge; verdict is pass, with every axis scoring 4 or above."
- "The judge flagged two sentences on factual correctness; I revised both before this draft."
- "The judge's rubric maps to our exec-readiness discipline — labels on numbers, explicit recommendation, small ask."

Do not open with rubric detail. The reviewer wants to know whether the artifact is ready, what was changed as a result of the judge, and what still needs a human pass.

## Handling "how do I know the judge is reliable?"

Point at three evidence surfaces:

1. **Reproducibility target** — the same input should return the same verdict once the current endpoint and auth requirements are confirmed. If a reviewer doubts a verdict, re-run the curl call with the reproducibility stub and confirm the axis scores match. If they do not, surface that to the API operator at https://elasticjudge.com/; do not hide the drift.
2. **Per-axis breakdown** — a verdict is not a single opinion; it is five axis scores. A reviewer can ignore the summary verdict and reason about the axis they care about.
3. **Line-level critiques** — the `explain` surface returns specific sentences with reason codes. A reviewer can inspect whether the judge's line-level reasoning holds, independent of the axis score.

If the judge's verdict and a human reviewer's verdict disagree, that disagreement is the signal. Log it, root-cause the axis where they diverged, and adjust either the artifact or the downstream agent's use of the judge. Do not silently override the judge; do not silently override the human.

## Handling "what about Elastic-specific accuracy?"

The judge's Elastic-domain axis is grounded in public Elastic material (see `elastic-knowledge.md`). If the artifact contains Elastic-internal claims — roadmap, unreleased pricing, customer-specific ARR — the judge will score those as Needs-verification because it cannot confirm them against public material. This is working-as-intended, not a bug.

The correct response is to either:
- remove the Elastic-internal claim from the artifact (if the audience is external)
- add an explicit Measured or Needs-verification label (if the audience is internal and the claim is load-bearing)
- supply the source alongside the claim so the judge can cite it

## Handling "what about privacy?"

The judge API sees the text submitted to it. Before submitting, confirm the artifact does not contain:

- customer PII outside an approved data processor boundary
- unreleased pricing or commercial terms
- embargoed security research
- compensation or outside-offer language for any internal stakeholder

The skill does not auto-screen for these categories. The calling user owns the submission decision. When in doubt, excerpt the artifact — submit only the paragraphs that need grading.

Local footprint: the verdict JSON is written under `deliverables/<audience>-<date>/` and nowhere else. The skill does not append to a central log and does not send background telemetry.

## Refresh cadence

A judge verdict is a snapshot against the API's current rubric. When the API version changes, older verdicts should be treated as Modeled until re-run. Re-run before any high-stakes send rather than reusing a stale verdict.

Version the verdict filename by date (`JUDGE-2026-04-22.md`) so prior versions are preserved for audit.

## Reproducibility example

A Measured-label claim from a judge run should be reproducible in a single command once the operator has confirmed the live endpoint:

```bash
curl -sS -X POST "https://elasticjudge.com/v1/evaluate" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ELASTICJUDGE_API_KEY" \
  -d @path/to/payload.json
```

The endpoint path (`/v1/evaluate`) is an educated guess based on common REST conventions and is marked NEEDS-VERIFICATION — confirm against the live API docs at https://elasticjudge.com/ before publishing the stub in a CIO artifact. When the operator publishes the canonical path, update `scripts/judge.sh` and this file in the same commit so the reproducibility stub never drifts from the actual call.

## Defending a verdict under scrutiny

If a reviewer challenges a verdict:

1. Show the reproducibility stub. Re-run the call live if time allows.
2. Walk the axis scores. Identify which axis the disagreement is about.
3. Read the line-level critique for that axis. The judge's reason code is the point of discussion, not the summary verdict.
4. If the reason code is wrong (judge misread the claim), note it and surface to the API operator. Do not cover for the judge; the judge's value is partly in being a third-party evaluator.
5. If the reason code is right but the reviewer still disagrees, the disagreement is between the reviewer and the rubric — not with the skill. Surface the rubric conflict and let the human decision-maker resolve it.

Never fabricate confidence in a verdict. A Measured label on a verified reproducible verdict is strong evidence; anything weaker should not carry a Measured label.
