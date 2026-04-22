# Copy-Paste Install Message

One-shot installer — an Elastic employee (or any Claude Code / Codex user) pastes the block below into their AI coding tool and the `AI Performance` skill bootstraps itself, produces a proof, and explains what happened.

---

## For Claude Code or Codex users

Copy the block between the fences and paste into Claude Code or Codex as a single prompt:

```
I'd like to see how much I could save on my AI bill.

Use the AI Performance skill to do the following, in order:
1. Run `scripts/demo.sh` to write ai-cost.config.json, apply safe starter
   patches (Anthropic prompt cache, prose compressor, expensive-model gate),
   and seed the ten-question before/after workload so there is real ledger
   data. No code other than config should change. The demo workload is
   deterministic — the numbers will be stable across runs.
2. Run `scripts/proof.sh --audience demo --date $(date +%Y-%m-%d)` to write
   `deliverables/demo-$(date +%Y-%m-%d)/PROOF.md`.
3. Show me `deliverables/demo-$(date +%Y-%m-%d)/PROOF.md` inline.
4. Tell me three concrete next steps I can take based on the scan output from
   `scripts/optimize.sh`.
5. Optionally run `scripts/feedback.sh --audience elastic-pilot --date $(date +%Y-%m-%d)` to prepare a local aggregate feedback packet I can choose to share back with the rollout team. Do not send anything automatically.

Do not edit source code outside of ai-cost.config.json and .kostai/ unless I
explicitly approve each edit. Do not install an MCP server. Do not send any
data off my machine. If any step fails, report the error verbatim and stop.
```

## How to make the skill available

Claude Code auto-discovers skills from three locations. Pick one:

### Option A — Drop into user skills directory

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git
cp -r ai-performance-skills/skills/cost-optimization ~/.claude/skills/cost-optimization
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

When publishing to the internal Agent Builder skills catalog, the folder is self-contained — ship `skills/cost-optimization/` as-is. No rename required; the frontmatter `name: cost-optimization` is the canonical identifier.

Published display name: `AI Performance`

## What to expect

On first run the user sees:

1. `ai-cost.config.json` written to their repo (capture mode `metadata_only`, router default rules, shadow-mode enabled)
2. `.kostai/` directory with demo ledger seeded
3. `deliverables/demo-<date>/PROOF.md` — the one-pager showing ~92% cost reduction on the ten-question demo workload
4. A short summary of three next steps (typically: run `optimize`, review `.kostai/optimizations.md`, apply top-three patches)
5. Optional: `deliverables/elastic-pilot-<date>/FEEDBACK.md` if `scripts/feedback.sh` is run

Full runtime cost of the install: zero frontier-model calls. The install step is pure config + local scan.
