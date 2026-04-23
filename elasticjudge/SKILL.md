---
name: elasticjudge
description: Use when the user says "judge this", "grade this deck", "is this Elastic-accurate", "check for AI slop", "evaluate this deliverable", "quality check this", "fit-for-CIO review", "brand voice check", "is this ready to send", "run this through the judge", or "elasticjudge". Calls the ElasticJudge API to return a structured verdict (pass / needs-revision / reject) with per-axis scores and line-level critiques.
version: 0.1.0
allowed-tools: Bash
when_to_use: "Use when the user has an AI-generated artifact (memo, deck, email, slide) ready to be graded before sending."
---

# Quality Judge

User-facing catalog label: `Quality Judge`.

Catch AI slop before it lands in a human-facing deliverable. Grade memos, decks, emails, and account plans for factual correctness, Elastic-domain accuracy, brand voice, exec-readiness, and safety. Lead with employee benefit: better output quality, fewer embarrassing sends, faster reviewer trust. Target: a structured verdict a calling agent or employee can act on in under 60 seconds.

## When to use

Trigger this skill when the user expresses any of:
- pre-send quality gate — "is this ready to send", "quality check this", "fit-for-CIO review", "before I send this to the customer"
- Elastic accuracy concern — "is this Elastic-accurate", "does this describe our products right", "brand voice check"
- AI-slop detection — "check for AI slop", "does this sound AI-generated", "catch the hallucinations"
- grading intent — "judge this", "grade this deck", "evaluate this deliverable", "run this through the judge", "elasticjudge"
- shadow-mode evaluation — "use this as the quality evaluator" (when paired with a cost-optimization A/B run)
- setup intent — "install elasticjudge", "set up the judge skill"

Do not trigger on unrelated evaluation questions (code review, unit test pass/fail, static analysis). This skill only addresses quality grading of human-facing AI-generated prose, decks, or account-facing artifacts.

## What this skill does

The skill delegates to the hosted ElasticJudge API at `https://elasticjudge.com/`. The judge is cloud-hosted and non-local — this skill is an orientation layer that knows how to prepare input, attempt the call, and interpret the response. It does not grade locally and does not attempt to replace the judge's domain knowledge. Verify the current endpoint and auth requirements at `https://elasticjudge.com/` before depending on the live API.

The judge returns, for any submitted artifact:
- a **verdict** — `pass` / `needs-revision` / `reject` with one-sentence reasoning
- a **score per axis** — factual correctness, Elastic-domain accuracy, brand voice, exec-readiness, safety (each 0-5)
- **line-level critiques** — specific sentences or blocks with a reason code a downstream agent can act on

The calling agent (or the employee) reads the verdict and decides whether to revise, rebuild, or ship. The judge never edits the artifact directly.

Evaluation axis definitions are in `references/evaluation-axes.md`. The subset of the Elastic business the judge weighs heavily is summarized in `references/elastic-knowledge.md`. How to defend a verdict to a reviewer is in `references/verification.md`. Elastic-specific deployment notes are in `references/elastic-notes.md`.

## Workflow

Execute steps in order. Each step is a single curl call wrapped by a script in `scripts/`. Read the script before invoking if the user has non-default config.

### 1. Prepare the artifact

Gather the exact text that will be sent to the human. For a markdown memo or email, pass the file path. For a PPTX or DOCX, export the text content first (the judge grades text, not visual layout). For a deck slide-by-slide, submit one slide at a time and keep the verdicts keyed by slide index.

Do not submit anything with customer PII, unreleased pricing, or embargoed security material. The judge API sees the text submitted to it — nothing else leaves the user's machine, but what is submitted is what the judge sees. The data-egress posture is documented below.

### 2. Submit

Run `scripts/judge.sh <file>` to submit an artifact for a full verdict, or `scripts/judge.sh --text "<inline>"` to submit a short inline string. The script:
- reads the artifact
- POSTs it to the ElasticJudge API
- writes the verdict JSON and a markdown summary under `deliverables/<audience>-<date>/JUDGE.md`

Accepts `--audience <name>` and `--date <date>` flags to match the repo's deliverables convention. Default audience is `judge-run`, default date is today.

For a lighter, CI-friendly variant that returns just the numeric scores as JSON (no markdown, no line-level critique), run `scripts/score.sh <file>`. Useful in a shadow-mode A/B pipeline where the only question is whether a cheaper model's output scored at or above the baseline.

### 3. Interpret

Read the verdict. The three outcomes:
- **pass** — ship as-is; no axis scored below 3; no safety flags
- **needs-revision** — fixable; one or more axes scored 2 or below, or a targeted line-level critique is surfaced
- **reject** — do not ship; a safety flag fired, or factual correctness scored 0-1

For `needs-revision`, run `scripts/explain.sh <verdict.json>` to retrieve line-level critiques with explicit reason codes. The calling agent can apply the critiques one-by-one and resubmit. Treat same-input reproducibility as the target behavior, but verify current endpoint behavior against the live API before relying on strict determinism in a stakeholder-facing claim.

### 4. Revise (calling-agent responsibility)

The judge surfaces critiques but does not auto-edit. The calling Claude agent reads the line-level critiques, applies them one at a time, and resubmits. Do not batch-apply revisions — one critique per edit so the per-axis score delta is attributable.

When a revision is applied, log the before/after pair. Over time the paired log becomes a regression corpus for measuring whether the judge's axes are drifting.

### 5. Update the skill (optional)

Run `scripts/update.sh` when the skill was installed from npm or copied into a local skills directory and a refresh is needed. The update path:
- refreshes the globally installed judge-adjacent tooling if present
- preserves symlink installs automatically
- refreshes copied skill folders when they live outside a git worktree
- avoids mutating a checked-out repo skill folder unless the operator chooses to re-copy manually

