# Elastic Notes

Context and deployment posture for running `Brain Orchestration` inside an Elastic-style enterprise environment and/or the Agent Builder skills catalog.

## Packaging decision

This skill is packaged as a Claude skill — voluntary install, no MCP server running by default, no new product line. Rationale:

- Large enterprises resist top-down "install this" mandates. Skills are voluntary and adopted when employees see value.
- A local MCP server reads as a token tax and a surveillance vector to the average employee. Default-off.
- An orchestration product line is off-strategy for an infra / vector-DB company. A skill that wraps the orchestration is in-strategy.
- An internal skills catalog (Agent Builder, or equivalent) is the natural distribution channel. Publish the skill folder and let adoption grow bottom-up.

Framing for employees:
- Lead with **employee benefit** (synthesized expert answers, fewer tabs, less re-pasting of context)
- Not with company visibility into employee knowledge (reads as surveillance)
- Goodwill / open-source framing plays well with infra-heritage companies

## Distribution channels

Three channels, same skill folder:

1. **npm package** — `@sapperjohn/brainofbrains` may ship this skill under `skills/brainofbrains/` once published. Employees symlink into `~/.claude/skills/brainofbrains/` or drop the folder there directly.
2. **Agent Builder catalog** — publish the skill folder to the internal catalog. Employees install via whatever UX the catalog exposes for skill install.
3. **Public GitHub** — open-source at https://github.com/CrunchyJohnHaven/ai-performance-skills alongside `AI Performance` and `Quality Judge`.

In this source repo the folder is `brainofbrains/`; packaged builds may export the same folder as `skills/brainofbrains/`.

## Skill install footprint

Zero runtime cost. When triggered:

- Reads SKILL.md into Claude context once
- May load a reference file on demand
- Delegates all action to `bin/brain` via shell scripts, or to the remote MCP only for the opt-in provisioning flow

No always-on process. No background network calls. No local MCP server. No surveillance surface. Brains run entirely on the employee's machine after install; the remote MCP at `brainofbrains.ai/mcp` is only touched if the employee explicitly runs `scripts/provision.sh`.

## What an employee sees on first invocation

1. One-sentence description ("route expert questions to specialist brains and get a synthesized answer")
2. One install step (`scripts/install.sh`)
3. One ask step (`scripts/ask.sh "<question>"`)
4. One health check (`scripts/health.sh`)

Do not start with mechanism explanations. Do not start with BIV formula math. Lead with outcome.

## Agent Builder catalog metadata

- **Skill name:** Brain Orchestration
- **Category:** Productivity / Developer Tools
- **Short description:** Routes expert questions to specialist brains and returns synthesized answers — one question, one synthesized answer shaped by every specialist who already knows the relevant stakeholder, product, or codebase.
- **Version:** 0.1.0
- **Trigger phrases** (from SKILL.md description frontmatter): "Brain Orchestration", "brain orchestration", "install brains", "brainofbrains", "BrainOfBrains", "call the expert", "ask an expert brain", "specialist brains", "route this to the right brain", "agent-to-agent install", "bootstrap brains into this workspace", "set up specialist brains"
- **Repo path:** source repo `brainofbrains/`; packaged builds may export `skills/brainofbrains/`
- **MCP default:** OFF. No local MCP server is installed by default. The remote MCP at `brainofbrains.ai/mcp` is only contacted if the employee explicitly runs `scripts/provision.sh`. This is non-negotiable for catalog publication — a default-on MCP is a blocker.

## Employee-benefit framing

Use these bullets when explaining the skill to a skeptical Elastic employee — focus on what the employee personally gains, not what the company gains:

- **Privacy is the default, not a policy promise.** Every tick, query, and closet rebuild runs entirely on your own machine. Nothing leaves unless you explicitly run the provisioning script. There is no phone-home, no background telemetry, and no local server listening for connections.
- **No surveillance surface.** The skill reads commits, meeting transcripts, and KB artifacts that you point it at. It does not read your screen, browser history, keystrokes, or any file outside the paths you configure. The closet builder redacts known secret patterns before writing any closet.
- **Opt-in remote, opt-out local.** The remote MCP at `brainofbrains.ai/mcp` is only touched if you run `scripts/provision.sh` or `scripts/health.sh --remote`. All other operations — queries, tick loops, BIV scoring, health checks — stay local. Stop invoking those remote paths or remove any manually added remote endpoint config to revert to fully local operation.
- **What you personally gain:** ask one question and get a synthesized answer shaped by every specialist context you have already built — without opening a second tab, re-pasting background, or waiting for a colleague to respond. The longer you run the tick loop, the more relevant your synthesized answers become.

## 2026-04-22 commitments

From the Adnan CIO meeting (2026-04-22):

- **Ship as a Claude skill for the Agent Builder catalog.** This is the agreed distribution channel — not a new product line, not a managed install mandate. The skill folder goes into the catalog; adoption grows bottom-up.
- **Zero MCP by default.** No local MCP server is installed. No remote MCP is contacted without explicit employee opt-in. This was a hard requirement from the CIO conversation and is non-negotiable in v1.
- **Employee-owned.** The brains, closets, and STATE files live on the employee's machine. The employer does not see the data. Aggregate-only sharing back to a central service is a future opt-in, never a default.

## Update path

- npm-based installs update via `scripts/update.sh`
- symlink installs inherit the new global package version after `npm install -g @sapperjohn/brainofbrains@latest`
- copied skill folders outside git worktrees refresh in place via `scripts/update.sh`
- Agent Builder installs update by catalog republish rather than local scripting

## Feedback loop without surveillance

Default posture:
- no background telemetry
- no local MCP requirement
- no automatic sends
- no closet data ever leaves the machine

Opt-in posture:
- `scripts/health.sh --remote` polls the `health_check(install_id)` MCP tool — useful only to prove install reliability back to the buy-flow
- a future aggregate feedback packet mirroring the `AI Performance` pattern may ship BIV deltas and synthesis-quality metrics, always opt-in, always local-first

## Posture for an enterprise rollout

1. Ship `Brain Orchestration` alongside `AI Performance` and `Quality Judge` in the suite.
2. Keep default-MCP off — no regression.
3. Keep every numeric claim labeled Measured / Modeled / Needs verification in any stakeholder-facing output.
4. Route distribution through the internal catalog, not through a new product line.

## What NOT to do on the rollout

- Do not install a local MCP server by default.
- Do not frame the skill as a visibility layer for the employer.
- Do not request telemetry back to a central dashboard in v1. Local-first.
- Do not add any "internal only" slides to any exec-facing artifact.
- Do not claim unmeasured BIV numbers in an exec artifact. Every number carries a Measured / Modeled / Needs verification label.
- Do not use second-person or "you should" language in SKILL.md or references. Imperative form only.

## Success signal

The skill is working when:

1. An employee installs it and sees `evidence/brain/brains.json` populate within seconds
2. `scripts/ask.sh "<question>"` returns a synthesized answer citing local closets
3. `scripts/health.sh` reports the local status snapshot, per-brain labels, and the BIV headline
4. The employee can hand a health snapshot to a manager without a walkthrough
5. Adoption grows through word-of-mouth rather than mandate
