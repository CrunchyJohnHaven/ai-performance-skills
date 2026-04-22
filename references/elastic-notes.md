# Elastic Notes

Context and commitments specific to the Elastic rollout. Treat this as the deployment runbook for the 2026-04-22 Adnan (Elastic CIO) meeting outcome.

## Meeting outcome (2026-04-22)

Adnan Adil (Elastic CIO) endorsed the thesis after a 30-minute 1:1. The direct ask: **package this as a Claude skill that ships inside the Agent Builder skills catalog**, not as an MCP server and not as a new standalone product line.

Adnan's reasoning:
- Elastic's heritage resists top-down "install this" mandates. Skills are voluntary — employees adopt when they see value.
- MCP is perceived as a token tax and a surveillance vector. Default-off.
- Elastic's product strategy is infrastructure and vector databases; a new cost-AI product line is off-strategy.
- Agent Builder is the natural distribution channel. Add the skill to the templated-skills catalog alongside existing agent builder skills.

Framing for Elastic employees:
- Lead with **employee benefit** (better performance, faster responses, measurable savings)
- Not with company cost reduction (reads as surveillance)
- Goodwill / open-source framing plays well with Elastic's heritage

## Distribution channels

Three channels, same skill folder:

1. **npm package** — `@sapperjohn/kostai` ships this skill under `skills/cost-optimization/`. Employees who already have the npm package get the skill by symlinking into `~/.claude/skills/cost-optimization/` or dropping the folder there directly.
2. **Agent Builder catalog** — Elastic publishes the skill folder to the internal catalog. Employees install via whatever UX Agent Builder exposes for skill catalog install.
3. **Public GitHub** — open-source in a public repo under Elastic's org or the sapperjohn org. Reinforces the goodwill framing Adnan endorsed.

All three channels pull from the same source of truth: `skills/cost-optimization/` in this repo.

## Skill install footprint

The skill itself adds zero runtime cost. When triggered:

- Reads SKILL.md (~1,500 words) into Claude context once
- May load a reference file on demand
- Delegates all action to the `ai-cost` CLI via shell scripts

No always-on process. No background network calls. No MCP server. No surveillance surface.

## What Elastic employees need to know

On first invocation, an Elastic employee should see:

1. A one-sentence description of what the skill does ("cut your Claude Code bill without changing what you ask for")
2. A clear install step they can run in seconds (`scripts/install.sh`)
3. A proof they can show their manager (`scripts/proof.sh`)
4. An optional private feedback packet they can choose to share (`scripts/feedback.sh`)

Do not start with mechanism explanations. Do not start with the 42-technique inventory. Lead with outcome.

## Agent Builder catalog metadata

When publishing to Elastic Agent Builder, use:

- **Skill name:** AI Performance
- **Category:** Productivity / Developer Tools
- **Short description:** Speeds up AI work, cuts LLM waste, and emits a proof-of-savings artifact suitable for manager or CIO review.
- **Trigger phrases:** "AI Performance", "reduce my AI bill", "optimize LLM cost", "prove my Claude Code savings"
- **Owner:** John Bradley, Value Engineering (pending org decision on longer-term owner)
- **Repo path:** `skills/cost-optimization/` until the packaging slug is changed in a later cleanup pass

## Update path

v1 update posture:
- npm-based installs update by running `scripts/update.sh`
- symlink installs inherit the new global package version automatically after `npm install -g @sapperjohn/kostai@latest`
- copied skill folders outside git worktrees can be refreshed in place by `scripts/update.sh`
- Agent Builder installs update by catalog republish rather than local scripting

This keeps the update path simple enough for field use now, without adding an always-on service.

## Feedback loop without surveillance

Default posture:
- no background telemetry
- no MCP requirement
- no automatic sends

Opt-in posture:
- `scripts/feedback.sh` generates a local aggregate packet from proof data
- packet contains cost deltas, savings percentage, mechanism mix, optional employee note
- packet excludes prompt and response bodies
- employee chooses whether to paste or attach it back to the rollout team

## Commitments made in the Adnan meeting

1. Send Adnan the costai.app URL after the meeting (calendar: 2026-04-22, within 24h).
2. Convert the existing npm package + CLI into a Claude skill (this folder).
3. Loop back to Adnan when the skill is field-ready for Elastic employee testing.
4. Brief Jesse Sledik (VP PS) on the outcome before the next Jesse 1:1.
5. Share the outcome with Aaron Gore (sat out of the meeting at his own request).

## What NOT to do on the Elastic rollout

- Do not install an MCP server by default. Adnan explicitly flagged this as surveillance-adjacent.
- Do not frame the skill as "Elastic is watching your AI usage." Employees will opt out.
- Do not request telemetry back to a central Elastic dashboard in v1. Keep it local-first.
- Do not add any "internal only" slides to any exec-facing artifact (see `feedback_no_how_to_read_slides.md`).
- Do not claim unmeasured savings in an exec artifact. Every number carries a Measured / Modeled / Needs verification label.
- Do not use second-person or "you should" language in SKILL.md or references. Imperative form only.

## Success signal

The skill is working when:

1. An Elastic employee installs it and sees their `.ai-cost-data/` ledger populate within a day of normal Claude Code use
2. Running `kostai proof` produces a one-pager showing non-zero measured savings
3. The employee can hand that one-pager to their manager without a walkthrough
4. The employee can optionally generate a `FEEDBACK.md` packet without exposing prompt bodies
5. Adoption grows through word-of-mouth rather than mandate
