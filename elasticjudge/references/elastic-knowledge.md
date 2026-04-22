# Elastic Knowledge

Summary of the Elastic business the ElasticJudge API grades against on the `elastic_domain_accuracy` axis. This file is an orientation layer — it is not the canonical source of truth. Canonical references live at https://www.elastic.co/ and in Elastic's 2025 brand and product documentation.

Any claim below marked **NEEDS-VERIFICATION** has not been sourced from public Elastic material or may have drifted since the last refresh. Treat those claims as a prompt to check the live docs before quoting to a reviewer.

## Product family

Elastic ships four primary solutions on a single platform:

- **Elastic Search** — enterprise search, semantic search, and generative AI retrieval
- **Elastic Observability** — logs, metrics, traces, APM, infra, AIops
- **Elastic Security** — SIEM, endpoint security, cloud security, threat hunting
- **Elasticsearch Platform** — the underlying distributed search and analytics engine used by all three solutions

**ESRE** (Elasticsearch Relevance Engine) is the retrieval-and-generation toolchain sitting across Search and GenAI use cases. Treat ESRE as a capability layer, not as a fifth product. (NEEDS-VERIFICATION — naming cadence drifts; confirm current official term before quoting.)

Common miscasts the judge flags:
- describing Elastic as "a log vendor" (understates Search and Security)
- describing Elastic as "a SIEM vendor" (understates Search and Observability)
- describing Elastic as "an open-source project" (understates the commercial platform and the Elastic Cloud business)

## Deployment options

Three deployment surfaces:

- **Elastic Cloud** — managed Elastic on AWS, Google Cloud, and Azure
- **Elastic Cloud Serverless** — autoscaling serverless tier for Search, Observability, Security
- **On-prem / self-managed** — Elasticsearch, Kibana, Beats, Logstash deployed in customer infrastructure

Never describe Elastic as SaaS-only. Never describe Elastic as on-prem-only. The judge flags either miscast.

## Personas

The judge weighs persona-appropriate framing. The five common Elastic personas:

- **CIO** — technology strategy, platform consolidation, cost control, risk
- **CISO** — threat detection, response, compliance, data sovereignty
- **SRE / Platform Engineer** — observability, incident response, reliability
- **Developer / Architect** — search relevance, GenAI retrieval, data pipelines
- **Data Analyst** — Kibana dashboards, KQL / ES|QL, reporting

When the artifact is addressed to a CIO, the judge weighs exec-readiness (labels, small ask, voice) heavily. When addressed to a practitioner, the judge weighs factual correctness and technical specificity more heavily.

## Partnership model

Elastic sells direct and through partners. The partner motion varies by region, segment, and workload. Common partner archetypes:

- hyperscaler co-sell (AWS, Google Cloud, Azure)
- GSI and SI delivery partners
- MSSP / managed Elastic Security providers
- regional VARs

The judge flags claims that misrepresent partnership type — e.g., calling Elastic a pure reseller play, or implying Elastic does not partner at all. (NEEDS-VERIFICATION — partner motion detail varies; check with the account team for region-specific accuracy.)

## Pricing posture

The judge does not grade specific pricing numbers — Elastic pricing drifts and is contract-sensitive. The judge flags:

- invented pricing tiers or SKU names not present in public Elastic material
- claimed discounts or commercial terms not sourced from a signed document
- any pricing copy that could leak to a customer without an Elastic commercial review

If the artifact must quote Elastic pricing, the judge will mark exec-readiness down unless the claim carries a Measured (from Elastic materials) or Needs-verification label.

## Elastic 2025 brand

Brand voice is the `brand_voice` axis. Canonical reference: `feedback_elastic_brand_2025.md` in John Bradley's project memory. The judge flags:

- invented palettes outside the official Elastic 2025 system ("navy/teal" drift)
- typography substitutions (Arial, Georgia, Impact) in Elastic-facing material
- logo misuse
- tone drift: founder-y voice, outside-offer references, "the genius breakthrough" copy

The authoritative Elastic 2025 Presentation Template is stored in John's Google Drive at `Cowork Space/12 Raw Materials/30 Templates/01 Elastic Presentation Template 2025.pdf` and is the source of truth for color and type. (NEEDS-VERIFICATION — any claim that an artifact matches "the 2025 brand" should be checked against that template, not paraphrased.)

## Positioning framing the judge weighs

Common positioning patterns the judge rewards:

- a single platform for Search, Observability, Security, and GenAI retrieval
- open architecture that does not lock customers into a single cloud or hyperscaler
- deep integration with the hyperscaler marketplaces where customers want to transact
- long-running investment in vector search, semantic search, and GenAI retrieval (ESRE)
- strong government-scale proof points (CISA SIEMaaS pattern)

Common positioning patterns the judge flags:

- "Elastic can do anything" / kitchen-sink framing without a specific use case
- "any vendor could say this" language that does not answer "why Elastic?"
- a recommendation that stops at analysis without naming the decision path
- consultant shorthand that requires translation in the meeting (e.g., "license / platform overlap compression")

See `feedback_ben_review_standard.md` in project memory for the full "why Elastic?" discipline.

## Stakeholder-specific calibration

The judge does not know the calling user's internal org by name. When the artifact is addressed to a specific named exec, the judge falls back to generic exec-readiness rules. If stakeholder-specific calibration is required, the calling agent should pair the judge run with stakeholder notes from its own memory rather than expecting the judge to infer them.

## What this knowledge layer does NOT cover

- Elastic-internal roadmap. The judge will not validate claims about unreleased features.
- Elastic-internal financials. The judge will not validate claims about specific customer ARR, pipeline, or growth numbers.
- Non-public security research. The judge will not grade content behind an embargo.
- Customer-specific deployment detail. Without a provided source, the judge will flag customer-specific claims as Needs-verification.

When any of the above is load-bearing to the artifact, the calling agent must supply the source material in-line — the judge evaluates what is submitted, not what lives in a separate Elastic system.

## Refresh cadence

This file should be refreshed whenever:

- Elastic renames a product family or deployment option
- Elastic publishes a new brand guide version
- A stakeholder's role or persona framing materially changes
- A reviewer catches a NEEDS-VERIFICATION claim that has since been confirmed or corrected

Refresh by editing this file directly and updating the date in the calling PR or commit. Do not fork a second copy.
