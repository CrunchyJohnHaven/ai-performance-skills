# Evaluation Axes

The ElasticJudge API scores every submitted artifact across five axes, each on a 0-5 scale. This file documents the rubric so a calling agent knows what the judge is weighing and a reviewer can read the verdict without guessing.

Do not paraphrase these definitions in a downstream critique — quote them directly. Axis names and descriptor language are what the downstream agent reasons over.

## Axis list

| Axis | What it scores | Typical failure signal |
| --- | --- | --- |
| `factual_correctness` | Claims match external reality; citations resolve | Fabricated numbers, invented quotes, hallucinated URLs |
| `elastic_domain_accuracy` | Product names, architectures, personas match Elastic public material | Wrong product family name, invented pricing tier, miscast persona |
| `brand_voice` | Matches Elastic 2025 brand guide tone and style | Custom palette, wrong typography reference, off-tone phrasing |
| `exec_readiness` | Labeled numbers, explicit recommendation, small ask | Unlabeled percentages, missing ask, founder-y voice |
| `safety` | No surveillance language, no banned phrases, no PII leak | "emergency", "golden ticket", outside-offer references, customer PII |

## Score descriptors

Each axis uses the same 0-5 scale:

- **0** — Severe. Ship-blocker. One or more factual / safety violations that would embarrass the sender or the company.
- **1** — Poor. Major rework required. The artifact fails the axis in a way a reviewer would call out immediately.
- **2** — Below bar. Needs revision. Specific critiques exist; the artifact is fixable but not shippable.
- **3** — Acceptable. Meets minimum bar for the audience. A reviewer might nit-pick but would not block.
- **4** — Strong. Above minimum; the axis is an asset of the artifact, not a drag.
- **5** — Exemplary. Reference-grade; can be used as a template for future artifacts.

A `pass` verdict requires every axis at 3 or above and no safety flag. `needs-revision` covers axes at 2 or below that are fixable without rebuild. `reject` fires on any axis at 0-1 in `factual_correctness` or `safety`.

## Axis 1 — Factual correctness

Scores whether the claims in the artifact match reality.

| Score | Descriptor |
| --- | --- |
| 5 | Every numeric, factual, and cited claim is verifiable against a public or provided source |
| 4 | Claims verifiable; at most one low-stakes detail requires a minor source correction |
| 3 | No fabricated claims; some claims lack citations but are plausible and non-critical |
| 2 | One or more claims require revision — number wrong, date wrong, or citation missing |
| 1 | Multiple claims wrong or a central claim is wrong; significant rework |
| 0 | Fabricated citations, invented quotes, or a ship-blocking factual error |

Common failure modes the judge flags:
- invented statistics ("92% of CIOs say…" with no source)
- fabricated quotes attributed to a named person
- URLs that do not resolve to the claimed content
- dates that do not match the referenced event

### Concrete examples for Axis 1

**Score 0 — Severe:**
> "According to Gartner's 2025 Magic Quadrant, Elastic holds the #1 position in AI-powered SIEM."
> (No such Gartner report exists; the claim is fabricated. Ship-blocker.)

**Score 2 — Below bar / fixable:**
> "Elastic handles over 10 petabytes of log data per day globally."
> (The number is plausible but has no cited source and no Measured / Modeled label. Fixable with a label and a source link or removal.)

**Score 3 — Acceptable:**
> "Elastic is used by thousands of organizations worldwide for search and observability workloads."
> (Vague but not wrong; a reviewer might ask for a sharper stat but would not block on it.)

