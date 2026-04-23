# Examples

This directory contains sample inputs and sample outputs that show the shape of each skill without requiring a live install first.

The examples are intentionally mixed:

- `sample-memo.md` is an intentionally flawed input for `elasticjudge`
- `sample-proof.md` is a sample proof artifact for `cost-optimization`
- `sample-scan.md` is a sample repo scan for `cost-optimization`
- `sample-brain-answer.md` is a sample routed answer for `brainofbrains`
- `test-prompts.md` is a quick trigger-phrase sheet

Use the wrapper scripts from the repo root when you want to compare the samples with live behavior in your own workspace.

## cost-optimization

```bash
cd /path/to/target-repo
/path/to/ai-performance-skills/cost-optimization/scripts/scan.sh
```

Expected result: stdout shaped similarly to `sample-scan.md`, with detected runtimes, flagged call sites, and recommended savings levers.

If the target repo already has ai-cost data:

```bash
cd /path/to/target-repo
/path/to/ai-performance-skills/cost-optimization/scripts/proof.sh --audience demo --date "$(date +%Y-%m-%d)"
```

Expected result: `deliverables/demo-<date>/PROOF.md`, structurally similar to `sample-proof.md`. Fresh repos with no captured calls will show a zero-call baseline instead of measured savings.

## brainofbrains

```bash
cd /path/to/target-workspace
/path/to/ai-performance-skills/brainofbrains/scripts/install.sh
/path/to/ai-performance-skills/brainofbrains/scripts/ask.sh "what changed this week?"
```

Expected result: `bin/brain` plus `evidence/brain/` appear in the target workspace, and the answer returned by `ask.sh` looks broadly like `sample-brain-answer.md`.

## elasticjudge

```bash
cd /path/to/target-workspace
export ELASTICJUDGE_API_KEY="<token-if-required>"
/path/to/ai-performance-skills/elasticjudge/scripts/judge.sh /path/to/ai-performance-skills/examples/sample-memo.md
```

Expected result: `deliverables/judge-run-<date>/JUDGE.md` and `verdict.json`. The live verdict should use the repo's current vocabulary: `pass`, `needs-revision`, or `reject`.

The judge script exits non-zero on invocation or HTTP failure. A non-`pass` verdict is still written to the output artifacts for review.
