# Elastic Notes

Context and deployment posture for the Quality Judge skill inside Elastic-style enterprise environments and the Agent Builder skills catalog.

## Packaging decision

This skill is packaged as a Claude skill — voluntary install, no MCP server running by default, no new product line. Rationale is the same as the other two skills in the suite: voluntary catalog distribution wins over top-down mandates; default-MCP reads as surveillance; an evaluation service is in-strategy for an infra-heritage company only as a skill, not as a product SKU.

The three-skill framing:

- **cost-optimization (KostAI)** — generates savings
- **brainofbrains (orchestration)** — coordinates multi-agent work
- **elasticjudge (this skill)** — the shared quality evaluator across both

The Quality Judge skill is intended to be cloud-hosted — not a local runtime. The local skill is the wrapper and orientation layer around that service. Verify the current endpoint and auth posture at https://elasticjudge.com/ before depending on the live API. Its value is expert evaluation of AI-generated output against the Elastic business (and similar enterprise software businesses).

Framing for employees:

- Lead with **employee benefit** (better output quality, fewer embarrassing sends, faster reviewer trust)
- Not with surveillance framing ("we will check everything you produce")
- Goodwill / open-source framing plays well inside infra-heritage organizations

## Distribution channels

Three channels, same skill folder:

1. **npm package** — the ElasticJudge publisher (see https://github.com/CrunchyJohnHaven/ElasticJudge) can ship this skill folder under `skills/elasticjudge/`. Employees symlink into `~/.claude/skills/elasticjudge/` or drop the folder there directly.
2. **Agent Builder catalog** — publish the skill folder to the internal catalog. Employees install via whatever UX the catalog exposes for skill install.
3. **Public GitHub** — open-source at https://github.com/CrunchyJohnHaven/ai-performance-skills alongside the other two skills.

In this source repo the folder is `elasticjudge/`; packaged builds may export the same folder as `skills/elasticjudge/`.

## Skill install footprint

Zero runtime cost. When triggered:

- Reads SKILL.md into Claude context once
- May load a reference file on demand
- Attempts to delegate to the ElasticJudge cloud API via shell scripts

No always-on process. No background network calls. No MCP server. No surveillance surface. The default judge flow sends one POST to https://elasticjudge.com/ per submitted artifact; `scripts/explain.sh` may send a follow-on request with prior verdict data, and `scripts/update.sh` contacts package registries only when the operator explicitly runs it.

## What an employee sees on first invocation

1. One-sentence description ("catch AI slop before it lands in a human-facing deliverable")
2. One invoke step (`scripts/judge.sh path/to/artifact.md`)
3. One verdict artifact (`deliverables/<audience>-<date>/JUDGE.md`)
4. One clear data-egress statement (the judge API sees what is submitted; nothing else)

Do not start with rubric explanations. Do not start with axis-by-axis inventory. Lead with outcome.

## 2026-04-22 CIO meeting commitments

Source: Adnan CIO meeting 2026-04-22. Adnan endorsed the thesis. These are the confirmed commitments from that session.

**Ship as Claude skill for Agent Builder catalog.** The directive from the meeting was to package the judge as a Claude skill that drops into the Agent Builder catalog, not as a standalone product or MCP server. Distribution path: catalog install, voluntary, zero mandate.

**Judge is intended to be cloud-hosted at elasticjudge.com.** The grading engine is not local. `scripts/judge.sh` is a thin HTTP wrapper that attempts to POST the artifact to the hosted API and return a verdict JSON. Verify the current endpoint and auth posture at https://elasticjudge.com/ before relying on the live service.

**Grading is AI-slop detection, not surveillance.** The framing agreed in the meeting: the judge catches common AI-generated quality failures (factual drift, unsourced superlatives, persona mismatch, banned phrases) before the artifact reaches a human reviewer. The grading result goes to the employee, not to a manager dashboard. Nothing is auto-reported.

**Employee-benefit framing.** The agreed pitch to employees: "fewer embarrassing sends, faster reviewer trust." Do not lead with "the company wants to verify your output quality." Lead with the employee getting a better result with less rework. This framing was explicitly endorsed in the meeting as the right distribution posture for an infra-heritage organization.

## Agent Builder catalog metadata

- **Skill name:** Quality Judge
- **Version:** 0.1.0
- **Category:** Productivity / Exec Readiness
- **One-sentence pitch:** Catch AI slop before it lands in front of a human — the Quality Judge grades your AI-generated output for factual correctness, Elastic accuracy, brand voice, and exec-readiness in one command.
- **Short description:** Evaluates AI-generated output for factual correctness, Elastic accuracy, brand voice, and exec-readiness — catches AI slop before it lands in front of a human.
- **Trigger phrases:** "judge this", "grade this deck", "is this Elastic-accurate", "check for AI slop", "fit-for-CIO review", "brand voice check", "elasticjudge", "run the judge", "evaluate this artifact", "is this exec-ready"
- **Repo path:** source repo `elasticjudge/`; packaged builds may export `skills/elasticjudge/`
- **Install method:** catalog install (Agent Builder), source-repo copy, or package-backed install if the publisher ships one
- **Network egress:** user-invoked judge/explain requests to https://elasticjudge.com/ plus optional package-registry calls during `scripts/update.sh` — no background calls, no telemetry

## Update path

- npm-based installs update via `scripts/update.sh`
- symlink installs inherit the new global package version after the upstream package publishes an update
- copied skill folders outside git worktrees refresh in place via `scripts/update.sh`
- Agent Builder installs update by catalog republish rather than local scripting

## Feedback loop without surveillance

Default posture:
- no background telemetry
- no MCP requirement
- no automatic sends
- no server-side retention of artifact bodies beyond what the API operator documents at https://elasticjudge.com/

Opt-in posture:
- the employee manually runs `scripts/judge.sh` per artifact
- verdict JSON stays local under `deliverables/<audience>-<date>/`
- the employee chooses whether to share the verdict upward; the skill never auto-shares

## Posture for an enterprise rollout

1. Ship the Quality Judge alongside the other two skills in the three-skill suite.
2. Keep default-MCP off.
3. Keep every reproducibility claim labeled Measured / Modeled / Needs verification.
4. Route distribution through the internal catalog, not a new product line.

## What NOT to do on the rollout

- Do not install an MCP server by default.
- Do not frame the skill as "the company is grading your output."
- Do not request telemetry back to a central dashboard in v1. Local-first; network egress is limited to user-invoked judge/explain calls plus optional update traffic.
- Do not add any "internal only" slides to any exec-facing artifact.
- Do not claim unmeasured verdict reliability. Every reproducibility claim carries a Measured / Modeled / Needs verification label.
- Do not use second-person or "you should" language in SKILL.md or references. Imperative form only.
- Do not hard-code internal IPs or non-public URLs.
- Do not reimplement the judge locally. The judge is intended to be cloud-hosted — `scripts/judge.sh` is a thin HTTP wrapper.

## Success signal

The skill is working when:

1. An employee installs it and runs the judge on a real memo within a day of install
2. The verdict artifact lands under `deliverables/` with axis scores the employee trusts enough to act on
3. The employee revises an artifact in response to a `needs-revision` verdict and ships the revised version
4. A reviewer can follow the reproducibility stub, recover the original artifact or payload, and re-run the same call
5. Adoption grows through word-of-mouth rather than mandate

## Pairing with the other two skills

- **cost-optimization (KostAI)** — generates savings; the judge evaluates whether savings came at a quality cost
- **brainofbrains (orchestration)** — coordinates multi-agent work; the judge evaluates the artifacts the orchestrator produces
- **elasticjudge (this skill)** — the shared quality evaluator across both

The canonical shadow-mode A/B pattern: cost-optimization produces a cheaper optimized response, the Quality Judge grades it against the baseline, the pair is logged to prove savings did not degrade quality. Neither skill depends on the other, but the pair is the three-skill thesis.

## What the judge does NOT do

This section exists to answer the employee's first objection. Lead with this framing when rolling out the skill inside an organization.

**Does not auto-edit.** The judge returns a verdict with axis scores and a plain-English rationale. It does not rewrite the artifact. The employee decides whether and how to revise. No automated edits, no auto-replace, no silent modifications to any file.

**Does not store prompt bodies locally.** The artifact submitted to https://elasticjudge.com/ is handled according to the API operator's live data-retention policy. The skill itself performs no additional body storage beyond the local verdict artifacts it writes.

**Does not report to management.** The local verdict artifacts land under `deliverables/<audience>-<date>/` on the employee's machine (`JUDGE.md` plus `verdict.json`, and `critiques.json` when `scripts/explain.sh` is run). The skill never POSTs the verdict to a manager dashboard, a Slack channel, a ticketing system, or any other management surface. Sharing the verdict upward is a voluntary decision made by the employee, not a default behavior of the skill.

**Grading stays with the employee.** The score, the rationale, and the revision decision belong to the employee who ran the judge. No aggregate scoring, no leaderboard, no per-employee quality tracking in v1. Network egress is limited to the user-invoked judge/explain calls and any optional update traffic the employee chooses to run.

**Does not run unless manually invoked.** There is no background process, no file-watcher, no hook that triggers the judge automatically on save or commit. The employee runs `scripts/judge.sh path/to/artifact.md` explicitly, once, per artifact they choose to evaluate.
