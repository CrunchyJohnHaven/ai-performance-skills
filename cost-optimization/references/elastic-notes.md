# Elastic Notes

Context and deployment posture for running `AI Performance` (the cost-optimization skill) inside an Elastic-style enterprise environment and/or the Agent Builder skills catalog.

## Packaging decision

This skill is packaged as a Claude skill — voluntary install, no MCP server running by default, no new product line. Rationale:

- Large enterprises resist top-down "install this" mandates. Skills are voluntary and adopted when employees see value.
- A local MCP server reads as a token tax and a surveillance vector to the average employee. Default-off.
- A cost-AI product line is off-strategy for an infra / vector-DB company. A skill that wraps the cost-AI work is in-strategy.
- An internal skills catalog (Agent Builder, or equivalent) is the natural distribution channel.

Framing for employees:

- Lead with **employee benefit** (better performance, faster responses, measurable savings)
- Not with company cost reduction (reads as surveillance)
- Goodwill / open-source framing plays well inside infra-heritage companies

## Distribution channels

Three channels, same skill folder:

1. **npm package** — `@sapperjohn/kostai` ships this skill under `skills/cost-optimization/`. Employees symlink into `~/.claude/skills/cost-optimization/` or drop the folder there directly.
2. **Agent Builder catalog** — publish the skill folder to the internal catalog. Employees install via whatever UX the catalog exposes for skill install.
3. **Public GitHub** — open-source at https://github.com/CrunchyJohnHaven/cost-optimization-skill.

All three channels pull from the same source of truth: `skills/cost-optimization/`.

## Skill install footprint

Zero runtime cost. When triggered:

- Reads SKILL.md (~1,500 words) into Claude context once
- May load a reference file on demand
- Delegates all action to the `ai-cost` CLI via shell scripts

No always-on process. No background network calls. No MCP server. No surveillance surface.

## What an employee sees on first invocation

1. One-sentence description ("cut your Claude Code bill without changing what you ask for")
2. One install step (`scripts/install.sh`)
3. One proof artifact (`scripts/proof.sh`)
4. One optional feedback packet (`scripts/feedback.sh`) — aggregate-only, opt-in, never auto-sent

Do not start with mechanism explanations. Do not start with the 42-technique inventory. Lead with outcome.

## Agent Builder catalog metadata

- **Skill name:** AI Performance
- **Category:** Productivity / Developer Tools
- **Short description:** Speeds up AI work, cuts LLM waste, and emits a proof-of-savings artifact suitable for manager or CIO review.
- **Trigger phrases:** "AI Performance", "reduce my AI bill", "optimize LLM cost", "prove my Claude Code savings"
- **Repo path:** `skills/cost-optimization/`

## Update path

- npm installs update via `scripts/update.sh`
- symlink installs inherit the new global package version after `npm install -g @sapperjohn/kostai@latest`
- copied skill folders outside git worktrees refresh in place via `scripts/update.sh`
- Agent Builder installs update by catalog republish rather than local scripting

## Feedback loop without surveillance

Default posture:
- no background telemetry
- no MCP requirement
- no automatic sends

Opt-in posture:
- `scripts/feedback.sh` generates a local aggregate packet from proof data
- packet contains cost deltas, savings percentage, mechanism mix, optional employee note
- packet excludes prompt and response bodies
- employee chooses whether to paste or attach it back to a rollout team

## Posture for an enterprise rollout

1. Ship `AI Performance` alongside `Brain Orchestration` and `Quality Judge` in the three-skill suite.
2. Keep default-MCP off.
3. Keep every numeric claim labeled Measured / Modeled / Needs verification in any stakeholder-facing output.
4. Route distribution through the internal catalog, not a new product line.

## What NOT to do on the rollout

- Do not install an MCP server by default.
- Do not frame the skill as a company cost-surveillance tool. Employees will opt out.
- Do not request telemetry back to a central dashboard in v1. Local-first.
- Do not add any "internal only" slides to any exec-facing artifact.
- Do not claim unmeasured savings in an exec artifact. Every number carries a Measured / Modeled / Needs verification label.
- Do not use second-person or "you should" language in SKILL.md or references. Imperative form only.

## Success signal

The skill is working when:

1. An employee installs it and sees their `.ai-cost-data/` ledger populate within a day of normal Claude Code use
2. Running `kostai proof` produces a one-pager showing non-zero measured savings
3. The employee can hand that one-pager to a manager without a walkthrough
4. The employee can optionally generate a `FEEDBACK.md` packet without exposing prompt bodies
5. Adoption grows through word-of-mouth rather than mandate
