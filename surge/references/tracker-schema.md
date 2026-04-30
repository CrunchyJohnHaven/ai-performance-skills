# SURGE tracker schema

The SURGE tracker exists to answer five questions for every deliverable:

1. What are we producing?
2. By when?
3. How many pages or slides?
4. Who is the audience?
5. What format is the artifact?

The canonical JSON shape is:

```json
{
  "version": 1,
  "updatedAt": "2026-04-23T00:00:00.000Z",
  "items": [
    {
      "id": "aubree-doi-palo-alto-splunk-2-pager",
      "priority": "P0",
      "what": "Aubree DOI Palo Alto + Splunk 2-pager",
      "byWhen": "2026-04-23",
      "pages": "2",
      "audience": "Aubree Narus; DOI CIO/CISO follow-on",
      "format": "2-page brief / PPTX+PDF",
      "owner": "John Bradley",
      "status": "needs Palo Alto validation",
      "source": "deliverables/ReadyToSend/aubree-public-sector-2026-04-23/Aubree_Public_Sector_Work_Packet.md",
      "notes": "Treat Palo Alto as telemetry input until the installed footprint is validated.",
      "updatedAt": "2026-04-23T00:00:00.000Z"
    }
  ]
}
```

## Rendering rules

- JSON is the source of truth.
- Markdown is the human-facing render.
- Sort rows by priority first, then by `what`.
- Use `TBD` for missing fields instead of empty strings.
- Keep `what` concrete enough to distinguish parallel assets.
- `pages` may be a page count (`2`), a slide count (`8 slides`), or a bounded text string like `~5 pages`.
- `format` should describe the actual send surface, not just the tool used to make it.

## Missing-field policy

Do not fabricate missing information.

If a row is missing any of the five canonical fields, write `TBD` and let the row appear in the `Missing-field queue` section of `deliverables/SURGE_TRACKER.md`.

Expected acceptable examples:
- `byWhen: "TBD"`
- `pages: "TBD"`
- `audience: "TBD"`
- `format: "TBD"`

Unacceptable examples:
- silently omitting the field
- inventing a due date from directory structure
- collapsing multiple deliverables into one vague row

## Discovery inbox contract

`deliverables/SURGE_DISCOVERY.md` is not canonical state. It is a staging surface containing:
- build-packet and deliverable candidates
- due and status hints
- the source path for each hint

Promote only confirmed rows from the discovery inbox into the canonical tracker.
