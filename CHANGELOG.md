# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] — 2026-04-22

### Fixed

- `cost-optimization/scripts/feedback.sh`, `proof.sh`, `ask.sh` — bash 3.2 empty-array crash: all `${ARRAY[@]}` expansions guarded with `${ARRAY[@]+"${ARRAY[@]}"}` pattern
- `elasticjudge/scripts/explain.sh`, `score.sh`, `judge.sh` — bash 3.2 `AUTH_HEADER` variable expansion bug fixed
- `scripts/provision.sh` — JSON encoding rewritten as pure-bash `json_str()` helper, removing `python3` dependency

### Changed

- `scripts/demo.sh`, `scripts/install.sh`, `scripts/optimize.sh`, `scripts/proof.sh`, `docs/install-message.md` — corrected stale `kostai` command references (`install`→`init`, `pitch`→`demo` workflow, `proof`→`report`, `optimize`→`scan`)

### Added

- `--help|-h` flag added to `proof.sh`, `feedback.sh`, `ask.sh`, `provision.sh`
- `--check` flag added to both `update.sh` scripts (cost-optimization and brainofbrains)
- CI: node 18/20/22 matrix added to `pulser` job; top-level `permissions: read-all`
- `.editorconfig` — editor normalisation (indent style, charset, trailing newline)
- `SECURITY.md` — vulnerability disclosure policy
- `CONTRIBUTING.md` — contributor guide and PR conventions
- `.github/ISSUE_TEMPLATE/` — bug-report and feature-request templates
- `.github/pull_request_template.md` — PR checklist template
- `scripts/test-integration.sh` — 4-group integration test suite
- `scripts/test-skill-triggers.sh` — `claude -p` intent-matching harness for trigger-phrase validation
- `docs/ux-flow.md` — first-time install walkthrough and per-skill workflow reference
- `examples/test-prompts.md` — trigger phrases and should-NOT-trigger list for all three skills
- All three `SKILL.md` files reach 100/100 Pulser score; all shell scripts pass `bash -n` and `shellcheck -S warning`

## [0.2.0] — 2026-04-22

### Fixed

- `scripts/install.sh` — `kostai install` command replaced with `kostai init`
- `scripts/demo.sh` — `kostai pitch` replaced with `kostai init` + `kostai scan` + `kostai report` workflow
- `scripts/proof.sh` — `kostai proof` replaced with `kostai report`
- `scripts/optimize.sh` — `kostai optimize` replaced with `kostai scan`
- All reference docs and SKILL.md — stale command names replaced throughout
- README clone URLs updated from `cost-optimization-skill` to `ai-performance-skills`

### Added

- `Makefile` with `install-all`, `check`, `update-all`, `help` targets
- `scripts/install-all.sh` — one-command installer for all three skills
- `.github/workflows/ci.yml` — bash lint + frontmatter validation CI
- `references/capabilities.md` — "Available CLI Commands (v0.5.1)" table
- `references/evaluation-axes.md` — concrete 0/2/3/5 scoring examples per axis

## [0.1.0] — 2026-04-22

Initial release of the AI Performance Skills suite.

### Added

- `brainofbrains` skill — agent-to-agent orchestration layer with three-tier compute pipeline routing
- `elasticjudge` skill — judge-first evaluation kernel for AI-generated artifacts

---

[0.2.0]: https://github.com/CrunchyJohnHaven/ai-performance-skills/compare/v0.1.0...v0.2.0
