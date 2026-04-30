# Elastic employee pilot — send kit

Use this when inviting individual employees to install **AI Performance** (`skills/cost-optimization/`). It aligns with `references/adnan-pilot.md` and `references/elastic-notes.md`: employee-benefit framing first, Measured / Modeled / Needs verification on numbers, no auto egress, opt-in return packet.

---

## Minimum path (default)

Participants **unzip** (or **Download ZIP** from **ai-performance-skills** if they have no attachment), **open the folder**, read `**START_HERE.txt`**, then `**PILOT_README.txt`** — instructions live there; no separate “paste this whole kit” file.

**Coordinator outbound text** (attach zip or skip if they will use GitHub only): copy from `assets/elastic-pilot-coordinator-wrapper.txt` in this repo (same words as below).

```text
Hi — we have a pilot; would you participate?

Pilot testing new claude skills: https://github.com/CrunchyJohnHaven/ai-performance-skills

We are testing whether doing the following saves you 30%+ (millions of dollars company-wide) on your LLM costs.

This pilot will help us turn this into something that can be shared company-wide and what we develop here could even help our customers.

We need a few real tries on real machines so we know what to ship. Nothing auto-uploads — you only send a report if you want to.

1. Paste the block under PASTE BELOW into Claude (Desktop or Code) in a new chat.
2. Attach the zip file I shared to that chat if you have it — Claude can pull the same files from GitHub.

PASTE BELOW:

Hi — unzip the attachment if there is one OR download https://github.com/CrunchyJohnHaven/ai-performance-skills (Code → Download ZIP) and open that folder. Read START_HERE.txt, then PILOT_README.txt — do what they say. Come back with FEEDBACK.md for the human to forward (that’s the report).
```

Nothing auto-uploads; they still return `**FEEDBACK.md**` when the run finishes.

**Slack pitch hygiene:** do not promise unlabeled “~30%” or company-wide “millions” as **Measured** — use **Modeled / directional** language; internal spec is `references/adnan-pilot.md` in the skill folder.

---

## Zip contents (what to attach)

**Automated build (recommended):** from this repo root:

```bash
npm run package:elastic-pilot-zip
```

Writes `dist/elastic-ai-performance-skill-pilot.zip` (gitignored). Requires the `zip` CLI.

Manual layout — `elastic-ai-performance-skill-pilot.zip` contains:


| Path in zip                | Source                                                                                                        |
| -------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `START_HERE.txt`           | `skills/cost-optimization/assets/START_HERE.txt` (open this first after unzip)                                |
| `PILOT_README.txt`         | `skills/cost-optimization/assets/PILOT_README.txt`                                                            |
| `ELASTIC_PILOT_PROMPT.txt` | `skills/cost-optimization/assets/elastic-pilot-participant-prompt.txt` (paste into Claude — see PILOT_README) |
| `cost-optimization/`       | Full skill tree from `skills/cost-optimization/`                                                              |


**GitHub “Download ZIP” source:** use **ai-performance-skills** and follow `START_HERE.txt` in the archive root, then `PILOT_README.txt`.

**Skill folder destinations**


| Agent                | Typical skills directory                                                                                        |
| -------------------- | --------------------------------------------------------------------------------------------------------------- |
| Claude Code / Cowork | `~/.claude/skills/cost-optimization` (copy or symlink the folder; final path must end with `cost-optimization`) |
| Codex                | `~/.codex/skills/cost-optimization` if present, else follow current Codex skill path in your build              |


Do not rename the inner `cost-optimization` folder; the skill id stays `cost-optimization`.

**Coordinator hygiene (avoid first-run failure)**

- Do **not** paste personal paths (e.g. `/Users/you/Downloads/...`) into the participant email body — humans copy-paste those into threads and it reads as broken instructions. Attach the **zip**; paths inside the prompt should only use `~/.claude/skills/cost-optimization` or “the `cost-optimization` folder you installed”.
- Canonical attachment name: **elastic-ai-performance-skill-pilot.zip** (from `npm run package:elastic-pilot-zip`). If using GitHub instead of the attachment, use **https://github.com/CrunchyJohnHaven/ai-performance-skills** and follow the root `START_HERE.txt`.

