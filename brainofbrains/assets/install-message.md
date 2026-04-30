# Copy-Paste Install Message

One-shot bootstrap — an Elastic employee (or any Claude Code / Codex user) pastes the block below into their AI coding tool and the `Brain Orchestration` skill installs the brain substrate, runs the first tick, and demonstrates how to ask an expert question.

---

## For Claude Code or Codex users

Copy the block between the fences and paste into Claude Code or Codex as a single prompt:

```
I'd like to ask an expert brain about my work.

Use the Brain Orchestration skill to do the following, in order:
1. Run `scripts/install.sh` to bootstrap the BrainOfBrains substrate into this
   workspace. It should populate `evidence/brain/` with a seeded
   `brains.json` registry, initial closets, and a `bin/brain` CLI. No code
   outside of `evidence/brain/`, `bin/brain`, `scripts/brain/`, and ignored
   `.ai-cost-data/brain/` runtime state should change.
2. Run `scripts/scan.sh` to list the brains that now live in this workspace.
   Show me each brain's name, role, and status.
3. Run `bin/brain tick` once to produce a first `STATE.json` snapshot.
4. Run `scripts/health.sh` to print PASS/FAIL per brain and the BIV headline.
   Use `--remote` only if I explicitly want the hosted health check too.
5. Pick one question from my recent work (a stakeholder name, a product
   roadmap item, or a meeting follow-up), route it through
   `scripts/ask.sh "<question>"`, synthesize the answer from the layered
   packet, and cite any drawer paths you opened.
6. Tell me three concrete next steps I can take to get more value from the
   substrate: which additional specialist brain to add, which closet is
   weakest, and which stakeholder brain would benefit from more signal.

Do not install an MCP server. Do not send any data off my machine. If any
step fails, report the error verbatim and stop.
```

## How to make the skill available

Claude Code auto-discovers skills from three locations. Pick one:

### Option A — Drop into user skills directory

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git
cp -r ai-performance-skills/brainofbrains ~/.claude/skills/brainofbrains
```

Claude Code will pick up the skill on next session start.

### Option B — Use as a plugin skill

If the workspace is a Claude Code plugin, drop the folder under `skills/` in the plugin directory. Auto-discovered.

### Option C — Use a package-backed build (if your operator ships one)

Link the exported `skills/brainofbrains/` folder from that package into `~/.claude/skills/brainofbrains`.

## For Elastic Agent Builder

When publishing from this source repo, ship `brainofbrains/` as-is. If you are publishing from a packaged build instead, use its exported `skills/brainofbrains/` folder. No rename required; the frontmatter `name: brainofbrains` is the canonical identifier.

Published display name: `Brain Orchestration`

## What to expect

On first run the user sees:

1. `evidence/brain/` created in the repo with `STATE.json`, `brains.json`, and stock closets seeded
2. `bin/brain` CLI available as an executable in the workspace
3. A `scan.sh` output listing substrate + specialist brains, each with a current status
4. A first tick snapshot showing BIV score, last-tick timestamp, and per-brain health
5. One grounded answer to a real question from the user's work, synthesized from the layered packet and drawer pointers

Full runtime cost of the install: zero frontier-model calls. The install step is pure config + local scan + local tick. No local MCP server is started. No data leaves the machine.

## Optional — buy a managed install via agent-to-agent flow

If the user's agent is speaking MCP and wants the remote install path instead of the local one:

```
Use Brain Orchestration's scripts/provision.sh with a stack_description of my
current workspace. Quote first, then ask me to confirm before paying. Use the
x402 payment rail if available.
```

This is an opt-in flow. The free install path remains fully functional without it.
