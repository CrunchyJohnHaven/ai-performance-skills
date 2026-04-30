# SURGE workflow

SURGE works best as a short loop, not as a one-time setup.

## Operating loop

1. Run `scripts/install.sh` once per workspace.
2. Run `scripts/scan.sh` whenever the deliverables surface has drifted or new packets have landed.
3. Reconcile the discovery inbox into canonical rows with `scripts/surge.sh`.
4. Read `deliverables/SURGE_TRACKER.md` before planning the next wave of work.

## Recommended usage pattern

Use `scripts/scan.sh` first when the current state is fragmented.

Use `scripts/surge.sh` directly when the user has already told you the fields and the goal is to lock them into a durable tracker row.

Examples:

```bash
scripts/surge.sh \
  --priority P0 \
  --what "Dana Aerospace bounded working-session deck" \
  --by "2026-04-23" \
  --pages "7 slides" \
  --audience "Dana Pipia internal review; Aerospace follow-on" \
  --format "deck / PPTX+PDF" \
  --status "blocked on final canonical deck path"
```

```bash
scripts/surge.sh \
  --priority P0 \
  --what "IRS VE proposal perfection" \
  --by "TBD" \
  --pages "~5 pages" \
  --audience "Jen / Chris T internal review; IRS CISO with ops-safe framing" \
  --format "whitepaper / DOCX" \
  --status "needs perfection pass"
```

## Practical rule

If a meeting note knows the due date but the build packet knows the audience and page count, SURGE is the place where those facts get joined. Do not leave them stranded in separate artifacts.
