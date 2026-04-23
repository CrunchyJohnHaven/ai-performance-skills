# Architecture

How the BrainOfBrains product is delivered, paid for, and operated. This file covers the A2A (agent-to-agent) distribution model and the local-only operating posture once installed.

## The thesis

BrainOfBrains is A2A *distribution*, not A2A *software*. The product — a self-improving specialist-brain substrate — stays the same regardless of who installs it. The GTM is machine-callable: a customer's agent arrives, quotes, pays, and installs. John-time per customer trends toward zero. Engineering time compounds across every customer because every customer runs the same install recipe against the same install compiler.

## v0.1 surface

The public wrapper currently targets three hosted surfaces under `https://brainofbrains.ai/mcp`:

| Tool | Purpose | Input | Output |
| --- | --- | --- | --- |
| `quote(stack_description)` | price an install | free-text stack description | service-defined quote response |
| provision endpoint | run the managed install | the same `stack_description`, with an optional payment token header | service-defined provision response plus next-step install instructions |
| `health_check(install_id)` | confirm an install is alive | install ID returned by provision | latest hosted health response for that install |

The hosted endpoints are the only always-on surface the product exposes. There is no web dashboard to log into, no background process on the customer's machine calling home, and no default telemetry pipe. A customer who never touches the hosted path again after install still gets a functional local substrate.

## Payment rail

- **Primary**: x402 (agent-native HTTP 402). Cloudflare has native x402 support; the Worker in front of `provision` returns 402 with the quote, the customer's agent pays, and the 402 challenge is satisfied. No browser-mediated checkout is required.
- **Fallback**: Stripe Checkout. If the customer's agent cannot speak x402, `quote` returns a Stripe Checkout URL instead. A human can complete checkout; the resulting payment token is accepted by `provision` the same way x402 payment tokens are.

Either way, `provision` returns the same kind of response: service-defined install instructions plus whatever proof of payment the hosted path requires. The payment rail is a swap; the provision contract stays constant.

## Delivery

The current public wrapper assumes `provision` returns service-defined install instructions. Depending on the hosted implementation, that may be a tarball URL, an install script URL, or a manual handoff page. `scripts/provision.sh` prints the raw response and asks the operator to follow the returned instructions.

## Infrastructure

- **Cloudflare Worker** — stateless provisioning logic. Receives MCP calls, compiles the install request, and returns the next-step instructions the hosted path needs.
- **Cloudflare Durable Object** — install records and payment state. One DO instance per install ID; survives Worker restarts; cheap at scale.
- **Cloudflare R2** — optional storage for hosted install payloads when the response includes downloadable artifacts.
- **Cloudflare DNS** — already holds `brainofbrains.ai`; the MCP route and the install-script route live on the same zone.

Near-zero infrastructure cost. Scales trivially. Matches the domain already being on Cloudflare, which is a hard rule for John's projects (see `feedback_cloudflare_cli.md`).

## The tradeoff — install reliability

Agentic delivery raises the install-reliability bar:

- Consulting-era install reliability: ~80% (a human is on the call to debug)
- A2A install reliability: ~99% (auto-refund kicks in below this)

This means **do not build the A2A layer first**. Build the deterministic install and the install compiler first, because those same components also make human-triggered setup frictionless. A2A is then a thin wrapper over the install pipeline, not a separate product.

The current dependency chain to unlock A2A:

1. Install script that runs cleanly on a fresh machine with no John intervention
2. `stack_description` compiler path solid enough that the hosted service can turn it into the install-specific state, tick scripts, and closet slots it needs
3. External health check that can prove the install worked (implemented as the `health_check` MCP tool — reads the install's `STATE.json`)
4. x402 integration on the Cloudflare Worker (Cloudflare has a template; this is trivial once 1–3 are solid)

This skill assumes the local installer works and that the hosted path is still an evolving surface. If the hosted endpoint is unavailable, `scripts/provision.sh` should fall back to the manual page instead of pretending a fuller managed flow exists.

## Local-only operation

Once installed, every brain operation is local:

- **Closet rebuilds** — `bin/brain closet` reads commits, meetings, KB artifacts from the local filesystem and writes updated `.aaak` files locally.
- **Ticks** — `bin/brain tick` runs the full loop (ingest, rebuild, recompute, snapshot) without touching the network.
- **Queries** — `bin/brain query` composes L0/L1/L2 context against local closets and returns a synthesized answer. The only outbound call a query makes is to whichever frontier model the calling agent chose, and that call is outside the substrate.
- **Health** — `bin/brain status` and `scripts/health.sh` read the local `STATE.json` and `brains.json` by default. The remote MCP `health_check` tool is only used when the user explicitly passes `--remote` (useful only for proving reliability to a buyer, not for day-to-day use).

No cloud dependency for normal use. A machine that drops off the internet after install still produces synthesized answers. This is the structural reason default-off-MCP is a coherent posture — the product does not need the MCP to function; only the buy-flow does.

## Why default-MCP is off

Default-MCP reads as surveillance-adjacent inside large organizations. The reasoning:

- an always-on MCP server is a process the customer's machine is hosting on the customer's behalf
- some MCP integrations ingest filesystem state, terminal output, or keystrokes — the category reads as surveillance to a skeptical employee
- employees who read "install the MCP server" as "my employer is watching me" opt out, permanently

The BrainOfBrains install does not need a local MCP server. The remote MCP at `brainofbrains.ai/mcp` is agent-callable for the buy-flow; after that, every brain operation happens through `bin/brain` on the local filesystem. If a local MCP surface is published later, treat it as opt-in; this bundle does not ship one today.

## Why A2A compounds

Each customer added compounds engineering time in one direction only:

- bugs in the install pipeline → fixed once, helps every future customer
- new specialist-brain templates → shipped once, available to every future customer via the hosted install compiler
- better closet compression → shipped once, reduces every future customer's context spend
- better routing → shipped once, improves every future customer's synthesized-answer quality

The only work that does not compound is bespoke per-customer customization, which is why feature requests from the landing page should be routed into the install compiler inputs rather than into bespoke installs. The compiler is the product.

## What the skill does not do

This skill is an orientation layer. It does not:

- reimplement the `bin/brain` CLI (it wraps it)
- reimplement the MCP tools (it calls them via `scripts/provision.sh` and `scripts/health.sh --remote`)
- rebuild the install compiler (the installer ships it; the skill does not touch compiler internals)
- host its own payment rail (payment is whatever the MCP returns)

If a user needs behavior beyond what the CLI or the MCP tools expose, the correct path is to extend the upstream surface, not to add logic to this skill.