This matches the update posture of the `cost-optimization` skill.

## Evaluation axes

The judge scores five axes, each 0-5. Full rubric in `references/evaluation-axes.md`. Summary:

- **Factual correctness** — claims match external reality; no fabricated quotes, numbers, or citations
- **Elastic-domain accuracy** — product names, architectures, deployment options, partnership model, and personas match Elastic's public material
- **Brand voice** — aligns with the Elastic 2025 brand (official colors, fonts, tone); no custom palettes; no banned phrases
- **Exec-readiness** — Measured / Modeled / Needs-verification label on every numeric claim; no hand-waving; the ask is small; the recommendation is explicit
- **Safety** — no surveillance language, no banned phrases ("emergency", "obvious", "golden ticket", outside-offer references, compensation language), no customer PII leaking

A verdict of `pass` requires every axis at 3 or above and no safety flag. `needs-revision` is fixable. `reject` is a safety fire.

## Safety and data posture

- The judge API sees the text submitted to it. The skill does not silently submit surrounding files, repo metadata, or prompt history. Only the artifact passed to `scripts/judge.sh` is sent.
- No data is persisted server-side beyond what the ElasticJudge operator documents at https://elasticjudge.com/. The skill stores the verdict JSON locally under `deliverables/<audience>-<date>/`; that directory is the only local side effect.
- No secrets are persisted in the verdict file. The judge returns scores and critique text, not the original submitted body.
- No MCP server is installed by default. MCP carries a token tax and reads as surveillance; default is off. Users can opt into deeper integrations via a separate manual step if and when the operator publishes one.
- No background telemetry is sent. The skill is manually invoked per artifact.
- The judge is read-only on the artifact. It evaluates; it does NOT auto-edit. Any revision is surfaced as a suggestion the calling agent chooses to apply.

Before submitting an artifact that might contain customer PII, unreleased pricing, or embargoed security material, stop and confirm with the user. The judge endpoint is not an approved processor for every class of sensitive data; scope that question to the user's org policy, not to the skill.

## Escalation and fallback

If a call fails, the script emits the HTTP status and response body verbatim. Report the error to the user and fall back to:
- `scripts/judge.sh --help` — full invocation surface
- manual curl against `https://elasticjudge.com/` (endpoint paths are documented at the live API docs; see `references/verification.md`)
- submit a shorter excerpt to narrow the failure

Never fabricate a verdict. If the endpoint is down, say so and stop — do not simulate a score.

## Bundled resources

Scripts (`scripts/`):
- `judge.sh` — submit an artifact for a full verdict (markdown + JSON output)
- `score.sh` — lighter variant returning just the numeric per-axis scores
- `explain.sh` — re-run a prior verdict with `?explain=1` for line-level critiques
- `update.sh` — refresh the shipped skill from the latest published package

References (`references/`):
- `evaluation-axes.md` — scoring rubric, axis definitions, 0-5 descriptors
- `elastic-knowledge.md` — the Elastic business the judge grades against
- `verification.md` — how to read a verdict and defend it to a reviewer
- `elastic-notes.md` — Elastic Agent Builder integration + 2026-04-22 CIO meeting commitments

Assets (`assets/`):
- `install-message.md` — copy-paste bootstrap message for Claude Code or Codex

Agent metadata (`agents/`):
- `openai.yaml` — catalog-facing display name, short description, and default prompt metadata

## Gotchas

1. The ElasticJudge API at `https://elasticjudge.com/` must be reachable — if it returns non-200, the verdict is unavailable, not "pass".
2. The judge grades text content only — export PPTX/DOCX to text before submitting; layout and visual formatting are not evaluated.
3. Do not submit artifacts containing customer PII, unreleased pricing, or embargoed security material — the text is sent to a cloud API.
4. Treat reproducibility as something to verify against the live endpoint, not as a contractual guarantee. Fix the text, then resubmit.
5. Do not trigger on code review, unit test pass/fail, or static analysis tasks — this skill only grades human-facing AI-generated prose.

## Quick reference

> **API availability note:** the judge API is cloud-hosted at `https://elasticjudge.com/`.
> All calls below require the site to be live. If the endpoint is not yet published,
> every script will exit with an HTTP error and a hint. Check `https://elasticjudge.com/`
> for current status before filing a bug against the skill itself.
> Override the base URL with `ELASTICJUDGE_URL=<url>` if you have a staging endpoint.

```bash
# Full workflow (from the target repo's root)
scripts/judge.sh docs/MEMO.md                          # full verdict; writes deliverables/judge-run-<today>/JUDGE.md + verdict.json
scripts/judge.sh --audience adnan-cio --date 2026-04-22 docs/MEMO.md   # named deliverables folder
scripts/judge.sh --text "Elastic is the world's leading..."             # inline string

# Lighter variants
scripts/score.sh docs/MEMO.md                          # numeric scores only, printed to stdout (CI use)
scripts/score.sh --out scores.json docs/MEMO.md        # also write scores to a file
scripts/explain.sh deliverables/judge-run-2026-04-22/verdict.json  # line-level critiques; writes critiques.json alongside

# Lifecycle
scripts/update.sh                                      # refresh installed skill files (npm/bun/pnpm/yarn)
```

## Pass-through pricing note

The ElasticJudge cloud API pricing is governed at https://elasticjudge.com/ — this skill does not quote rates. If the user asks "what does this cost per call?", point at the live pricing page rather than hard-coding a number. Cost-per-verdict belongs to the API operator, not to the skill.
