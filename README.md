# AI Performance Skills — a three-skill open-source suite for Claude

![CI](https://github.com/CrunchyJohnHaven/ai-performance-skills/actions/workflows/ci.yml/badge.svg)
[![npm](https://img.shields.io/npm/v/@sapperjohn/kostai.svg)](https://www.npmjs.com/package/@sapperjohn/kostai)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Quick start:** `bash scripts/install-all.sh` → restart Claude Code → `/cost-optimization`

Three Claude skills that cut AI bills, orchestrate work across tools, and catch AI slop before it leaves the building — shipped together under one MIT license.

---

## What this is

This repository hosts three independent Claude skills that each solve one problem most AI-using teams eventually hit: cost runaway, workflow fragmentation, and unreviewed AI output. Each skill is self-contained and can be installed on its own. Together they form the employee-side stack for working with Claude (or any frontier model) without the bill, the chaos, or the slop.

Every skill in this suite is:

- **Local-first.** Nothing leaves your machine unless you explicitly share it.
- **Opt-in MCP.** No telemetry, no surveillance server, no default-on data collection.
- **Employee-owned.** The skills are built to make the individual employee more productive and more credible with their manager, not to give a central team a dashboard over their shoulder.
- **Open source (MIT).** Fork it, audit it, ship it inside your own internal catalog.

If you are running Claude Code, Codex, or Gemini CLI today, all three skills drop into `~/.claude/skills/` and work immediately. Any internal skill catalog (Claude desktop, Agent Builder, or a self-hosted registry) can ingest these folders as-is.

---

## The three skills at a glance

| Skill | Domain | What it does | One-line install |
|---|---|---|---|
| **cost-optimization** | Spend | Scans the repo, applies safe savings patches, routes non-frontier work cheaper, emits a proof-of-savings artifact | `git clone … ~/.claude/skills/cost-optimization` |
| **brainofbrains** | Orchestration | Agent-to-agent distribution layer that watches local AI tools and routes tasks across a three-tier compute pipeline | `git clone … ~/.claude/skills/brainofbrains` |
| **elasticjudge** | Quality | Judge-first evaluation kernel that scores AI-generated slides (and other artifacts) on content, formatting, and persona before a human sees them | `git clone … ~/.claude/skills/elasticjudge` |

Full install commands are in [Install any one skill](#install-any-one-skill). Each skill links to its own `SKILL.md` for the user-facing catalog description Claude actually consumes.

- [cost-optimization/SKILL.md](./cost-optimization/SKILL.md)
- [brainofbrains/SKILL.md](./brainofbrains/SKILL.md)
- [elasticjudge/SKILL.md](./elasticjudge/SKILL.md)

---

## Why three skills?

Three different people at a company usually ask three different questions about AI, and these are the three:

1. **"Why is this so expensive?"** → cost-optimization
2. **"How do I get these tools to work together?"** → brainofbrains
3. **"How do I know this slide / doc / answer is any good?"** → elasticjudge

If you only install one, install the one that matches the question your manager is actually asking this quarter. If you install all three, you get a coherent layer between the employee and their frontier model of choice that (a) makes them faster, (b) makes them cheaper, and (c) lets them defend their output.

The thesis behind this packaging: the right entry point for AI cost / orchestration / quality work inside a large org is a voluntary skill catalog, not an MCP surveillance server and not a new product line. Skills get adopted when an employee sees value; catalogs grow from the bottom. This suite is what that looks like in code.

---

## Architecture

```
           +------------------------------------------+
           |                 Employee                 |
           |       (Claude Code / Codex / Gemini)     |
           +----------------------+-------------------+
                                  |
          +-----------------------+-----------------------+
          |                       |                       |
    +-----v------+        +-------v-------+       +-------v-------+
    |  cost-     |        | brainofbrains |       | elasticjudge  |
    |  optim.    |        |  (orch)       |       |  (quality)    |
    +------------+        +---------------+       +---------------+
    scan + route          watch + dispatch         judge + revise
    proof artifact        three-tier pipeline      content/form/persona
          |                       |                       |
          +-----------------------+-----------------------+
                                  |
                      +-----------v-----------+
                      |   Local fs + caches   |
                      |   Optional: local LM  |
                      |   Optional: MCP (off) |
                      +-----------------------+
```

Each skill is standalone. The arrows are conventions, not dependencies: nothing in the repo forces you to run them together. If you install only `elasticjudge`, it still judges slides. If you install only `cost-optimization`, it still prints a proof artifact. The composition is the point, but the independence is the guarantee.

---

## Install any one skill

Pick the one you want. Each block is copy-paste ready.

### cost-optimization

```bash
# Clone directly into your Claude skills directory
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git /tmp/aips
cp -R /tmp/aips/cost-optimization ~/.claude/skills/cost-optimization
```

Then ask Claude for `AI Performance`, or run the bootstrap flow manually:

```bash
cd ~/.claude/skills/cost-optimization
scripts/install.sh
scripts/scan.sh
scripts/optimize.sh
scripts/proof.sh --audience demo --date "$(date +%Y-%m-%d)"
```

> **Note:** `scripts/install.sh` bootstraps the environment. The underlying CLI command it wraps is `npx @sapperjohn/kostai init`.

Alternative install via npm:

```bash
npm install -g @sapperjohn/kostai
ln -s "$(npm root -g)/@sapperjohn/kostai/skills/cost-optimization" \
      ~/.claude/skills/cost-optimization
```

### brainofbrains

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git /tmp/aips
cp -R /tmp/aips/brainofbrains ~/.claude/skills/brainofbrains
```

Smoke-test:

```bash
npx -y brainofbrains scan
```

### elasticjudge

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git /tmp/aips
cp -R /tmp/aips/elasticjudge ~/.claude/skills/elasticjudge
```

Generate a judge packet against a sample slide:

```bash
cd ~/.claude/skills/elasticjudge
npx elastic-judge packet ./examples/sample-slide.json
```

### All three at once

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git /tmp/aips
for s in cost-optimization brainofbrains elasticjudge; do
  cp -R /tmp/aips/$s ~/.claude/skills/$s
done
```

---

## What each skill actually does

### cost-optimization — "AI Performance"

Wraps the `@sapperjohn/kostai` / `ai-cost` toolchain. It scans a repo for LLM call sites, applies safe savings patches (Anthropic prompt caching, prose compression, expensive-model gating), routes non-frontier work to cheaper or local models, and emits a manager-friendly proof artifact under `deliverables/<audience>-<date>/`.

42 cost-reduction techniques live in the underlying CLI across nine categories: model routing, context compression, waste detection, caching, shadow-mode A/B, local inference, batching, budget governance, and observability. The skill's job is to point Claude at the right verbs in the right order.

Target: 60–92% input-token reduction with a one-page receipt an employee can show their manager or CIO. Every numeric claim carries a **Measured / Modeled / Needs verification** label — no bullshit claims leave the artifact.

Companion landing page: [kostai.app](https://kostai.app/).

### brainofbrains — orchestration layer

A small, quiet helper that watches a developer's AI tools (Claude, ChatGPT, Gemini) and routes work through the three-tier compute pipeline: cached data → open-source / local models → frontier models. It deduplicates, compresses, and picks the cheapest model that still clears quality.

The user experience: a weekly plain-English email showing savings achieved. The developer-facing artifact: a skill Claude can invoke to see what's cached, what's been routed, and what's still flowing to frontier.

Companion landing page: [brainofbrains.ai](https://brainofbrains.ai/).

### elasticjudge — quality kernel

A judge-first evaluation kernel. The central design bet:

> Do not start by building a machine that makes good PowerPoints. Start by building a machine that can reliably tell whether a slide is good.

Two independent lanes score every artifact:

1. **Content lane** reads the slide like a skeptical enterprise buyer, sentence by sentence: what are we trying to say, how is this additive, could this be said better, where will the customer get confused.
2. **Formatting lane** treats the slide as an image: is hierarchy obvious in under five seconds, does the layout feel intentional, is spacing consistent.

A synthesizer merges lane verdicts into one **approve / revise / rebuild** decision. Once the judge is stable, generation becomes an optimization loop against it.

Companion landing page: [elasticjudge.com](https://elasticjudge.com/).

---

## Framing — employee benefit, not company surveillance

This suite was packaged after a direct CIO ask: build it as a skill people can choose to install, not as something you push to endpoints. Three consequences follow:

1. **No default MCP.** If a skill needs MCP, it asks first, and the user can say no and keep the skill.
2. **No body exfiltration.** The cost-optimization proof artifact captures hashes and token counts by default. Prompt and response bodies stay local unless the user opts into `redacted_body` or `full_body` for debugging.
3. **Aggregate-only share-back.** The optional feedback packet is aggregate metrics — savings totals, technique breakdown, optional free-form notes. It never auto-sends and never includes prompts or responses.

The framing in every artifact leads with employee benefit: faster responses, cleaner context, measurable savings, better-looking slides. Central teams can still see aggregate adoption if the employee chooses to share, but the employee owns the share.

---

## License

All three skills in this repo are **MIT-licensed and free to self-host.** No license-gating code runs inside the skills themselves. Fork, audit, ship, run inside any internal catalog.

Companion sites for each skill:

- **cost-optimization** — [kostai.app](https://kostai.app/)
- **brainofbrains** — [brainofbrains.ai](https://brainofbrains.ai/)
- **elasticjudge** — [elasticjudge.com](https://elasticjudge.com/)

---

## Skill catalog distribution

These skills are designed for catalog distribution. A catalog install lives next to other voluntary skills; no one gets forced into adoption, and the employee sees value (savings, orchestration, quality) on day one.

If you're operating an internal skills catalog, the drop-in pattern is the same — every skill lives in its own directory with its own `SKILL.md`, its own `scripts/`, and its own license-compatible dependency set.

---

## Repo layout

```
/
├── cost-optimization/     # KostAI / ai-cost wrapper
│   ├── SKILL.md
│   ├── scripts/
│   ├── references/
│   └── assets/
├── brainofbrains/         # orchestration skill
│   ├── SKILL.md
│   └── …
├── elasticjudge/          # judge-first evaluation kernel
│   ├── SKILL.md
│   └── …
├── LICENSE                # MIT
├── AGENTS.md              # publishing + guardrails
└── README.md              # this file
```

---

## License

MIT. See [LICENSE](./LICENSE). Every skill in this repo is MIT; any third-party bundle (e.g. npm `@sapperjohn/kostai`) carries its own license, called out in the relevant skill's `SKILL.md`.

---

## Roadmap

- Ship all three skills into the Elastic Agent Builder catalog.
- Add an `examples/` top-level directory showing all three skills composed end-to-end (scan → route → judge → proof).
- Publish a per-skill npm package so `npx` installs work without cloning.
- Optional image-aware adapter for `elasticjudge` formatting lane.
- Deck-level coherence checks in `elasticjudge` (slide-to-slide, not just slide-local).
- Shadow-mode benchmarks across all three skills into a single rollup artifact.

---

## Contributing

PRs welcome for any of the three skills. Ground rules:

- Each skill stays self-contained. If you need cross-skill behavior, expose it as a documented contract, not a hidden import.
- Every numeric claim in a user-facing artifact is labeled Measured / Modeled / Needs verification.
- Never add default-on telemetry or MCP requirements. Opt-in only, per-skill.
- Follow the guardrails in [AGENTS.md](./AGENTS.md) — especially the "never automatic share-back" rule.

---

## Repo name

This repo was renamed from `cost-optimization-skill` to `ai-performance-skills` on 2026-04-22. GitHub automatically redirects the old URL, so existing clones keep working.

---

## Credits

Originated by John Bradley. Built in the open so any company can fork, audit, and adopt without waiting on a vendor roadmap.
