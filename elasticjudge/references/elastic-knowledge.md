# Elastic Knowledge

Summary of the Elastic business the ElasticJudge API grades against on the `elastic_domain_accuracy` axis. This file is an orientation layer — it is not the canonical source of truth. Canonical references live at https://www.elastic.co/ and in Elastic's 2025 brand and product documentation.

Any claim below marked **NEEDS-VERIFICATION** has not been sourced from public Elastic material or may have drifted since the last refresh. Treat those claims as a prompt to check the live docs before quoting to a reviewer.

## Product family

Elastic ships four primary solutions on a single platform:

- **Elastic Search** — enterprise search, semantic search, and generative AI retrieval; combines BM25 lexical search with dense-vector (kNN/ANN) and sparse-vector (ELSER) retrieval; the retrieval engine for RAG pipelines
- **Elastic Observability** — logs, metrics, traces, APM, infrastructure monitoring, and AI-assisted anomaly detection (AIOps); ingests from OpenTelemetry natively
- **Elastic Security** — SIEM, EDR (endpoint detection and response), cloud security posture, threat hunting, and SOAR integrations; the platform behind the U.S. government SIEMaaS contract
- **Elasticsearch Platform** — the underlying distributed search and analytics engine used by all three solutions; exposes REST APIs, the Query DSL, ES|QL, and KQL

**Kibana** is the visualization and management UI that ships with the platform. It hosts Dashboards, Lens, Canvas, Maps, and the developer tools console. Kibana is not a standalone product — it depends on Elasticsearch.

**ESRE** (Elasticsearch Relevance Engine) is the retrieval-and-generation toolchain sitting across Search and GenAI use cases. Treat ESRE as a capability layer, not as a fifth product. (NEEDS-VERIFICATION — naming cadence drifts; confirm current official term before quoting.)

Common miscasts the judge flags:
- describing Elastic as "a log vendor" (understates Search and Security)
- describing Elastic as "a SIEM vendor" (understates Search and Observability)
- describing Elastic as "an open-source project" (understates the commercial platform and the Elastic Cloud business)
- describing Elasticsearch as "a vector database" — Elasticsearch is a search and analytics platform with vector search capabilities; calling it a vector database misrepresents the scope and triggers a flag on the `elastic_domain_accuracy` axis

## Deployment options

Four deployment surfaces:

- **Elastic Cloud (SaaS)** — fully managed Elastic on AWS, Google Cloud, and Azure; Elastic operates the control plane; customer chooses region and cloud provider
- **Elastic Cloud Serverless** — per-project, autoscaling serverless tier for Search, Observability, and Security; billing is consumption-based, not cluster-based; no cluster sizing decisions
- **ECE (Elastic Cloud Enterprise)** — self-managed control plane that replicates Elastic Cloud inside customer infrastructure or a private cloud; used when data sovereignty or air-gap requirements rule out SaaS
- **ECK (Elastic Cloud on Kubernetes)** — the official Kubernetes operator; deploys and manages Elasticsearch and Kibana on any Kubernetes distribution; used in container-first environments

Never describe Elastic as SaaS-only. Never describe Elastic as on-prem-only. The judge flags either miscast. Never conflate ECE (self-managed) with Elastic Cloud (SaaS) — they are different products with different support and pricing models.

## Personas

The judge weighs persona-appropriate framing. The five common Elastic personas and what each cares about:

- **CIO** — platform consolidation (fewer vendors), total cost of ownership, vendor lock-in risk, board-level risk posture, time-to-value on AI bets; does not want latency numbers, cluster sizing, or shard math in the first meeting
- **CISO** — threat detection fidelity, mean time to detect / respond, data sovereignty (which cloud region, can data leave the country), compliance posture (FedRAMP, SOC 2, GDPR), and endpoint coverage breadth
- **SRE / Platform Engineer** — observability pipeline cost, MTTD on incidents, OpenTelemetry compatibility, cardinality limits, retention tiers, and whether Elastic can replace N point tools
- **Developer / Architect** — search relevance tuning, hybrid BM25 + vector retrieval, ELSER vs. dense-vector trade-offs, ES|QL expressiveness, API stability, and latency under production load
- **Data Analyst** — Kibana Lens and Dashboards, KQL / ES|QL query ergonomics, scheduled reports, and whether the dashboard can be shared outside the platform

When the artifact is addressed to a CIO, the judge weighs exec-readiness (labels, small ask, voice) heavily. When addressed to a practitioner, the judge weighs factual correctness and technical specificity more heavily. Mixing personas in a single artifact without a clear primary audience is itself a flag.

## Partnership model

Elastic is the ISV. AWS, Azure, and GCP are distribution partners — they list Elastic Cloud on their marketplaces and count purchases toward customer committed spend (EDP/MACC/CUD), but Elastic retains the commercial relationship and sets the product roadmap. The hyperscalers do not co-develop the product.

