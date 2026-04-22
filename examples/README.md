# Examples

This directory contains sample inputs you can run against the AI Performance Skills to see each one in action. The files here are intentionally imperfect — `sample-memo.md` is a fictional Elastic account plan that contains a vague unsourced benchmark claim ("over 60% based on industry benchmarks") and a minor brand voice issue (the phrase "AI-powered" without citing which Elastic product or capability). These subtle problems give `elasticjudge` something concrete to critique and let you see the judge return a meaningful `revise` verdict rather than a trivially clean `approve`.

To run each skill against the sample, use the wrapper scripts from the repo root. For `elasticjudge`, point the judge at the sample memo directly:

```bash
# Judge the sample memo for content, formatting, and persona
scripts/judge.sh examples/sample-memo.md

# Run the cost-optimization scan across the repo (no sample input required)
scripts/scan.sh

# Generate a proof-of-savings report after scanning
scripts/proof.sh --audience demo --date "$(date +%Y-%m-%d)"
```

Each command writes its output to stdout and, where applicable, drops a structured artifact into `deliverables/`. The judge script exits non-zero on a `rebuild` verdict, so it can be wired into CI as a quality gate.
