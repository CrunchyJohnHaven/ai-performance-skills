# User Experience Flows

These are Claude Code example flows. The same skill folders can be used in other local skill catalogs, but the interaction language below assumes Claude Code.

## First-time install

1. Open terminal in any repo
2. Run: `git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git && cd ai-performance-skills && bash scripts/install-all.sh`
3. Open a new Claude Code session if the skills do not appear immediately
4. Type: "lower my AI bill" to trigger `cost-optimization` (`AI Performance`)

## Cost-optimization workflow (5 minutes)

**Step 1 — trigger**
User types "lower my AI bill" or "am I wasting tokens on Claude Code?" in a Claude Code session.
Claude responds: "I'll run the `cost-optimization` skill (`AI Performance`) to scan your workspace and identify savings opportunities."

**Step 2 — scan**
Claude runs `~/.claude/skills/cost-optimization/scripts/scan.sh`.
User sees: detected local runtimes, flagged LLM call sites, and the files most likely to benefit from cheaper routing or prompt cleanup.

**Step 3 — recommend**
Claude reads the scan output and identifies the top optimization opportunities: prompt caching, prose compression, and model downgrade where quality can be preserved.
User sees: a short list of recommended techniques plus the call sites they apply to. Any source-code edit is proposed for approval before it is applied.

**Step 4 — proof**
If the workspace already has ai-cost comparison data, Claude runs `~/.claude/skills/cost-optimization/scripts/proof.sh`.
User sees: a `PROOF.md` under `deliverables/<audience>-<date>/` with Measured / Modeled / Needs verification labels. If the repo has no data yet, Claude explains that the first proof will be a baseline until real usage lands in `.ai-cost-data/`.

**Step 5 — share (optional)**
User says "I want to share the results with my manager."
Claude runs `~/.claude/skills/cost-optimization/scripts/feedback.sh --audience manager` and produces `FEEDBACK.md`, `SLACK.md`, and `feedback.json` locally.
User sees: paste-ready summary files. No data leaves the machine automatically.

## BrainOfBrains workflow (first-time setup)

**Step 1 — trigger**
User types "install brains into this workspace" or "ask the expert brain about Jesse's priorities."
Claude responds: "I'll bootstrap the BrainOfBrains substrate locally and then route a question through it."

**Step 2 — install**
Claude runs `~/.claude/skills/brainofbrains/scripts/install.sh`.
User sees: `bin/brain` plus `evidence/brain/` created in the target workspace.

**Step 3 — first tick**
Claude runs `bin/brain tick` to populate closets and compute the initial BIV score.
User sees: tick output with BIV score and per-brain status (`in-band`, `breach`, `awaiting-data`).

**Step 4 — first query**
User types "what does Jesse care about this quarter?"
Claude runs `~/.claude/skills/brainofbrains/scripts/ask.sh "what does Jesse care about this quarter?"`.
User sees: a plain-English answer and the L0/L1/L2 source layers it was drawn from.

**Step 5 — verify**
Claude runs `~/.claude/skills/brainofbrains/scripts/health.sh`.
User sees: a local PASS/FAIL health table with the last-tick timestamp. Remote health checks are only used if the operator explicitly adds `--remote`.

## ElasticJudge workflow (grade a memo)

**Step 1 — trigger**
User types "judge this memo before I send it" or pastes a file path and says "is this Elastic-accurate?"
Claude responds: "I'll submit this to ElasticJudge. Confirm the content is approved for external submission first."

**Step 2 — submit**
Claude runs `~/.claude/skills/elasticjudge/scripts/judge.sh docs/MEMO.md` or `~/.claude/skills/elasticjudge/scripts/judge.sh --text "<inline>"`.
User sees: a progress indicator while the request is sent to the ElasticJudge API.

**Step 3 — verdict**
Claude presents the verdict: `pass`, `needs-revision`, or `reject`, along with the five per-axis scores and the one-sentence reasoning.
User sees: `deliverables/judge-run-<today>/JUDGE.md` plus `verdict.json`.

**Step 4 — revise (if needed)**
Claude runs `~/.claude/skills/elasticjudge/scripts/explain.sh deliverables/judge-run-<today>/verdict.json` to retrieve line-level critiques.
User sees: specific sentences flagged with reason codes. Claude proposes one edit per critique for approval before resubmitting.

**Step 5 — pass**
Once every axis clears the threshold and no safety flag fires, the verdict is `pass`.
User sees: "Ready to send. JUDGE.md saved to `deliverables/judge-run-<today>/`."

## Verification: how to confirm skills are active

After running `scripts/install-all.sh`, open a new Claude Code session if the slash commands are not already visible.

In the slash command picker, all three skills should appear:

- `/cost-optimization`
- `/brainofbrains`
- `/elasticjudge`

If a skill does not appear, re-run the installer:

```bash
bash scripts/install-all.sh
```

Then open a fresh Claude Code session.
