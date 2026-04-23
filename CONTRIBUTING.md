# Contributing

This project is MIT-licensed and PRs are welcome for any of the three skills (cost-optimization, brainofbrains, elasticjudge). Fork it, improve it, and open a pull request — no CLA required.

---

## Development setup

```bash
# Clone the repo
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git
cd ai-performance-skills

# Run the fast syntax check suite
make check

# Run the same syntax check via the lint alias
make lint

# Run the Pulser quality score (no animation output)
npx pulser-cli . --no-anim
```

---

## Testing before you push

Work through all four steps before opening a PR:

1. **Syntax-check every shell script.**
   ```bash
   bash -n {cost-optimization,brainofbrains,elasticjudge}/scripts/*.sh scripts/*.sh
   ```
   Zero output means zero syntax errors.

2. **Run ShellCheck.**
   ```bash
   shellcheck {cost-optimization,brainofbrains,elasticjudge}/scripts/*.sh scripts/*.sh
   ```
   Fix any warnings before pushing. SC2086 / SC2046 (quoting) are the most common.

3. **Confirm Pulser score is 100/100.**
   ```bash
   npx pulser-cli . --no-anim
   ```
   A score below 100 blocks merge.

4. **Run the smoke test** from the repo root or by pointing at the bundled script directly.
   ```bash
   make smoke-test
   # or:
   bash cost-optimization/scripts/smoke-test.sh
   ```
   The smoke test checks CLI availability, optional `ai-cost.config.json`, `doctor`, `scan`, `demo.sh`, and `--help` coverage for `proof.sh` and `feedback.sh`. It does not validate install, optimize, or proof end-to-end.

---

## Adding a new skill

Every skill added to this repo must follow the five rules from [AGENTS.md](./AGENTS.md):

1. **Self-contained.** The skill lives entirely inside its own directory (`skillname/`). No cross-skill imports. If you need cross-skill behavior, expose it as a documented contract in `SKILL.md`, not a hidden dependency.
2. **No telemetry by default.** Do not add automatic background reporting, silent uploads, or recurring sends. Any share-back feature must be opt-in and triggered explicitly by the user (e.g. `scripts/feedback.sh`).
3. **No MCP by default.** If the skill needs MCP, it must ask the user at install time. The user can decline and the core skill must still work.
4. **Aggregate-only share-back.** If the skill generates a share-back payload, that payload may only contain aggregate metrics (totals, counts, technique breakdown). It must never contain prompt bodies, response bodies, filenames, repo names, or raw per-call logs.
5. **Measured / Modeled / Needs verification labels on every numeric claim.** Every number that appears in a user-facing artifact (SKILL.md, proof output, README) must be tagged with one of these three labels. No unattributed claims.

New skills also need:
- A `SKILL.md` at `skillname/SKILL.md` (the catalog description Claude consumes)
- A `scripts/` directory with at minimum `install.sh`
- An entry in the root `README.md` skills table
- A `CHANGELOG.md` update when the change is user-visible or release-note-worthy

---

## Updating CLI command references

Before changing any command reference in a `SKILL.md`, script, or README, verify against the live CLI:

```bash
npx --yes @sapperjohn/kostai --help
```

Only document flags and subcommands that appear in the `--help` output. Do not guess, do not document flags from memory, and do not copy flags from an older version without re-verifying. If a flag is absent from `--help`, it does not belong in any user-facing file in this repo.

---

## Commit format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary>

<optional body — explain why, not what>
```

Allowed types: `fix`, `feat`, `docs`, `test`, `ci`

Examples:

```
fix(cost-optimization): correct --audience flag name after CLI update

feat(elasticjudge): add deck-level coherence check across slides

docs(brainofbrains): clarify three-tier pipeline routing rules

test(cost-optimization): add smoke-test coverage for proof --format json

ci: pin shellcheck to v0.9.0 for reproducible lint
```

Keep the summary line under 72 characters. The body is optional but encouraged when the reason for the change is not obvious from the diff.
