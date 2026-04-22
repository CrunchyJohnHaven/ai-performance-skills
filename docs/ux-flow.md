# User Experience Flows

## First-time install (30 seconds)

1. Open terminal in any repo
2. Run: `bash <(curl -fsSL https://raw.githubusercontent.com/CrunchyJohnHaven/ai-performance-skills/main/scripts/install-all.sh)`
3. Open Claude Code — skills appear immediately (no restart needed)
4. Type: "lower my AI bill" — AI Performance skill activates

## Cost-optimization workflow (5 minutes)

**Step 1 — trigger**
User types "lower my AI bill" or "am I wasting tokens on Claude Code?" in any Claude Code session.
Claude responds: "I'll run the AI Performance skill to scan your workspace and identify savings opportunities."

**Step 2 — scan**
Claude runs `scripts/scan.sh`. Output lists detected local runtimes (Ollama, LM Studio) and source files containing LLM call sites.
User sees: a table of call sites with estimated token costs per call and which are candidates for local routing.

**Step 3 — optimize**
Claude runs `scripts/optimize.sh` and presents the top three patches: prompt caching, prose compression, and model downgrade for eligible calls.
User sees: a diff for each patch. Claude applies one patch per commit so savings can be attributed per technique.

**Step 4 — proof**
After at least one shadow-mode comparison has run, Claude runs `scripts/proof.sh`.
User sees: a one-page `PROOF.md` under `deliverables/<audience>-<date>/` with measured savings, dollars saved, quality signal, and the 10%-pass-through pricing math. Every number is labeled Measured, Modeled, or Needs verification.

**Step 5 — share (optional)**
User says "I want to share the results with my manager."
Claude runs `scripts/feedback.sh --audience manager` and produces a `SLACK.md` snippet the user pastes into Slack or email. No data leaves the machine automatically.

## BrainOfBrains workflow (first-time setup)

**Step 1 — trigger**
User types "install brains into this workspace" or "ask the expert brain about Jesse's priorities."
Claude responds: "I'll bootstrap the BrainOfBrains substrate. This writes `bin/brain` and seeds specialist brains locally — nothing leaves the machine."

**Step 2 — install**
Claude runs `scripts/install.sh`. The installer writes `bin/brain`, creates `evidence/brain/` with a seeded `STATE.json`, `brains.json`, and initial `.aaak` closet files.
User sees: a list of installed brains (substrate, specialist per stakeholder, product brains).

**Step 3 — first tick**
Claude runs `bin/brain tick` to populate closets and compute the initial BIV score.
User sees: tick output with BIV score and per-brain status (in-band, breach, awaiting-data).

**Step 4 — first query**
User types "what does Jesse care about this quarter?"
Claude runs `scripts/ask.sh "what does Jesse care about this quarter?"` and returns a synthesized answer with closet citations.
User sees: a plain-English answer and the L0/L1/L2 source layers it was drawn from.

**Step 5 — verify**
Claude runs `scripts/health.sh` and prints PASS/FAIL per brain with the last-tick timestamp.
User sees: a health table. Any brain in breach shows a remediation hint.

## ElasticJudge workflow (grade a memo)

**Step 1 — trigger**
User types "judge this memo before I send it" or pastes a file path and says "is this Elastic-accurate?"
Claude responds: "I'll submit this to ElasticJudge. The judge API sees the text you send it — confirm there is no customer PII or embargoed material in the file."

**Step 2 — submit**
Claude runs `scripts/judge.sh docs/MEMO.md` (or `--text "<inline>"` for short strings).
User sees: a progress indicator while the POST completes.

**Step 3 — verdict**
Claude presents the verdict: `pass` / `needs-revision` / `reject`, the five per-axis scores (factual correctness, Elastic-domain accuracy, brand voice, exec-readiness, safety), and the one-sentence verdict reasoning.
A full verdict and `JUDGE.md` are written to `deliverables/judge-run-<today>/`.

**Step 4 — revise (if needs-revision)**
Claude runs `scripts/explain.sh deliverables/judge-run-<today>/verdict.json` to retrieve line-level critiques.
User sees: specific sentences flagged with reason codes. Claude applies critiques one at a time and resubmits after each edit.

**Step 5 — pass**
Once every axis scores 3 or above and no safety flag fires, the verdict is `pass`.
User sees: "Ready to send. JUDGE.md saved to `deliverables/judge-run-<today>/`."

## Verification: how to confirm skills are active

After running `scripts/install-all.sh`, open a new Claude Code session (Cmd+N) so the skills are picked up.

In the slash command picker, all three skills appear as:
- `/cost-optimization`
- `/brainofbrains`
- `/elasticjudge`

Run `/cost-optimization` directly (no trigger phrase needed) to confirm the skill loads and can call the CLI.

If a skill does not appear in the picker, re-run the installer:

```bash
bash scripts/install-all.sh
```

Then open a fresh Claude Code session.
