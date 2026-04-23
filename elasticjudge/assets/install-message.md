# Copy-Paste Install Message

One-shot trigger — an Elastic employee (or any Claude Code / Codex user) pastes the block below into their AI coding tool and the `Quality Judge` skill evaluates a deliverable and explains the verdict.

---

## For Claude Code or Codex users

Copy the block between the fences and paste into Claude Code or Codex as a single prompt:

```
I'd like to grade this deliverable before I send it.

NOTE: This skill submits the artifact text to the ElasticJudge cloud API.
You may need a valid ELASTICJUDGE_API_KEY set in your shell environment before
running step 2. Verify the current endpoint and auth requirements at
https://elasticjudge.com/ before relying on the live service.

Use the Quality Judge skill to do the following, in order:
1. Confirm the artifact I want graded. Default to the most recent file under
   deliverables/ or docs/ if I do not specify one.
2. Run `scripts/judge.sh --audience pre-send --date $(date +%Y-%m-%d) <path>`
   to submit the artifact to the ElasticJudge cloud API and write the verdict
   plus markdown summary under deliverables/pre-send-<date>/.
3. Show me the markdown verdict inline (JUDGE.md).
4. If the verdict is `needs-revision`, run
   `scripts/explain.sh deliverables/pre-send-<date>/verdict.json` and surface
   the line-level critiques. Propose one edit per critique for me to review
   before applying any change.
5. If the verdict is `reject`, stop. Do not apply any edits automatically.
   Explain which axis scored a safety or correctness fail.
6. Do not edit the artifact without my explicit approval for each change.
7. Do not submit anything that contains customer PII, unreleased pricing, or
   embargoed security material without my explicit confirmation that the
   ElasticJudge API is approved for that content class.
```

## How to make the skill available

Claude Code auto-discovers skills from three locations. Pick one:

### Option A — Drop into user skills directory

```bash
git clone https://github.com/CrunchyJohnHaven/ai-performance-skills.git
cp -r ai-performance-skills/elasticjudge ~/.claude/skills/elasticjudge
```

Claude Code will pick up the skill on next session start.

### Option B — Use as a plugin skill

If the workspace is a Claude Code plugin, drop the folder under `skills/` in the plugin directory. Auto-discovered.

### Option C — Use a package-backed build (if your operator ships one)

Link the exported `skills/elasticjudge/` folder from that package into `~/.claude/skills/elasticjudge`.

If the package name is different in the field (scoped publisher, renamed slug), override via the environment:

```bash
ELASTICJUDGE_PKG=<package-name> scripts/update.sh
```

## For Elastic Agent Builder

When publishing from this source repo, ship `elasticjudge/` as-is. If you are publishing from a packaged build instead, use its exported `skills/elasticjudge/` folder. No rename required; the frontmatter `name: elasticjudge` is the canonical identifier.

Published display name: `Quality Judge`

## API key configuration

The ElasticJudge cloud API may require a bearer token. Set it once in the shell environment:

```bash
export ELASTICJUDGE_API_KEY="<token-from-elasticjudge.com>"
```

The scripts pick up the variable automatically. If no key is set, the scripts still attempt the call. Whether unauthenticated or quota-limited access is allowed is controlled by the live service, so confirm the current pricing and auth posture at https://elasticjudge.com/.

## What to expect

On first run the user sees:

1. `deliverables/pre-send-<date>/JUDGE.md` — markdown verdict summary with axis scores and line-level critiques (when applicable)
2. `deliverables/pre-send-<date>/verdict.json` — structured payload a downstream agent can reason over
3. `deliverables/pre-send-<date>/critiques.json` — line-level critiques written when `scripts/explain.sh` is run
4. A short inline summary: verdict, each axis score 0-5, and the one-sentence reasoning

Full runtime cost of the install: zero frontier-model calls. The judge call itself costs whatever https://elasticjudge.com/ charges per evaluation — see the live pricing page.

## Safety posture recap

- The judge API sees the text submitted to it. Nothing else leaves the machine.
- No MCP server is installed by default.
- No background telemetry.
- The judge is read-only on the artifact; revisions are surfaced as suggestions the calling agent chooses to apply.
