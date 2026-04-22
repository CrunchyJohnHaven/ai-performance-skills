# AI Performance

`AI Performance` is a local-first skill for Claude Code, Codex, and similar AI coding tools. It wraps `@sapperjohn/kostai` / `ai-cost` to install safe savings defaults, scan a repo for waste, generate an optimization plan, produce a proof-of-savings artifact, and optionally prepare a share-back packet with aggregate metrics only.

## Install

Pick one path:

```bash
# Clone directly into a Claude skills directory
git clone git@github.com:CrunchyJohnHaven/cost-optimization-skill.git \
  ~/.claude/skills/cost-optimization
```

```bash
# Or install the npm package and symlink the shipped skill
npm install -g @sapperjohn/kostai
ln -s "$(npm root -g)/@sapperjohn/kostai/skills/cost-optimization" \
      ~/.claude/skills/cost-optimization
```

Then ask for `AI Performance`, or paste the bootstrap block from [assets/install-message.md](assets/install-message.md).

## Core flow

```bash
scripts/install.sh
scripts/scan.sh
scripts/optimize.sh
scripts/proof.sh --audience demo --date "$(date +%Y-%m-%d)"
```

The proof step creates manager-friendly outputs under `deliverables/<audience>-<date>/`.

## Share Results

`scripts/feedback.sh` creates a manual, opt-in share packet:

```bash
scripts/feedback.sh --audience elastic-pilot --date "$(date +%Y-%m-%d)"
```

Outputs:
- `FEEDBACK.md`
- `SLACK.md`
- `feedback.json`

Default privacy posture:
- local only
- no MCP requirement
- no prompt or response bodies in the share packet
- no automatic send

## Update

Preferred update path for npm and copied installs:

```bash
scripts/update.sh
```

If this repo was cloned directly, `git pull` also works.

## Maintainers

Future agents should read [AGENTS.md](AGENTS.md) first. That file contains the publishing checklist, guardrails, and the “never automatic telemetry” rule for share-back behavior.
