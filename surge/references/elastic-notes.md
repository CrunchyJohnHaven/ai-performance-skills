# Elastic rollout notes

- **Skill name:** SURGE
- **Short description:** Creates a single deliverables tracker around what, due date, pages, audience, and format.

## Why this matters in the current workspace

The recurring failure mode is not "we forgot there was work." It is that the work exists across many good artifacts, but the control plane is split:
- build packets know pages, audience, and format
- meeting notes know due dates and owners
- send queues know status
- none of those surfaces alone answer the full "what do we owe" question

SURGE exists to collapse those fragments into one operator-visible tracker.

## Current motivating examples

- Aubree Palo Alto 2-pager — the packet exists, but the motion depends on keeping the Palo Alto footprint caveat explicit.
- Dana Aerospace / Space Corp deck — the bounded story exists, but the hard part is the final canonical deck path and donor-to-final promotion.
- IRS perfection — the original packet and audience guidance exist, but the current perfection pass still needs an explicit canonical row.
- OMB perfection — the canonical deck exists, but the tracker should preserve the validation-first audience and format constraints.

## Elastic-specific posture

- Keep rows customer-safe and operational.
- Favor exact artifact names over vague project labels.
- Preserve the audience calibration that already exists in the source packet.
- Use `TBD` openly when the workspace does not yet know the page count, due date, or format.
