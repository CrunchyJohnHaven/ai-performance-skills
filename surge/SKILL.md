---
name: surge
description: This skill should be used when the user asks "what do we need to do", "by when", "how many pages", "who is the audience", "what format is this", "what do I owe", "what's due", "deliverables tracking", "build me a tracker", "surge", or wants a single operating surface for executive decks, briefs, proposals, and internal send packets. Creates and maintains a canonical deliverables tracker so AI agents stop losing the what, due date, page count, audience, and format fields across scattered notes.
version: 0.1.0
---

# SURGE

User-facing catalog label: `SURGE`.

Create one operating surface for deliverables. The point is not "project management" in the abstract. The point is to stop losing the five fields that decide whether work ships: what we owe, by when, how many pages, who the audience is, and what format the asset should take.

## When to use

Trigger this skill when the user expresses any of:
- tracking pain — "what do we need to do", "what's due", "what do I owe", "what are the deliverables"
- field loss — "by when", "pages", "audience", "format", "I keep losing the brief"
- control-plane intent — "build me a tracker", "fix our deliverables tracking", "surge", "SURGE"
- handoff intent — "turn this scattered context into one send surface", "make this mergeable into a tracker"
- backlog triage — "what is blocked", "what is missing", "what still needs clarification"
- workspace bootstrap — "install SURGE", "add SURGE to Claude", "put this in our skill suite"

Do not trigger on generic issue-tracker or sprint-board requests. This skill is specifically for deliverables control: decks, one-pagers, briefs, proposals, send packets, and their required fields.

## What this skill does

The skill keeps three local artifacts in the workspace:
- `deliverables/SURGE_TRACKER.json` — canonical machine-readable tracker
- `deliverables/SURGE_TRACKER.md` — human-scannable tracker surface
- `deliverables/SURGE_DISCOVERY.md` — discovery inbox built from existing notes, build packets, and tracker tables

The skill does not replace the deck builders, brief builders, or send-pack flows already in the workspace. It is the control plane that sits above them and keeps the key fields from getting lost.

The tracker schema is in `references/tracker-schema.md`. The operating flow is in `references/workflow.md`. Elastic-specific rollout notes and the current motivating examples are in `references/elastic-notes.md`.

## Workflow

Execute steps in order.

### 1. Install

Run `scripts/install.sh` in the target workspace. This creates the canonical SURGE files if they do not already exist and leaves existing tracker state intact.

First install creates:
- `deliverables/SURGE_TRACKER.json`
- `deliverables/SURGE_TRACKER.md`
- `deliverables/SURGE_DISCOVERY.md`

The install step is local-only and does not inspect or upload repo contents.

### 2. Discover

Run `scripts/scan.sh` to build `deliverables/SURGE_DISCOVERY.md`. The discovery pass harvests candidate deliverables and due/status hints from:
- build packets
- deliverable README files
- meeting-note tracker tables
- send-queue surfaces

The discovery inbox is intentionally loose. It is a staging area, not the source of truth. The calling agent still needs to reconcile duplicates and missing fields before promoting anything into the canonical tracker.

### 3. Upsert

Run `scripts/surge.sh` with the confirmed fields to add or update one row in the canonical tracker.

Minimum useful call:

```bash
scripts/surge.sh \
  --what "Aubree DOI Palo Alto + Splunk 2-pager" \
  --by "2026-04-23" \
  --pages "2" \
  --audience "Aubree Narus; DOI CIO/CISO follow-on" \
  --format "2-page brief / PPTX+PDF"
```

Recommended fields for a real row:
- `--priority`
- `--what`
- `--by`
- `--pages`
- `--audience`
- `--format`
- `--owner`
- `--status`
- `--source`
- `--notes`

Every upsert rewrites both `deliverables/SURGE_TRACKER.json` and `deliverables/SURGE_TRACKER.md`. Missing or unknown fields are written as `TBD` instead of being dropped silently.

### 4. Triage

Read `deliverables/SURGE_TRACKER.md` and use the `Missing-field queue` section to identify what still needs clarification. The skill is working correctly when the missing information is explicit and concentrated instead of scattered across notes.

### 5. Update the skill (optional)

Run `scripts/update.sh` when the skill was installed from npm or copied into a local skills directory and a refresh is needed. The update path:
- refreshes from `SURGE_SOURCE_DIR` when the skill was copied from a local checkout
- refreshes the globally installed `@sapperjohn/kostai` package when that package ships `skills/surge`
- preserves symlink installs automatically
- refreshes copied skill folders when they live outside a git worktree
- avoids mutating a checked-out repo skill folder unless the operator chooses to re-copy manually

## What SURGE tracks

SURGE is opinionated. Every canonical row should answer these five questions:
- what are we producing
- by when
- how many pages or slides
- for whom
- in what format

Additional fields like owner, priority, status, notes, and source are welcome, but those five fields are the operating minimum.

## Safety and data posture

- No data leaves the user's machine. SURGE is local-file only.
- No MCP server is installed.
- No background process runs.
- No existing tracker file is overwritten during install. SURGE initializes missing files and then only mutates the canonical tracker when `scripts/surge.sh` is called explicitly.
- Discovery is read-only against the workspace. Promotion into the canonical tracker is an explicit upsert step.

## Escalation and fallback

If the discovery pass finds conflicting or partial data, do not guess. Promote the row with `TBD` placeholders and use the `notes` field to state what remains unclear.

If a script fails, report the error verbatim and fall back to:
- `scripts/install.sh --help`
- `scripts/scan.sh --help`
- `scripts/surge.sh --help`
- `scripts/update.sh`

Never silently drop page count, audience, or format just because the current source packet does not state them cleanly.

## Bundled resources

Scripts (`scripts/`):
- `install.sh` — initialize the canonical SURGE files in the workspace
- `scan.sh` — build `deliverables/SURGE_DISCOVERY.md` from existing notes and packets
- `surge.sh` — add or update one canonical deliverables row
- `update.sh` — refresh the shipped skill from a local source folder or the latest package that includes it

References (`references/`):
- `tracker-schema.md` — canonical row fields, missing-field policy, markdown rendering rules
- `workflow.md` — discovery-to-upsert operating flow and recommended use patterns
- `elastic-notes.md` — Elastic rollout framing plus the Aubree, Dana, IRS, and OMB motivating cases

Assets (`assets/`):
- `install-message.md` — copy-paste bootstrap message for Claude Code or Codex

Agent metadata (`agents/`):
- `openai.yaml` — catalog-facing display name, short description, and default prompt metadata

## Quick reference

```bash
# Initialize the canonical tracker surfaces
scripts/install.sh

# Discover candidate deliverables from the current workspace
scripts/scan.sh

# Add or update a canonical row
scripts/surge.sh \
  --priority P0 \
  --what "NYC OMB decision brief perfection" \
  --by "TBD" \
  --pages "8 slides" \
  --audience "NYC OMB" \
  --format "decision brief deck / PPTX+PDF" \
  --owner "John Bradley" \
  --status "needs perfection pass" \
  --source "deliverables/nyc-omb-2026-04-21/00 README.md"

# Refresh the installed skill
SURGE_SOURCE_DIR=/path/to/ai-performance-skills/skills/surge scripts/update.sh
```

## Naming note

If the user says "SURGE", treat that as both the skill name and the operating mode. The point is to create forward motion by collapsing scattered deliverables context into a single trackable surface.