---

## Participant instructions

**Canonical path:** unzip (or GitHub ZIP) → `**START_HERE.txt`** → `**PILOT_README.txt`** → paste `**ELASTIC_PILOT_PROMPT.txt**` into Claude when that file tells you to; assistant runs install and pilot.

In the invite body: *do not* paste personal `Downloads/` paths — attach the zip only. See **Coordinator hygiene** above.

Demo-first narrative for non-Elastic audiences: `assets/install-message.md`.

---

## What participants return (max signal for coordinators)

**Plain language for invites:** “When it’s done, **send us back the report**” — that file is `**FEEDBACK.md`** under `deliverables/elastic-pilot-<date>/` (aggregate only).

### Slack — longer variant (only if you want more tone in-channel)

Same substance as **Minimum path**; instructions live in **START_HERE.txt** / **PILOT_README.txt** inside the package.

```text
Hi — voluntary **AI Performance** pilot (local on your machine; nothing auto-uploads).

Attach the zip to Claude, paste the full pilot prompt (ELASTIC_PILOT_PROMPT.txt — your coordinator will paste it or it’s inside the zip). Claude unpacks, runs the pilot, and tells you what to return. We need **FEEDBACK.md** (aggregate); **SLACK.md** + **PILOT_ROLLUP.json** help if you can include them — no customer data, code, or prompts.

Thanks.
```

**Required**

- `deliverables/elastic-pilot-<YYYY-MM-DD>/FEEDBACK.md` — savings + **where the money went** (workload roll-up) + **pass-through economics** (annualized labeled **Modeled**) + mechanisms + **implementation plan signal** (`.kostai/optimizations.md` line / `[SAFE]` counts in skill cwd + scan workspace, no paths or plan body) + gates + pilot environment + positive close.

**Strongly encouraged (same folder; tiny, no PII)**

- `SLACK.md` — one-screen rollup for email/Slack forwarding.
- `PILOT_ROLLUP.json` — pairs, savings %, **mechanism mix**, **top savings rows**, **subscription / annualized value**, **captureMode**, Node/platform, gate booleans — for spreadsheets and KostAI sprint planning (**no absolute skill path**).
- `proof.json` — **full ProofReport** (same economics + methodology string); best for engineering ingestion alongside `PILOT_ROLLUP.json`.
- `SCAN_SNAPSHOT.txt` — raw `kostai scan` output for triage.

**If scripts could not run**

- `PROOF.md` from the demo path if it exists, plus agent + OS + one-sentence blocker — use the attestation template below.

Aggregate-only: no prompt bodies, no automatic send.

---

## Day 30 — second report (rolling **Measured** savings, easy coordinator ask)

After participants have used KostAI normally for a few weeks, ask for **one more** aggregate packet — same privacy rules, **30-day window** only:

**What to say (plain language):** “Please run the **30-day report** and send us `**FEEDBACK.md`** again.”

**What they run** (from the repo that actually contains `**.ai-cost-data/`** — usually their main git project, not the skill zip):

```bash
cd /path/to/your/project
PILOT_LEDGER_ROOT="$PWD" /path/to/cost-optimization/scripts/pilot-30d-report.sh
```

If the ledger only exists under the installed skill folder, `cd` there and run `./scripts/pilot-30d-report.sh` with no env var.

**What you collect:** `deliverables/elastic-pilot-30d-<YYYY-MM-DD>/FEEDBACK.md` (required). Same-folder `**SLACK.md`**, `**PILOT_ROLLUP.json`**, and `**proof.json**` are optional but speed dashboards the same way as the day-0 bundle.

Script: `skills/cost-optimization/scripts/pilot-30d-report.sh` (wraps `feedback.sh --audience elastic-pilot-30d --last 30d`).

---

