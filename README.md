# AI Performance Skills — open-source workflow skills for Claude Code, Codex, and Gemini CLI

![CI](https://github.com/CrunchyJohnHaven/ai-performance-skills/actions/workflows/ci.yml/badge.svg)
[![npm](https://img.shields.io/npm/v/@sapperjohn/kostai.svg)](https://www.npmjs.com/package/@sapperjohn/kostai)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Quick start:** `git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git && cd ai-performance-skills && bash scripts/install-all.sh` → open a new Claude Code session → ask `lower my AI bill`

Three local-first skills that cut AI bills, orchestrate work across tools, and catch AI slop before it leaves the building — shipped together under one MIT license.

---

## Skill quick-reference

| Skill | When to use | Core command | Output |
|-------|-------------|--------------|--------|
| `cost-optimization` | Reduce AI API spend | `scripts/proof.sh` | `deliverables/*/PROOF.md` |
| `brainofbrains` | Route expert questions | `scripts/ask.sh` | stdout answer with citations |
| `elasticjudge` | Gate deliverables before sending | `scripts/judge.sh` | `deliverables/*/JUDGE.md` |

---

## What this is

This repository hosts three independent skill folders that each solve one problem most AI-using teams eventually hit: cost runaway, workflow fragmentation, and unreviewed AI output. Each skill is self-contained and can be installed on its own. Together they form an employee-side stack for working with frontier models without the bill, the chaos, or the slop.

Every skill in this suite is:

- **Local-first.** Nothing leaves your machine unless you explicitly share it.
- **Opt-in MCP.** No telemetry, no surveillance server, no default-on data collection.
- **Employee-owned.** The skills are built to make the individual employee more productive and more credible with their manager, not to give a central team a dashboard over their shoulder.
- **Open source (MIT).** Fork it, audit it, ship it inside your own internal catalog.

Claude Code reads these folders directly from `~/.claude/skills/`. Codex, Gemini CLI, and internal skill catalogs can ingest the same folders through their own local skill or catalog mechanisms.

## Trust At A Glance

| Posture | Default |
|---|---|
| Telemetry | None by default |
| MCP | Opt-in only |
| Data egress | Local-first; remote calls happen only when a user explicitly invokes a cloud-backed flow |
| Share-back | Manual only |
| License | MIT |

---

## The three skills at a glance

| Skill | Domain | What it does | One-line install |
|---|---|---|---|
| **cost-optimization** | Spend | Scans the repo, surfaces safe savings patches, routes non-frontier work cheaper, emits a proof-of-savings artifact | `git clone … ~/.claude/skills/cost-optimization` |
| **brainofbrains** | Orchestration | Agent-to-agent distribution layer that watches local AI tools and routes tasks across a three-tier compute pipeline | `git clone … ~/.claude/skills/brainofbrains` |
| **elasticjudge** | Quality | Judge-first evaluation kernel that scores AI-generated slides (and other artifacts) on content, formatting, and persona before a human sees them | `git clone … ~/.claude/skills/elasticjudge` |

Full install commands are in [Install](#install). Each skill links to its own `SKILL.md` for the user-facing catalog description Claude actually consumes.

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
    scan + route          watch + dispatch         judge + review
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

## Testing

Four levels of quality assurance are available, from fast syntax checks to full end-to-end integration.

### `make check` — bash syntax for all scripts

Runs `bash -n` across every `.sh` file in all three skill directories. Fastest check; no network required.

```bash
make check
```

Expected output: one `PASS <path>` line per script, then `Results: N passed, 0 failed`. Any syntax error prints the offending script and exits non-zero.

### `npx pulser-cli . --no-anim` — skill linting (100/100 target)

Validates SKILL.md frontmatter, required sections, script references, and catalog metadata across all three skills. Target score is 100/100 — the CI gate runs with `--strict` and fails on any warning.

```bash
npx --yes pulser-cli . --no-anim
```

Runs automatically in CI via the `pulser` job in `.github/workflows/ci.yml`.

### `scripts/smoke-test.sh` — kostai integration from any repo

Verifies the cost-optimization skill end-to-end from a directory that has an `ai-cost.config.json`. Safe to run against a real project or against a freshly initialized repo.

```bash
# From the repo root (uses the bundled smoke-test):
make smoke-test

# Or from any repo that already has ai-cost.config.json:
bash /path/to/aips/cost-optimization/scripts/smoke-test.sh
```

### `scripts/test-integration.sh` — full integration test suite

Runs all four test groups (A–D) and exits 0 only if every test passes. Requires Node.js >=18 and `npx` on `$PATH`. Network access is needed for Group A (npm package availability) and Group B's kostai calls.

```bash
# From the repo root:
bash scripts/test-integration.sh
```

Test groups:

| Group | What it checks |
|---|---|
| **A — CLI availability** | `@sapperjohn/kostai` version, `scan`, `report` |
| **B — Script behavior** | per-skill script exit codes and error messages |
| **C — Skill structure** | SKILL.md frontmatter, `## Gotchas`, script inventory |
| **D — Install** | `install-all.sh --dry-run`, `make check` |

A grouped summary (PASS/FAIL counts per group) is printed at the end.

### ShellCheck

The CI `shellcheck` job runs [ShellCheck](https://www.shellcheck.net/) at the `warning` severity level across every `.sh` in the repo. To run locally:

```bash
# macOS
brew install shellcheck
shellcheck -S warning cost-optimization/scripts/*.sh \
                      brainofbrains/scripts/*.sh \
                      elasticjudge/scripts/*.sh \
                      scripts/*.sh
```

The CI badge at the top of this file links directly to the GitHub Actions runs:

[![CI](https://github.com/CrunchyJohnHaven/ai-performance-skills/actions/workflows/ci.yml/badge.svg)](https://github.com/CrunchyJohnHaven/ai-performance-skills/actions/workflows/ci.yml)

---

## Install

### Before you install

- Node.js `>=18`, `npm`, `git`, and `bash`
- Claude Code reads `~/.claude/skills/` directly
- Other local skill catalogs can ingest the same top-level folders from this repo
- `curl` is only required for `brainofbrains/scripts/provision.sh`
- This source repo stores skills at the top level: `cost-optimization/`, `brainofbrains/`, and `elasticjudge/`. Some packaged builds nest the same folders under `skills/<name>/`.

### Install all three for Claude Code

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git
cd ai-performance-skills
bash scripts/install-all.sh
```

Open a new Claude Code session after the installer finishes. If you prefer `make`, `make install-all` performs the same local copy.

### Install one skill from this source repo

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git /tmp/aips
mkdir -p ~/.claude/skills
cp -R /tmp/aips/cost-optimization ~/.claude/skills/cost-optimization
```

For `brainofbrains`:

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git /tmp/aips
mkdir -p ~/.claude/skills
cp -R /tmp/aips/brainofbrains ~/.claude/skills/brainofbrains
```

For `elasticjudge`:

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git /tmp/aips
mkdir -p ~/.claude/skills
cp -R /tmp/aips/elasticjudge ~/.claude/skills/elasticjudge
```

If you are linking from a packaged build instead of this source repo, use the exported `skills/<name>/` path that package provides.

### First run from the workspace you actually want to inspect

Install adds the skills to your catalog. Run the scripts from the repo or workspace you want to operate on, not from `~/.claude/skills/`.

For `cost-optimization`:

```bash
cd /path/to/target-repo
~/.claude/skills/cost-optimization/scripts/install.sh
~/.claude/skills/cost-optimization/scripts/scan.sh
```

If the workspace already has ai-cost data, then run:

```bash
~/.claude/skills/cost-optimization/scripts/proof.sh --audience demo --date "$(date +%Y-%m-%d)"
```

Expected result: `ai-cost.config.json` appears in the target repo, `scan.sh` lists detected runtimes and call sites, and `proof.sh` writes `deliverables/demo-<date>/PROOF.md` once real usage data exists.

For `brainofbrains`:

```bash
cd /path/to/target-workspace
~/.claude/skills/brainofbrains/scripts/install.sh
~/.claude/skills/brainofbrains/scripts/scan.sh
~/.claude/skills/brainofbrains/scripts/ask.sh "what changed this week?"
```

Expected result: the target workspace gains `bin/brain` plus `evidence/brain/`, `scan.sh` lists installed brains, and `ask.sh` returns a layered answer with citations.

For `elasticjudge`:

```bash
cd /path/to/target-workspace
export ELASTICJUDGE_API_KEY="<token-if-required>"
~/.claude/skills/elasticjudge/scripts/judge.sh --audience pre-send --date "$(date +%Y-%m-%d)" docs/MEMO.md
```

Expected result: the workspace gains `deliverables/pre-send-<date>/JUDGE.md` plus `verdict.json`. The script exits non-zero on invocation or HTTP failure; the verdict itself is written into the artifact.

### Update installed skills

If you installed from this git checkout:

```bash
cd /path/to/ai-performance-skills
git pull
make check
bash scripts/install-all.sh
```

If you installed a package-backed copy under `~/.claude/skills/`, use the per-skill updater that lives inside the installed folder:

```bash
~/.claude/skills/cost-optimization/scripts/update.sh
~/.claude/skills/brainofbrains/scripts/update.sh
ELASTICJUDGE_PKG=<package-name-if-needed> ~/.claude/skills/elasticjudge/scripts/update.sh
```

Open a new Claude Code session after updating so the refreshed skill definitions are loaded.

### Example materials

If you want to see the output shape before installing, start with:

- [examples/sample-scan.md](./examples/sample-scan.md) — sample `cost-optimization` scan output
- [examples/sample-brain-answer.md](./examples/sample-brain-answer.md) — sample `brainofbrains` answer with layered citations
- [examples/sample-proof.md](./examples/sample-proof.md) — sample proof artifact format
- [examples/sample-memo.md](./examples/sample-memo.md) — intentionally imperfect memo for `elasticjudge`
- [examples/test-prompts.md](./examples/test-prompts.md) — trigger phrases for each skill

---

## What each skill actually does

### cost-optimization — "AI Performance"

Wraps the `@sapperjohn/kostai` / `ai-cost` toolchain. It scans a repo for LLM call sites, surfaces safe savings patches (Anthropic prompt caching, prose compression, expensive-model gating), routes non-frontier work to cheaper or local models, and emits a manager-friendly proof artifact under `deliverables/<audience>-<date>/`.

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

A synthesizer merges lane verdicts into one **pass / needs-revision / reject** decision. Once the judge is stable, generation becomes an optimization loop against it.

Companion landing page: [elasticjudge.com](https://elasticjudge.com/).

---

## Framing — employee benefit, not company surveillance

This suite was packaged after a direct CIO ask: build it as a skill people can choose to install, not as something you push to endpoints. Three consequences follow:

1. **No default MCP.** If a skill needs MCP, it asks first, and the user can say no and keep the skill.
2. **No body exfiltration.** The cost-optimization proof artifact captures hashes and token counts by default. Prompt and response bodies stay local unless the user opts into `redacted_body` or `full_body` for debugging.
3. **Aggregate-only share-back.** The optional feedback packet is aggregate metrics — savings totals, technique breakdown, optional free-form notes. It never auto-sends and never includes prompts or responses.

The framing in every artifact leads with employee benefit: faster responses, cleaner context, measurable savings, better-looking slides. Central teams can still see aggregate adoption if the employee chooses to share, but the employee owns the share.

---

## Share results (optional)

The only shipped share-back flow is manual. Nothing in this repo auto-sends anything to a central service.

Run the feedback packet from the workspace you already instrumented:

```bash
cd /path/to/target-repo
~/.claude/skills/cost-optimization/scripts/feedback.sh --audience manager --date "$(date +%Y-%m-%d)"
```

This creates local artifacts under `deliverables/<audience>-<date>/`:

- `FEEDBACK.md` — human-readable summary
- `SLACK.md` — short paste-ready summary
- `feedback.json` — machine-readable companion artifact

Review the files, then decide whether to paste or upload them anywhere. If you stop after generation, nothing leaves your machine.

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

## Troubleshooting

**Skill not activating after install**
Skills load at session start. Restart your Claude Code session after running `make install-all` or `bash scripts/install-all.sh`.

**`bash: EXTRA_ARGS[@]: unbound variable`**
You are on macOS with the system bash 3.2, which does not support named arrays. This is fixed in v0.3.0. Update with:
```bash
make update-all          # package-backed installs under ~/.claude/skills/
# or refresh from this repo checkout:
git pull && bash scripts/install-all.sh
```

**`npx: command not found`**
Install Node.js 18 or later. All scripts that invoke `@sapperjohn/kostai` require `npx` on `$PATH`.

**`kostai: command not found`**
Same root cause as above — the scripts call `npx --yes @sapperjohn/kostai` and need Node.js 18+. Install Node from [nodejs.org](https://nodejs.org/) or via your package manager.

**`curl: command not found`**
`brainofbrains/scripts/provision.sh` requires `curl`. Install it:
- macOS: `brew install curl`
- Debian/Ubuntu: `sudo apt-get install curl`
- RHEL/Fedora: `sudo dnf install curl`

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
