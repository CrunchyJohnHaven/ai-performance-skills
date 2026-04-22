# AGENTS.md

Instructions for any agent updating or publishing this public skill repository.

## What this repo is

This repo is the standalone public bundle for the `AI Performance` skill. Keep it small and opinionated:

- `SKILL.md`
- `agents/openai.yaml`
- `assets/`
- `references/`
- `scripts/`
- `README.md`
- `AGENTS.md`
- `LICENSE`
- `.gitignore`

Do not turn this into the full `AICost` product repo.

## Hard rules

- Keep the skill local-first.
- Do not add automatic telemetry, background reporting, or MCP-by-default behavior.
- Keep “Share Results” opt-in only via `scripts/feedback.sh`.
- Do not include prompt bodies, response bodies, filenames, repo names, or raw per-call logs in any share-back payload.
- Keep the user-facing label `AI Performance` unless the owner explicitly changes rollout naming.

## Update checklist

Run this checklist before every push:

1. Update the skill files that changed.
2. If `SKILL.md` changed, regenerate or validate `agents/openai.yaml`.
3. Run `bash -n {cost-optimization,brainofbrains,elasticjudge}/scripts/*.sh`.
4. Re-read `README.md` and make sure install, update, and share instructions still match the scripts.
5. Confirm the share-back path is still opt-in and aggregate-only.
6. Run `git status` and verify the diff only contains intended public skill files.
7. Commit with a clear message.
8. Push to `origin/main`.

## Push workflow

Standard publish flow:

```bash
git status
bash -n {cost-optimization,brainofbrains,elasticjudge}/scripts/*.sh
make check
git add .
git commit -m "Update AI Performance skill"
git push origin main
```

## Command verification

Before updating any SKILL.md or script, verify commands against the live CLI with:

```bash
npx @sapperjohn/kostai --help
```

This confirms command names, flags, and subcommands match what the published CLI actually exposes. Do not document flags or subcommands that are absent from `--help` output.

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

When this repo is maintained alongside the private `AICost` workspace, the skill bundle usually originates from `skills/cost-optimization/` there. When that upstream is unavailable, edit this repo directly and keep the structure stable.