## Compliant invite paragraph (replaces unlabeled “~30% / millions” claims)

Use when you want Adnan air cover **and** defensible numbers:

> At the direction of our Chief Information Officer **Adnan Adil**, you are invited to a **voluntary** pilot of Elastic’s **AI Performance** skill — local tooling for Claude-compatible coding assistants that produces **labeled** efficiency artifacts on your machine (nothing sent automatically).
>
> **What to do:** Attach **elastic-ai-performance-skill-pilot.zip** to **Claude Code or Cowork**, then paste the **entire** contents of **ELASTIC_PILOT_PROMPT.txt** (from inside the zip or from the coordinator’s mirror message). Your **coding assistant** unpacks, installs, and runs the pilot on your machine — you do not hand-type shell commands.
>
> **What to send back:** `**FEEDBACK.md`** (required) plus `**SLACK.md`**, `**PILOT_ROLLUP.json`**, and `**SCAN_SNAPSHOT.txt**` from the same `deliverables/elastic-pilot-<date>/` folder when possible — all aggregate metrics; no customer data, no proprietary code, no LLM prompt/response bodies.
>
> **About savings:** **~30%** is a **Modeled / directional** hypothesis for many coding-adjacent workflows at maturity — **not** a per-person **Measured** guarantee. Company-wide dollar impact is **Modeled at scale**, not read from this pilot. Expansion targets **≥20% Measured** savings with **≥95%** quality parity on agreed real tasks (`references/adnan-pilot.md` in the skill folder).

---

## Email template (recommended — employee benefit first)

**Subject:** Pilot invite: AI Performance skill for Claude Code / Codex (voluntary)

Hi Name,

With support from **Adnan Adil** (CIO), we are running a **voluntary** pilot of Elastic’s **AI Performance** Claude skill — local tooling that helps you get cleaner context and **measurable** insight into LLM efficiency on your own AI-assisted development work.

**What we need from you**

1. Attach **elastic-ai-performance-skill-pilot.zip** to **Claude Code or Cowork** (same conversation).
2. Paste the **entire** contents of **ELASTIC_PILOT_PROMPT.txt** from the zip (or use the copy we paste in a follow-up message). Do not edit the text.
3. When Claude finishes, forward what it produced: **FEEDBACK.md** (required) plus **SLACK.md**, **PILOT_ROLLUP.json**, and **SCAN_SNAPSHOT.txt** from the same `deliverables/elastic-pilot-<date>/` folder when possible. All are **aggregate** efficiency signals — no sensitive content.

**About the numbers**

- On the **built-in demo workload**, the proof artifact shows a large swing with clear **Measured / Modeled / Needs verification** labels.
- For **your** real repos, savings depend on workflow; our **expansion gate** is **≥20% Measured** savings with **≥95%** quality parity on an agreed task set — see internal pilot spec.
- A **~30%** figure is a **Modeled / directional** hypothesis for many coding workflows, not a guarantee per person; we are collecting pilot data to calibrate.

Thank you for helping us decide whether this should roll out more broadly — including, eventually, patterns we can share with customers.

Signature

---

## Email template (CIO-forward variant — use only if audience expects exec tone)

**Subject:** CIO-sponsored pilot: AI Performance skill — feedback requested

Hi Name,

**Adnan Adil** asked us to run a disciplined pilot of Elastic’s **AI Performance** skill for Claude-compatible coding agents. The skill is **local-first**: no MCP by default, no automatic telemetry, default capture is metadata-oriented.

Please attach **elastic-ai-performance-skill-pilot.zip** to **Claude Code or Cowork**, paste the entire **ELASTIC_PILOT_PROMPT.txt** into the same conversation (the **assistant** runs all shell steps), then return `deliverables/elastic-pilot-<date>/FEEDBACK.md` plus `SLACK.md`, `PILOT_ROLLUP.json`, and `SCAN_SNAPSHOT.txt` when possible. All are aggregate-only and suitable for rollup.

