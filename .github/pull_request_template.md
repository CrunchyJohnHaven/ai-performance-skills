## What does this PR do?

<!-- One paragraph. What changed and why? Link to the issue this closes if applicable. -->

---

## Checklist

- [ ] `bash -n` passes on all modified scripts
- [ ] ShellCheck clean (`shellcheck {cost-optimization,brainofbrains,elasticjudge}/scripts/*.sh scripts/*.sh`)
- [ ] Pulser 100/100 (`npx pulser-cli . --no-anim`)
- [ ] Smoke test passes if applicable (`make smoke-test` or `bash cost-optimization/scripts/smoke-test.sh`)
- [ ] `SKILL.md` references updated if any scripts changed
- [ ] `CHANGELOG.md` updated, or not needed is explained

---

## Test evidence

Paste the output of `make check` and `npx pulser-cli . --no-anim` below.

### `make check`

```

```

### `npx pulser-cli . --no-anim`

```

```
