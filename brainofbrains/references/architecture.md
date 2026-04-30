# Architecture

How the BrainOfBrains product is delivered, paid for, and operated. This file covers the A2A (agent-to-agent) distribution model and the local-only operating posture once installed.

## The thesis

BrainOfBrains is A2A *distribution*, not A2A *software*. The product — a self-improving specialist-brain substrate — stays the same regardless of who installs it. The GTM is machine-callable: a customer's agent arrives, quotes, pays, and installs. John-time per customer trends toward zero. Engineering time compounds across every customer because every customer runs the same install recipe against the same stack-spec compiler.

## v0.1 surface

Three agent-callable MCP tools live at `https://brainofbrains.ai/mcp`:

| Tool | Purpose | Input | Output |
| --- | --- | --- | --- |
| `quote(stack_description)` | price an install | free-text or structured stack description | quote object with price, included brains, included specialist templates |
| `provision(payment_token, stack_spec)` | run the install | payment token from the payment rail + concrete stack_spec | signed tarball URL + install ID + `install.sh` URL |
| `health_check(install_id)` | confirm an install is alive | install ID returned by provision | latest STATE snapshot + per-brain status + last-tick timestamp |

The MCP tools are the only always-on surface the product exposes. There is no web dashboard to log into, no background process on the customer's machine calling home, no telemetry pipe. A customer who never touches the MCP again after install gets a fully functional local substrate.

## Payment rail

- **Primary**: x402 (agent-native HTTP 402). Cloudflare has native x402 support; the Worker in front of `provision` returns 402 with the quote, the customer's agent pays, and the 402 challenge is satisfied. No browser-mediated checkout is required.
- **Fallback**: Stripe Checkout. If the customer's agent cannot speak x402, `quote` returns a Stripe Checkout URL instead. A human can complete checkout; the resulting payment token is accepted by `provision` the same way x402 payment tokens are.

Either way, `provision` returns the same artifact: a signed tarball and an `install.sh`. The payment rail is a swap; the install payload is constant.

## Delivery

`provision` emits:

1. A signed tarball containing the compiled brain substrate for the customer's stack spec
2. An `install.sh` that verifies the signature, lays down files, and triggers the first tick
3. Optional launchd / systemd unit files for always-on tick cadence
4. An install ID that the customer's agent can later pass to `health_check`

The customer's agent verifies the signature, runs `install.sh`, and observes the first BIV tick within 5 minutes. If `health_check` does not see a BIV emission within 10 minutes, the payment rail auto-refunds. That refund margin is the forcing function on install reliability — see "The tradeoff" below.

## Infrastructure

- **Cloudflare Worker** — stateless provisioning logic. Receives MCP calls, builds the stack spec, compiles the brain substrate, signs the tarball, returns URLs.
- **Cloudflare Durable Object** — install records and payment state. One DO instance per install ID; survives Worker restarts; cheap at scale.
- **Cloudflare R2** — signed tarball storage with short-lived presigned URLs.
- **Cloudflare DNS** — already holds `brainofbrains.ai`; the MCP route and the install-script route live on the same zone.

Near-zero infrastructure cost. Scales trivially. Matches the domain already being on Cloudflare, which is a hard rule for John's projects (see `feedback_cloudflare_cli.md`).

## The tradeoff — install reliability

Agentic delivery raises the install-reliability bar:

- Consulting-era install reliability: ~80% (a human is on the call to debug)
- A2A install reliability: ~99% (auto-refund kicks in below this)

This means **do not build the A2A layer first**. Build the deterministic install and the stack-spec compiler first, because those same components also make human-triggered setup frictionless. A2A is then a thin wrapper over the install pipeline, not a separate product.

The current dependency chain to unlock A2A:

1. Install script that runs cleanly on a fresh machine with no John intervention
2. `stack_description` → `stack_spec` compiler (schema: `{projects, cost_levers, thresholds, specialist_brains}` → generates STATE files, tick scripts, closet slots)
3. External health check that can prove the install worked (implemented as the `health_check` MCP tool — reads the install's `STATE.json`)
4. x402 integration on the Cloudflare Worker (Cloudflare has a template; this is trivial once 1–3 are solid)

This skill assumes 1 and 3 are in place (the installer ships and `bin/brain status` emits STATE). 2 and 4 are the remaining engineering work that this skill should surface through `scripts/provision.sh` as "managed install (coming soon)" if the MCP endpoint is not yet live.

## Local-only operation

Once installed, every brain operation is local:

- **Closet rebuilds** — `bin/brain closet` reads commits, meetings, KB artifacts from the local filesystem and writes updated `.aaak` files locally.
- **Ticks** — `bin/brain tick` runs the full loop (ingest, rebuild, recompute, snapshot) without touching the network.
- **Queries** — `bin/brain query` composes L0/L1/L2 context against local closets and returns a compact packet plus L3 drawer plan. The calling agent may use a frontier model to synthesize a final answer, but that call is outside the substrate.
- **Health** — `bin/brain status` and `scripts/health.sh` read the local `STATE.json` and `brains.json` by default. The remote MCP `health_check` tool is only used when the user explicitly passes `--remote` (useful only for proving reliability to a buyer, not for day-to-day use).

No cloud dependency for normal use. A machine that drops off the internet after install still produces fresh packets and drawer plans, and any locally capable agent can synthesize from them. This is the structural reason default-off-MCP is a coherent posture — the product does not need the MCP to function; only the buy-flow does.

## Why default-MCP is off

Default-MCP reads as surveillance-adjacent inside large organizations. The reasoning:

- an always-on MCP server is a process the customer's machine is hosting on the customer's behalf
- some MCP integrations ingest filesystem state, terminal output, or keystrokes — the category reads as surveillance to a skeptical employee
- employees who read "install the MCP server" as "my employer is watching me" opt out, permanently

The BrainOfBrains install does not need a local MCP server. The remote MCP at `brainofbrains.ai/mcp` is agent-callable for the buy-flow; after that, every brain operation happens through `bin/brain` on the local filesystem. Local MCP is available as an opt-in integration for users who want to call substrate queries from other MCP-aware agents, but the installer does not enable it and the skill does not suggest it by default.

## Why A2A compounds

Each customer added compounds engineering time in one direction only:

- bugs in the install pipeline → fixed once, helps every future customer
- new specialist-brain templates → shipped once, available to every future customer via stack_spec
- better closet compression → shipped once, reduces every future customer's context spend
- better routing → shipped once, improves every future customer's synthesized-answer quality

The only work that does not compound is bespoke per-customer customization, which is why feature requests from the landing page should be routed into the stack-spec compiler schema rather than into bespoke installs. The compiler is the product.

## What the skill does not do

This skill is an orientation layer. It does not:

- reimplement the `bin/brain` CLI (it wraps it)
- reimplement the MCP tools (it calls them via `scripts/provision.sh` and `scripts/health.sh --remote`)
- rebuild the stack-spec compiler (the installer ships it; the skill does not touch compiler internals)
- host its own payment rail (payment is whatever the MCP returns)

If a user needs behavior beyond what the CLI or the MCP tools expose, the correct path is to extend the upstream surface, not to add logic to this skill.