We are **not** asking for prompt text, customer data, or proprietary code — only labeled efficiency aggregates so we can compare against our **Measured** expansion gates (20%+ savings, 95% quality parity on agreed tasks).

Thank you,

Signature

---

## Claims to avoid in external employee mail

- Unlabeled “**~30%**” as if universally **Measured**.
- Company-wide “**millions**” unless explicitly tagged **Modeled** with assumptions stated, per `references/adnan-pilot.md`.
- Framing that sounds like **cost surveillance** of individuals; lead with **their** speed and clarity, then optional rollup.

---

## Email template (warm / relationship-forward — close to field voice)

Use when you want the note to feel personal while staying inside `references/adnan-pilot.md` (no unlabeled universal savings claims).

**Subject:** Pilot invite: AI Performance for your Claude / Codex workflow (voluntary)

Hi Name,

At **Adnan Adil**’s direction, I’m inviting you to a **voluntary** pilot of Elastic’s **AI Performance** skill — local tooling that helps you tighten LLM efficiency on AI-assisted dev work (same skill family we’re calling **LLM optimization** internally).

If you’re willing to try it, here’s all we need:

1. **Attach** the zip to **Claude Code or Cowork** (same thread).
2. **Paste** the entire contents of **ELASTIC_PILOT_PROMPT.txt** from the zip (or the mirror we send in a follow-up). Your assistant handles unpack/install/run via its shell tool — no hand-typed commands on your side.
3. **Reply** with what your agent produced: **FEEDBACK.md** required; **SLACK.md**, **PILOT_ROLLUP.json**, and **SCAN_SNAPSHOT.txt** strongly preferred (same folder; aggregate only). If those files are not generated yet, use the attestation template below.

**About the numbers**

Adnan’s working hypothesis is that, at **company scale**, disciplined use of these patterns could materially reduce LLM spend — think on the order of **roughly ~30%** for many coding-adjacent workflows — but that is **Modeled / directional**, not a per-person guarantee. We are calibrating against pilot returns and our expansion gates (**≥20% Measured** savings with **≥95%** quality parity on agreed real tasks). Treat any demo workload numbers as **labeled** in the proof file (Measured / Modeled / Needs verification).

Thank you for helping us decide whether this should roll wider — including patterns we can eventually share with customers.

Signature

---

## If `FEEDBACK.md` is missing — participant attestation (paste into reply)

```markdown
# AI Performance pilot — install attestation

- **Name / team**:
- **Agent + version** (e.g. Claude Code x.y, Codex, Cowork):
- **OS**:
- **Skill path used** (where `cost-optimization` landed):
- **Install outcome**: success | partial | blocked
- **Steps completed** (e.g. demo.sh, proof.sh, scan.sh, feedback.sh):
- **Largest blocker** (if any, one sentence):
- **Subjective note** (optional, one sentence — e.g. “would use again” / “needs IT help”):
- **Consent**: I did not paste proprietary prompts, customer data, or code into this reply.
```

---

## Coordinator checklist (before first send)

- `npm view @sapperjohn/kostai version` is **≥ 0.5.2** before you tell participants to rely on `npx @sapperjohn/kostai@^0.5.2` paths; if the registry lags, ship the zip from a pinned git commit of this repo instead and note the commit hash in the pilot thread (see root `AGENTS.md` / skill `SKILL.md` registry gate).
- Zip built from pinned commit or npm `@sapperjohn/kostai` version recorded in pilot thread; coordinator runs `**./scripts/pilot-complete.sh`** once from the staged `cost-optimization` folder before first external send.
- Default invite uses **Minimum path** (`**START_HERE.txt`** inside the zip or under **skills/cost-optimization/assets/** on GitHub); do not rely on a stale paraphrase copied weeks ago.
- Inbound path for `FEEDBACK.md` + optional `PILOT_ROLLUP.json` / `SCAN_SNAPSHOT.txt` (Slack channel, email alias, or form) is defined.
- Legal/comms knows default posture: opt-in return, no auto egress.

