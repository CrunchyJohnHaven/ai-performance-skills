# Copy-Paste Install Message

One-shot installer — an Elastic employee (or any Claude Code / Codex user) pastes the block below into their AI coding tool and the `AI Performance` skill initializes the workspace, scans for waste, and explains the next savings steps.

---

## For Claude Code or Codex users

Copy the block between the fences and paste into Claude Code or Codex as a single prompt:

```
I'd like to see how much I could save on my AI bill.

Use the AI Performance skill to do the following, in order:
1. Run `scripts/install.sh` to write `ai-cost.config.json` and initialize the
   local ai-cost workspace.
2. Run `scripts/scan.sh` to detect local runtimes and LLM call sites in this
   repo.
3. If `.ai-cost-data/` already contains real usage or comparison data, run
   `scripts/proof.sh --audience demo --date $(date +%Y-%m-%d)` and show me
   the resulting `deliverables/demo-$(date +%Y-%m-%d)/PROOF.md` inline.
4. If the repo is fresh and there is no data yet, explain that the first proof
   will be a baseline until real usage lands in `.ai-cost-data/`, then tell
   me the three highest-leverage next steps from the scan output.
5. Optionally run `scripts/feedback.sh --audience elastic-pilot --date $(date +%Y-%m-%d)` only if there is meaningful local data to summarize. Do not send anything automatically.

Do not edit source code outside of `ai-cost.config.json` and `.ai-cost-data/` unless I
explicitly approve each edit. Do not install an MCP server. Do not send any
data off my machine. If any step fails, report the error verbatim and stop.
```

## How to make the skill available

Claude Code auto-discovers skills from three locations. Pick one:

### Option A — Drop into user skills directory

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git
cp -r ai-performance-skills/cost-optimization ~/.claude/skills/cost-optimization
```

Claude Code will pick up the skill on next session start.

### Option B — Use as a plugin skill

If the workspace is a Claude Code plugin, drop the folder under `skills/` in the plugin directory. Auto-discovered.

### Option C — Install the npm package (ships the skill)

```bash
npm install -g @sapperjohn/kostai
# Then link the skill folder from the package into ~/.claude/skills/
ln -s "$(npm prefix -g)/lib/node_modules/@sapperjohn/kostai/skills/cost-optimization" \
      ~/.claude/skills/cost-optimization
```

## For Elastic Agent Builder

When publishing from this source repo, ship `cost-optimization/` as-is. If you are publishing from a packaged build instead, use its exported `skills/cost-optimization/` folder. No rename required; the frontmatter `name: cost-optimization` is the canonical identifier.

Published display name: `AI Performance`

## What to expect

On first run the user sees:

1. `ai-cost.config.json` written to their repo (capture mode `metadata_only`, router default rules, shadow-mode enabled)
2. A local `.ai-cost-data/` directory once real calls or comparisons begin landing
3. `scripts/scan.sh` output showing detected runtimes and candidate call sites
4. `deliverables/demo-<date>/PROOF.md` if real data already exists in the repo
5. Optional: `deliverables/elastic-pilot-<date>/FEEDBACK.md` if `scripts/feedback.sh` is run after meaningful data exists

Full runtime cost of the install step: zero frontier-model calls. The install flow is pure config + local scan.
