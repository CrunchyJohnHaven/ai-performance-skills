# Copy-Paste Install Message

One-shot bootstrap for the `SURGE` skill. An employee pastes the block below into Claude Code or Codex and the workspace gets a canonical deliverables tracker plus a discovery inbox without needing to reconstruct the control plane by hand.

---

## For Claude Code or Codex users

Copy the block between the fences and paste into Claude Code or Codex as a single prompt:

```
Use the SURGE skill to fix deliverables tracking in this workspace.

Do the following in order:
1. Run `scripts/install.sh` to create `deliverables/SURGE_TRACKER.json`,
   `deliverables/SURGE_TRACKER.md`, and `deliverables/SURGE_DISCOVERY.md`
   if they do not already exist.
2. Run `scripts/scan.sh` so the discovery inbox reflects current build packets,
   send queues, and meeting-note tracker tables.
3. Reconcile the discovery inbox into canonical rows focused on these fields:
   what, by when, pages/slides, audience, and format.
4. Use `scripts/surge.sh` to add or update the highest-priority rows.
5. Show me the final `deliverables/SURGE_TRACKER.md` inline.
6. Call out which rows still have `TBD` fields and what needs clarification.

Do not install an MCP server. Do not send any data off my machine. Keep all
tracker files local to this repo. If a field is unclear, write `TBD` instead of
guessing.
```

## How to make the skill available

Claude Code auto-discovers skills from three locations. Pick one:

### Option A — Drop into user skills directory

```bash
cp -r /path/to/ai-performance-skills/skills/surge ~/.claude/skills/surge
```

Claude Code will pick up the skill on next session start.

### Option B — Use as a plugin skill

If the workspace is a Claude Code plugin, drop the folder under `skills/` in the plugin directory. Auto-discovered.

### Option C — Refresh from a local checkout or a package that actually ships the skill

```bash
SURGE_SOURCE_DIR=/path/to/ai-performance-skills/skills/surge scripts/update.sh
```

If you are using an npm package, verify it contains `skills/surge/` before symlinking from `node_modules`.

## For Elastic Agent Builder

When publishing to the internal Agent Builder skills catalog, the folder is self-contained — ship `skills/surge/` as-is. No rename required; the frontmatter `name: surge` is the canonical identifier.

Published display name: `SURGE`

## What to expect

On first run the user sees:

1. `deliverables/SURGE_TRACKER.json` — canonical machine-readable tracker
2. `deliverables/SURGE_TRACKER.md` — human-scannable tracker with a missing-field queue
3. `deliverables/SURGE_DISCOVERY.md` — discovery inbox built from current workspace notes
4. A short summary of which deliverables are still missing `by when`, `pages`, `audience`, or `format`

SURGE is local only. No network calls are required to initialize or maintain the tracker.
