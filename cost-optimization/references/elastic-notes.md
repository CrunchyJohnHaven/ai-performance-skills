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
3. **Public GitHub** — open-source at https://github.com/CrunchyJohnHaven/ai-performance-skills.

In this source repo the folder is `cost-optimization/`; packaged builds commonly export the same folder as `skills/cost-optimization/`.

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
- **Repo path:** source repo `cost-optimization/`; packaged builds may export `skills/cost-optimization/`

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

## 2026-04-22 CIO meeting commitments

Outcome of the Adnan CIO meeting on 2026-04-22. These are binding commitments that shape every Elastic-facing artifact and rollout decision.

- **Ship as Claude skill for Agent Builder catalog.** Do not create a new product line. Package as `AI Performance` in the existing skills catalog alongside Brain Orchestration and Quality Judge.
- **Zero MCP default.** No MCP server is installed or enabled by default. MCP remains an opt-in integration. Default-off posture is non-negotiable for the enterprise rollout.
- **10%-of-savings pricing.** The default pass-through rate for any managed offering is 10% of measured savings. The proof artifact renders the math so an employee can justify the rollout to their CIO without hand-waving. Do not hard-code a CLI flag for that rate without re-checking the installed report surface.
- **Employee-benefit framing leads.** Every employee-facing message leads with personal benefit — faster responses, measurable savings, cleaner context — not with company cost reduction. Company-surveillance framing causes opt-out.
- **Measured / Modeled / Needs-verification label on every numeric claim.** No numeric claim appears in any stakeholder-facing output without one of these three labels. This applies to PROOF.md, FEEDBACK.md, slide decks, and any email or Slack message that contains a savings figure.

## Agent Builder catalog metadata

- **Name:** AI Performance
- **Category:** Productivity / Developer Tools
- **Version:** 0.2.0
- **Trigger phrases** (from SKILL.md `description` field):
  - "AI Performance"
  - "reduce my AI bill"
  - "lower my AI bill"
  - "cost optimization"
  - "save dollars on Claude Code"
  - "cut Claude Code spend"
  - "optimize my LLM calls"
  - "route to cheaper models"
  - "compress my prompts"
  - "set up cost optimization"
  - "install cost-optimization"
  - "how much am I spending on Claude or Codex"
  - "am I wasting tokens"
  - "prove my LLM savings"
- **One-sentence pitch:** Cut LLM spend on Claude Code, Codex, and Gemini CLI work on sampled workloads without changing what you ask for, and emit a one-page proof artifact any manager or CIO can read.
- **Repo path:** source repo `cost-optimization/`; packaged builds may export `skills/cost-optimization/`

## Elastic pilot rollout checklist

Five steps for an employee participating in the internal pilot.

1. **Install the skill.** Clone the repo or run `npm install -g @sapperjohn/kostai` and symlink the packaged `skills/cost-optimization/` folder into `~/.claude/skills/cost-optimization/`, or install via the Agent Builder catalog if it is already published there.
2. **Run the demo in your repo.** From the root of any Claude Code workspace, run `scripts/demo.sh`. This shows the scan/report flow and the artifact shape end-to-end. Fresh repos still need real usage or comparison data before the proof shows measured savings.
3. **Review PROOF.md.** After at least one shadow-mode comparison has landed, run `scripts/proof.sh`. Open `deliverables/<audience>-<date>/PROOF.md`. Every number carries a Measured / Modeled / Needs-verification label. If the ledger is empty, say so rather than inferring savings.
4. **Optionally run scripts/feedback.sh.** This generates a privacy-safe local feedback packet — aggregate counts, savings totals, mechanism breakdown, optional note. Prompt and response bodies stay local. No data is sent automatically.
5. **Share FEEDBACK.md with the pilot coordinator if you choose.** Paste or attach `deliverables/<audience>-<date>/FEEDBACK.md` to the pilot coordinator's Slack thread or email. This step is fully opt-in; skipping it does not affect your install or savings.

## Success signal

The skill is working when:

1. An employee installs it and sees their `.ai-cost-data/` ledger populate within a day of normal Claude Code use
2. Running `kostai report` produces a one-pager showing non-zero measured savings
3. The employee can hand that one-pager to a manager without a walkthrough
4. The employee can optionally generate a `FEEDBACK.md` packet without exposing prompt bodies
5. Adoption grows through word-of-mouth rather than mandate
