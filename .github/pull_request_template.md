## What does this PR do?

<!-- One paragraph. What changed and why? Link to the issue this closes if applicable. -->

---

## Checklist

- [ ] `bash -n` passes on all modified scripts
- [ ] ShellCheck clean (`shellcheck {cost-optimization,brainofbrains,elasticjudge}/scripts/*.sh scripts/*.sh`)
- [ ] Pulser strict passes (`npx --yes pulser-cli . --format json --no-anim --strict`)
- [ ] Smoke test passes if applicable (`make smoke-test` or `bash cost-optimization/scripts/smoke-test.sh`)
- [ ] `SKILL.md` references updated if any scripts changed
- [ ] `CHANGELOG.md` updated, or not needed is explained

---

## Test evidence

Paste the output of `make check` and `npx --yes pulser-cli . --format json --no-anim --strict` below.

### `make check`

```

```

### `npx --yes pulser-cli . --format json --no-anim --strict`

```

```
