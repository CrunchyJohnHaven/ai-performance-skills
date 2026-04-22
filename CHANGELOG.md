# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