**Score 5 — Exemplary:**
> "In our Elastic Cloud pilot (Measured, 2026-03-15), indexing latency dropped from 420 ms to 38 ms after enabling the local-tier inference cache — a 91% reduction on the sampled workload."
> (Source is the operator's own measurement; labeled; no invented claim.)

## Axis 2 — Elastic-domain accuracy

Scores whether the Elastic business is described correctly. See `elastic-knowledge.md` for the knowledge base the judge weighs against.

| Score | Descriptor |
| --- | --- |
| 5 | Product names, architectures, personas, and partnership model all match public Elastic material |
| 4 | Minor naming or phrasing drift; technically correct |
| 3 | Accurate at the top level; some secondary detail could be sharpened |
| 2 | A meaningful Elastic detail is wrong (e.g., wrong product family name, misstated deployment option) |
| 1 | Multiple Elastic details wrong; reads as generic-vendor language |
| 0 | Core Elastic positioning wrong (e.g., Elastic described as a SIEM-only vendor or a hosting-only business) |

The judge is pedantic on:
- product family names (Search, Observability, Security, Elasticsearch Platform, ESRE)
- deployment options (Cloud, Serverless, on-prem; not "SaaS-only")
- persona language (CIO, CISO, SRE, Dev, Analyst)
- partnership model (not a reseller; partner-driven motion varies by region)

### Concrete examples for Axis 2

**Score 0 — Severe:**
> "Elastic is a SaaS-only log management vendor competing primarily with Datadog on price."
> (Wrong on deployment model, product breadth, and positioning. Core Elastic identity is wrong. Reject.)

**Score 2 — Below bar / fixable:**
> "The Elastic SIEM product integrates with your existing security stack."
> ("Elastic SIEM" is not the correct product name; the product is Elastic Security. Fixable with a rename.)

**Score 3 — Acceptable:**
> "Elastic provides search, observability, and security solutions deployable on Cloud or on-premises."
> (Accurate at the top level; does not mention Serverless or ESRE, but a reviewer would not block on omission alone.)

**Score 5 — Exemplary:**
> "Elastic Security — part of the Elasticsearch Platform — provides SIEM, endpoint, and cloud security capabilities, deployable on Elastic Cloud, Elastic Cloud Serverless, or self-managed on-prem, with native ESRE integration for AI-powered threat reasoning."
> (All product names, deployment options, and AI story are correct and current.)

## Axis 3 — Brand voice

Scores adherence to the Elastic 2025 brand guide: colors, typography, tone. See `feedback_elastic_brand_2025.md` in project memory for the canonical palette and type system.

| Score | Descriptor |
| --- | --- |
| 5 | Colors, typography references, and tone all match the Elastic 2025 brand |
| 4 | Tone matches; minor color or font drift |
| 3 | Tone is acceptable; no major brand violations |
| 2 | Wrong color palette referenced, or tone is off (too founder-y, too casual for audience) |
| 1 | Custom palette invented ("navy/teal") or tone is substantially off-brand |
| 0 | Directly contradicts the Elastic 2025 brand — wrong logo usage, banned color combos, or legal-risk copy |

The judge flags, among other things:
- any invented palette outside the official Elastic 2025 system
- typography substitutions (Arial, Georgia, Impact) in an Elastic artifact
- tone drift: "the genius breakthrough" language, outside-offer references, founder-y voice

### Concrete examples for Axis 3

**Score 0 — Severe:**
> Deck uses a navy-and-teal custom color scheme, references "our proprietary Bluewave font," and includes the phrase "This is our golden ticket — the most important thing Elastic has ever built."
> (Invented palette + banned phrase + hyperbolic founder-y language. Legal-risk copy potential. Reject.)

**Score 2 — Below bar / fixable:**
> Memo uses correct content but the summary block is written in a casual, excited voice: "Honestly this is SO much better than what we had before — the results blew us away."
> (Tone is off-brand for an exec audience; fixable by rewriting to measured, evidence-first voice.)

**Score 3 — Acceptable:**
> Memo is professional and factual; tone is slightly generic ("Elastic is a leader in enterprise search"). No brand violations, but no distinctive Elastic voice either.
> (Meets the bar; a reviewer would not block but might ask for a sharper Elastic-specific angle.)

**Score 5 — Exemplary:**
> Deck uses the Elastic 2025 color system (coral, dark ink, white), Elastic Sans typography, measured and evidence-first language throughout, and the executive summary leads with "what we observed" before stating the recommendation.
> (Voice, design, and structure all match the Elastic 2025 brand guide.)

## Axis 4 — Exec-readiness

Scores whether the artifact is ready for a senior reviewer (CIO, VP, or equivalent). Weight is heaviest on claim labeling and ask discipline.

| Score | Descriptor |
| --- | --- |
| 5 | Every numeric claim is labeled Measured / Modeled / Needs-verification; the ask is small and explicit; the recommendation is stated before the analysis |
| 4 | Minor label gap; recommendation present; ask is reasonable |
| 3 | Acceptable labeling; some hand-waving; recommendation implicit |
| 2 | Multiple unlabeled numbers, ask is too big, or recommendation missing |
| 1 | No labeling discipline, founder-y voice, "reassign us" / "fund a new product line" ask |
| 0 | Would embarrass the sender in front of the target exec; violates the ban list from `feedback_exec_pitch_discipline.md` |

The judge weighs specifically:
- **labels on numbers** — Measured / Modeled / Needs-verification on every quantitative claim
- **size of ask** — one named owner, one pilot, or one adjacency; not a reassignment or a funding demand in a first meeting
- **ban list** — "emergency", "immediately", "obvious", "genius", "golden ticket", "tens of millions" without label, outside-offer references, compensation language
- **voice** — "I measured / I observed / I proved" instead of "I built the genius thing"
- **structure** — exec summary, why Elastic, recommendation before evidence; not evidence-first

### Concrete examples for Axis 4

**Score 0 — Severe:**
> "We need you to fund a new AI product line immediately — this is an emergency. The savings are in the tens of millions (obviously). We'd like to reassign three Elastic engineers to our team to make this happen."
> (Multiple ban-list violations: "immediately", "emergency", "obviously", unlabeled "tens of millions", and a reassignment ask in a first meeting. Would embarrass the sender.)

**Score 2 — Below bar / fixable:**
> "Our AI routing saves roughly 70% on model costs."
> (Quantitative claim with no Measured / Modeled / Needs-verification label and no source. Fixable: add "(Modeled, April 2026 pilot data)" and a source.)

**Score 3 — Acceptable:**
> "We observed meaningful cost reduction in a two-week pilot. We'd like to discuss next steps."
> (No banned phrases, implicit recommendation, vague numbers. A reviewer would not block but would ask for labeled specifics.)

**Score 5 — Exemplary:**
> "In a two-week pilot on the USPS workload (Measured, 2026-03-01 to 2026-03-15), local-tier inference routing reduced frontier-model spend by 91% (from $332/day to $29/day). Recommendation: authorize a 60-day expanded pilot under Patrick Chen (VE lead). No headcount change requested."
> (Labeled, sourced, small specific ask, named owner, recommendation stated before evidence, no ban-list terms.)

## Axis 5 — Safety

Scores whether the artifact is safe to send. This axis is binary-adjacent — most failures here are ship-blockers regardless of other scores.

| Score | Descriptor |
| --- | --- |
| 5 | No surveillance language, no PII, no banned phrases, no legal-risk copy |
| 4 | Clean; minor tonal nit |
| 3 | Acceptable; no safety flags |
| 2 | One soft flag (e.g., "we will be watching your AI usage" framing) that reads as surveillance |
| 1 | A banned phrase present, or a phrase that reads as an external-offer reference |
| 0 | Customer PII leak, embargoed pricing leak, or legal-risk copy — do not ship |

The judge fires on:
- surveillance framings: "we will monitor your AI usage", "we will audit every call"
- banned phrases from the exec-pitch ban list
- unreleased pricing or security material visible in the body
- customer-identifying information that should not leave a legal perimeter
- compensation / outside-offer language in an internal pitch artifact

### Concrete examples for Axis 5

**Score 0 — Severe:**
> Memo includes the customer's full name, email address, and contract renewal date in the body, combined with a sentence referencing an unreleased product price tier.
> (PII leak + embargoed pricing in a single artifact. Do not ship under any circumstances.)

**Score 2 — Below bar / fixable:**
> "We will be monitoring your AI tool usage across all teams to ensure compliance with our cost governance policy."
> (Reads as surveillance framing even if the intent is benign. Fixable: rewrite as "We will publish a monthly cost digest shared with team leads.")

**Score 3 — Acceptable:**
> Memo discusses AI cost optimization in general terms; no PII, no embargoed data, no banned phrases. One sentence: "We should act quickly on this."
> (Not a hard ban-list hit; "quickly" is marginal but a reviewer would not block. Score stays at 3.)

**Score 5 — Exemplary:**
> Memo contains only aggregate, labeled data; no customer names or identifiers; no unreleased pricing; no urgency language; no outside-offer references; no compensation language. Data-egress posture is explicitly noted: "All figures are internal aggregates; no customer-identifying information is included."
> (Clean on every safety dimension; the explicit data-egress note adds reviewer trust.)

## How the verdict combines the axes

The ElasticJudge API returns a single verdict (`pass` / `needs-revision` / `reject`) derived from the axis scores. The combination rule is documented at the API level (NEEDS-VERIFICATION — confirm against the live https://elasticjudge.com/ docs before quoting it to a reviewer). The skill treats the verdict as authoritative and the per-axis scores as the appeal surface — if a verdict surprises the caller, inspect the axis scores and the line-level critiques, do not argue with the verdict string.

## What this rubric does NOT do

- It does not grade visual layout of a PPTX or DOCX (text-only judge). For visual layout, run the artifact through a separate formatting lane or a human reviewer.
- It does not grade code correctness. Use a static analyzer or unit tests.
- It does not grade spoken-narration cadence. It grades the words, not the delivery.
- It does not replace a human reviewer for high-stakes sends. A `pass` verdict is necessary but not sufficient — the sender still owns the final call.
