# Adnan Pilot Gate

Use this reference for Elastic-facing pilots and any rollout framed from the 2026-04-22 Adnan CIO ask.

## Objective

Give Adnan a routing decision, not an open-ended "interesting tool" discussion. The skill should prove whether AI Performance deserves a small Elastic rollout, should be handed to an adjacent owner, or should stop.

## Pilot shape

- One real Elastic workflow, not a generic demo workload
- One named workflow owner
- Roughly four hours per week from that owner
- 30 calendar days
- Shadow mode only; production traffic still receives the baseline response
- Day-30 memo says one of: expand, hand off, or walk away

## Required measurements

- Baseline cost per call
- Optimized cost per call
- Saved dollars and saved percent
- Quality parity on the owner-approved task set
- Mechanism breakdown: cache, model-tier, context-prune, local-routing, or other tagged reducers
- Security/compliance review status

## Gates

- Savings: at least 20% Measured savings on real workflow traffic
- Quality: at least 95% parity against baseline on the agreed task set
- Security/compliance: no blocker raised by the sponsor's normal review path
- Inspectability: ledger and receipts are reviewable by the sponsor
- Ownership: next owner is named before expansion

## Guardrails

- No production routing during the pilot
- No raw prompt or response capture by default
- No default cloud egress
- No MCP server by default
- No Elastic-specific annual savings, finance, or TAM claim unless labeled Measured, Modeled, or Needs verification
- Stop on quality degradation, security/compliance blocker, sponsor stop request, or confirmed overlap with an existing Elastic owner

## Artifacts

Use `scripts/proof.sh --audience <workflow> --date <YYYY-MM-DD>` for the proof packet:

- `PROOF.md`
- `PROOF.html`
- `proof.json`

Use `scripts/feedback.sh --audience <workflow> --date <YYYY-MM-DD>` for the opt-in rollout packet:

- `FEEDBACK.md`
- `SLACK.md`
- `DAY_30_MEMO.md`

The feedback packet is aggregate-only and is never sent automatically.