Do NOT write "Elastic partners with Anthropic" or similar AI-vendor partnership claims unless sourced from a dated public announcement. The judge flags unsourced technology partnership claims.

Common partner archetypes:
- **Hyperscaler marketplace co-sell** (AWS, Google Cloud, Azure) — consumption billing, marketplace transact, EDP eligibility
- **GSI and SI delivery partners** — implementation, migration, and managed services on top of Elastic
- **MSSP / managed Elastic Security providers** — SOC-as-a-service built on Elastic Security
- **Regional VARs** — resell and local services in specific geographies

The judge flags claims that misrepresent partnership type — e.g., calling Elastic a pure reseller play, calling Elastic a hyperscaler product, or implying Elastic does not partner at all. (NEEDS-VERIFICATION — partner motion detail varies by region and segment; check with the account team for contract-specific accuracy.)

## Banned phrases in Elastic content

The following phrases trigger an automatic flag on the `brand_voice` or `elastic_domain_accuracy` axis regardless of context. Remove or replace them before submitting to a reviewer.

| Phrase | Why it is banned |
|---|---|
| "obviously" | Implies the reader should already know; condescending in exec copy |
| "it's clear that" | Same condescension pattern; also weak argumentation |
| "golden ticket" | Hyperbole; banned per explicit feedback from Ben review standard |
| "Elastic can do anything" / "one platform for everything" | Kitchen-sink framing; no specific use case means no specific win |
| "real-time" without a latency number | Means nothing; flag unless a p99 or SLA figure accompanies it |
| "market leader" without a Forrester or Gartner citation | Unsourced superlative; looks like AI slop |
| "industry-leading" | Same problem; always requires a dated third-party citation |
| "revolutionary" / "game-changing" / "transformative" | Marketing filler; zero information content |
| "democratize" | Overused; flag in enterprise copy |
| "we are excited to" | Founder-y voice; not Elastic brand voice |
| Outside-offer or ultimatum language | Explicitly banned per Jesse humility signal feedback |
| "internal only" slide label in an exec deck | Banned per exec pitch discipline; delete if present |
| Emergency or urgency framing without a sourced deadline | Manipulative; Elastic brand voice is evidence-first |

## Common AI slop patterns in Elastic context

These patterns appear frequently in AI-generated content about Elastic. Each is a flag on the `elastic_domain_accuracy` or `brand_voice` axis.

**"Elasticsearch is a vector database"** — Elasticsearch is a distributed search and analytics platform. It supports dense-vector (kNN) and sparse-vector (ELSER) retrieval, but calling it a vector database misrepresents the product's scope, lineage, and primary use cases. Say "Elasticsearch supports vector search" or "Elasticsearch is a search platform with native vector capabilities."

**"real-time search" without latency numbers** — "real-time" is undefined. Elasticsearch has configurable refresh intervals (default 1 second); true near-real-time depends on index settings and hardware. Any claim about real-time behavior must carry a latency figure and a test environment description.

**"Elastic is the market leader"** — requires a Forrester Wave, Gartner Magic Quadrant, or IDC MarketScape citation with a year. Do not write this claim without the citation inline.

**"Elastic partners with [AI vendor]"** — requires a dated public press release or official partner page URL. Do not assert technology partnerships from general knowledge.

**"unlimited scalability"** — meaningless without a scale test citation. Every distributed system has limits; claiming otherwise is a red flag for reviewers.

**"drop-in replacement for [competing product]"** — requires a documented migration guide and a scoped use-case comparison. Never assert a product-to-product replacement claim without sourcing.

**Claiming a specific Elastic pricing tier or SKU name not in current public docs** — Elastic pricing changes; SKU names drift. Any invented pricing claim will be flagged as Needs-verification at minimum.

**Mixing deployment model properties** — describing serverless behavior (no cluster sizing, consumption billing) in a sentence about ECE (self-managed cluster), or vice versa. Each deployment model has distinct operational and commercial properties.

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

## Official Elastic tone

Elastic brand voice is direct, precise, evidence-first, and practitioner-respecting. The shorthand: "build on what works."

Characteristics:
- Statements are grounded in evidence or carry a Measured / Modeled / Needs-verification label
- No hype language, no superlatives without citation
- Technical specificity is rewarded, not penalized — precision builds trust with practitioners and earns exec credibility
- Recommendations name a decision path, not just an observation
- Copy does not require translation in the meeting; jargon is defined on first use or removed
- The artifact speaks for itself; a good Elastic artifact does not need a "how to read this" meta-slide

The judge flags copy that reads as AI-generated filler, founder-y exuberance, or consultant hedging. The clearest test: could a practitioner or a CIO quote this sentence without embarrassment in front of their team?

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
