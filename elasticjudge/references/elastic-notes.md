# Elastic Notes

Context and deployment posture for the Quality Judge skill inside Elastic-style enterprise environments and the Agent Builder skills catalog.

## Packaging decision

This skill is packaged as a Claude skill — voluntary install, no MCP server running by default, no new product line. Rationale is the same as the other two skills in the suite: voluntary catalog distribution wins over top-down mandates; default-MCP reads as surveillance; an evaluation service is in-strategy for an infra-heritage company only as a skill, not as a product SKU.

The three-skill framing:

- **cost-optimization (KostAI)** — generates savings
- **brainofbrains (orchestration)** — coordinates multi-agent work
- **elasticjudge (this skill)** — the shared quality evaluator across both

The Quality Judge skill is cloud-based — not a local runtime. Its value is expert evaluation of AI-generated output against the Elastic business (and similar enterprise software businesses).

Framing for employees:

- Lead with **employee benefit** (better output quality, fewer embarrassing sends, faster reviewer trust)
- Not with surveillance framing ("we will check everything you produce")
- Goodwill / open-source framing plays well inside infra-heritage organizations

## Distribution channels

Three channels, same skill folder:

1. **npm package** — the ElasticJudge publisher (see https://github.com/CrunchyJohnHaven/ElasticJudge) can ship this skill folder under `skills/elasticjudge/`. Employees symlink into `~/.claude/skills/elasticjudge/` or drop the folder there directly.
2. **Agent Builder catalog** — publish the skill folder to the internal catalog. Employees install via whatever UX the catalog exposes for skill install.
3. **Public GitHub** — open-source at https://github.com/CrunchyJohnHaven/cost-optimization-skill alongside the other two skills.

All three channels pull from the same source of truth: `skills/elasticjudge/`.

## Skill install footprint

Zero runtime cost. When triggered:

- Reads SKILL.md into Claude context once
- May load a reference file on demand
- Delegates to the ElasticJudge cloud API via shell scripts

No always-on process. No background network calls other than the manually invoked curl. No MCP server. No surveillance surface. The skill's only network egress is the single POST to https://elasticjudge.com/ per submitted artifact.

## What an employee sees on first invocation

1. One-sentence description ("catch AI slop before it lands in a human-facing deliverable")
2. One invoke step (`scripts/judge.sh path/to/artifact.md`)
3. One verdict artifact (`deliverables/<audience>-<date>/JUDGE.md`)
4. One clear data-egress statement (the judge API sees what is submitted; nothing else)

Do not start with rubric explanations. Do not start with axis-by-axis inventory. Lead with outcome.

## Agent Builder catalog metadata

- **Skill name:** Quality Judge
- **Category:** Productivity / Exec Readiness
- **Short description:** Evaluates AI-generated output for factual correctness, Elastic accuracy, brand voice, and exec-readiness — catches AI slop before it lands in front of a human.
- **Trigger phrases:** "judge this", "grade this deck", "is this Elastic-accurate", "check for AI slop", "fit-for-CIO review", "brand voice check", "elasticjudge"
- **Repo path:** `skills/elasticjudge/`

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
- Do not request telemetry back to a central dashboard in v1. Local-first; the only network egress is the per-artifact POST to https://elasticjudge.com/.
- Do not add any "internal only" slides to any exec-facing artifact.
- Do not claim unmeasured verdict reliability. Every reproducibility claim carries a Measured / Modeled / Needs verification label.
- Do not use second-person or "you should" language in SKILL.md or references. Imperative form only.
- Do not hard-code internal IPs or non-public URLs.
- Do not reimplement the judge locally. The judge is cloud-based — `scripts/judge.sh` is a thin HTTP wrapper.

## Success signal

The skill is working when:

1. An employee installs it and runs the judge on a real memo within a day of install
2. The verdict artifact lands under `deliverables/` with axis scores the employee trusts enough to act on
3. The employee revises an artifact in response to a `needs-revision` verdict and ships the revised version
4. A reviewer can follow the reproducibility stub and re-run the same call
5. Adoption grows through word-of-mouth rather than mandate

## Pairing with the other two skills

- **cost-optimization (KostAI)** — generates savings; the judge evaluates whether savings came at a quality cost
- **brainofbrains (orchestration)** — coordinates multi-agent work; the judge evaluates the artifacts the orchestrator produces
- **elasticjudge (this skill)** — the shared quality evaluator across both

The canonical shadow-mode A/B pattern: cost-optimization produces a cheaper optimized response, the Quality Judge grades it against the baseline, the pair is logged to prove savings did not degrade quality. Neither skill depends on the other, but the pair is the three-skill thesis.
