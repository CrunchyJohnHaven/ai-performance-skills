# AGENTS.md

Instructions for any agent updating or publishing this public skill repository.

## What this repo is

This repo is the standalone public bundle for the three-skill `AI Performance Skills` suite. Keep it small and opinionated:

- `cost-optimization/`
- `brainofbrains/`
- `elasticjudge/`
- top-level `scripts/`
- top-level `docs/`
- top-level `examples/`
- `README.md`
- `AGENTS.md`
- `CHANGELOG.md`
- `LICENSE`
- `.gitignore`

Do not turn this into the full `AICost` product repo.

## Hard rules

- Keep the suite local-first.
- Do not add automatic telemetry, background reporting, or MCP-by-default behavior.
- Keep “Share Results” opt-in only via `scripts/feedback.sh`.
- Do not include prompt bodies, response bodies, filenames, repo names, or raw per-call logs in any share-back payload.
- Keep the shipped user-facing labels stable unless the owner explicitly changes rollout naming.

## Update checklist

Run this checklist before every push:

1. Update the skill files that changed.
2. If `SKILL.md` changed, regenerate or validate the corresponding `<skill>/agents/openai.yaml`.
3. Run `bash -n {cost-optimization,brainofbrains,elasticjudge}/scripts/*.sh scripts/*.sh`.
4. Run `shellcheck -S warning {cost-optimization,brainofbrains,elasticjudge}/scripts/*.sh scripts/*.sh`.
5. Run `npx --yes pulser-cli . --format json --no-anim --strict`.
6. Re-read `README.md` and make sure install, update, and share instructions still match the scripts.
7. Confirm the share-back path is still opt-in and aggregate-only.
8. Run `git status` and verify the diff only contains intended public skill files.
9. Commit with a clear message.
10. Push your branch; maintainers with direct access may push to `origin/main`.

## Push workflow

Maintainer publish flow (for operators with direct `main` access):

```bash
git status
bash -n {cost-optimization,brainofbrains,elasticjudge}/scripts/*.sh scripts/*.sh
shellcheck -S warning {cost-optimization,brainofbrains,elasticjudge}/scripts/*.sh scripts/*.sh
make check
npx --yes pulser-cli . --format json --no-anim --strict
git add .
git commit -m "Update AI Performance skill"
git push origin main
```

For outside contributors, use the same validation steps on a branch and open a PR instead of pushing directly to `main`.

## Command verification

Before updating any `cost-optimization` command reference in a `SKILL.md`, script, or README, verify against the live CLI with:

```bash
npx --yes @sapperjohn/kostai --help
```

This confirms command names, flags, and subcommands match what the published CLI actually exposes. Do not document flags or subcommands that are absent from `--help` output.

For `brainofbrains` and `elasticjudge`, verify against the shipped help surfaces instead of `kostai`:

```bash
bin/brain --help
bash elasticjudge/scripts/judge.sh --help
```

The current published version is **kostai v0.5.1**. Commands that exist as of this version:

- `init` — initialize a new KostAI project
- `scan` — scan for AI cost data in the current workspace
- `report` — generate a cost report
- `export` — export report data (markdown, HTML, JSON)
- `doctor` — diagnose configuration and environment issues
- `compare` — compare two scan results or time ranges
- `evidence` — manage the evidence store
- `compress` — compress evidence or report artifacts
- `dashboard` — launch the local dashboard UI

## Share-back posture

Allowed:
- `scripts/feedback.sh` generating `FEEDBACK.md`, `SLACK.md`, and `feedback.json`
- aggregate savings, token, and quality metrics
- manual user-controlled sharing

Not allowed:
- silent uploads
- recurring background sends
- central collection of raw events
- employee-monitoring language

## Source-of-truth note

When this repo is maintained alongside the private `AICost` workspace, the public bundle usually originates from the corresponding folders under `skills/` there. When that upstream is unavailable, edit this repo directly and keep the structure stable.
