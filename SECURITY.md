# Security Policy

## Supported Versions

The following skill versions currently receive security updates:

| Skill | Version | Supported |
|---|---|---|
| cost-optimization | 0.2.0 | Yes |
| brainofbrains | 0.1.0 | Yes |
| elasticjudge | 0.1.0 | Yes |

## Reporting a Vulnerability

Email **johnhavenbradley@gmail.com** with the subject line:

```
Security: ai-performance-skills
```

Please include a description of the issue, steps to reproduce, and any relevant environment details. You will receive an acknowledgment within 48 hours.

**Do not open a public GitHub issue for security reports.** Public disclosure before a fix is available puts all users at risk.

## Security Posture

This project is built around three security principles:

1. **Local-first** — all analysis runs on your machine. No data leaves your device unless you explicitly opt in to share-back.
2. **No default MCP** — the Model Context Protocol server is not enabled by default. You must deliberately configure and start it.
3. **Opt-in share-back only** — telemetry and result sharing require explicit user action. Nothing is uploaded automatically.

## Scope

### In Scope

The following classes of issues are in scope for responsible disclosure:

- Script injection risks in shell scripts under `*/scripts/`
- API key handling and credential exposure in `elasticjudge` scripts
- Unintended network call destinations (i.e., data leaving the machine without user consent)
- Privilege escalation through MCP server configuration

### Out of Scope

The following are not in scope:

- npm supply chain attacks against third-party dependencies
- Vulnerabilities in third-party CLI internals (e.g., `pulser-cli`, `shellcheck`)
- Issues that require physical access to the machine
- Social engineering attacks targeting project maintainers
