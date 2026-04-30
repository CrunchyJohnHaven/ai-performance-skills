# Market Readiness Score

Use one score: **AI Performance market readiness, 0-100**.

`100/100` means this is the best package on the market for employee-side LLM cost governance in Claude Code / Codex / Gemini CLI work: easiest install, safest enterprise posture, strongest proof artifact, cleanest public distribution, and fastest path from "my AI bill is too high" to credible savings.

## Current Gate

As of the `0.5.2` release push, treat the package as **84/100**. npm is live, the public `ai-performance-skills` repo is synced, and the release gate can now reproduce the packed npm install plus the installed Claude skill surface.

Do not inflate the score for modeled capability. Raise it only when a human or CI can reproduce the install and proof path.

## Scoring Rubric

- **Product story (15 pts):** Employee benefit is obvious, not framed as surveillance. The first minute makes the user faster and more credible.
- **Claude skill ergonomics (15 pts):** `SKILL.md` frontmatter is Claude-compatible, instructions are short, commands run from a target repo, and bundled scripts are helpers rather than hidden prerequisites.
- **Adnan / Elastic pilot safety (20 pts):** Real pilots use real workflow data, shadow-only posture, named owner, 30-day decision, >=20% measured savings, >=95% quality parity, no MCP default, no raw prompt capture.
- **Proof quality (15 pts):** `PROOF.md`, `PROOF.html`, and `proof.json` are generated from measured comparisons, label claims as Measured / Modeled / Needs verification, and support a CIO conversation without hand math.
- **Distribution readiness (20 pts):** npm package ships skills and excludes generated evidence; standalone public repo sync is gated on npm `0.5.2+`; install docs distinguish AICost/npm layout from public repo layout.
- **Release hygiene (15 pts):** Clean worktree, scoped commit, tests pass, package dry-run is small, and public sync happens only after the npm gate clears.

## Raise The Score

- **84 -> 90:** Add a fresh-machine Agent Builder / Claude Code install transcript and a real-pilot no-demo evidence receipt.
- **90 -> 95:** Add competitor/market scan notes and harden the proof packet against the best comparable tools.
- **95 -> 100:** One-click install, public docs fully synced, real Elastic workflow proof, and repeatable CI release gate covering npm, public repo, and installed Claude skill.

## Hard Gates

- If npm latest is below `0.5.2`, public skills repo sync remains blocked.
- If `scripts/registry-gate.sh` fails, do not run an install smoke or public sync.
- If generated `evidence/` appears in the npm tarball, score cannot exceed 70.
- If real pilot instructions run `demo --clear`, score cannot exceed 75.
- If proof data is modeled but presented as measured, score cannot exceed 60.
