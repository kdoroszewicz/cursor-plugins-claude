# Sentry Plugin for Cursor

A Cursor plugin that helps developers integrate [Sentry](https://sentry.io) error monitoring, performance tracking, session replay, and alerting into their projects.

## Features

- **Rules** — Coding best practices for Sentry SDK integration and performance monitoring, applied automatically when editing JS/TS files.
- **Agents** — A specialized debug agent that triages Sentry issues, analyzes stack traces and breadcrumbs, and suggests fixes.
- **Skills** — Step-by-step guides for setting up Sentry in Next.js, React, Node.js, and Python projects, and for configuring alerts.
- **Hooks** — Pre-deploy hook that creates Sentry releases, uploads source maps, and records deployments.
- **MCP Server** — Connects to the Sentry MCP server to expose issues, events, releases, and performance data directly to AI agents.

## Directory Structure

```
plugins/sentry/
├── .cursor/
│   └── plugin.json          # Plugin manifest
├── agents/
│   └── sentry-debug-agent.md  # Debug/triage agent
├── extensions/               # Reserved for future extensions
├── hooks/
│   └── hooks.json           # Pre-deploy hook definitions
├── mcp.json                 # MCP server configuration
├── rules/
│   ├── sentry-integration.mdc  # SDK integration best practices
│   └── sentry-performance.mdc  # Performance monitoring best practices
├── scripts/
│   └── sentry-release.sh    # Release creation script
├── skills/
│   ├── configure-alerts/
│   │   └── SKILL.md         # Alert configuration guide
│   └── setup-sentry/
│       └── SKILL.md         # Project setup guide
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Quick Start

### 1. Install the Plugin

Copy or symlink the `plugins/sentry/` directory into your Cursor workspace.

### 2. Set Environment Variables

The plugin requires the following environment variables for full functionality:

| Variable | Required | Description |
|---|---|---|
| `SENTRY_DSN` | Yes | Sentry project DSN |
| `SENTRY_ORG` | For releases/MCP | Sentry organization slug |
| `SENTRY_PROJECT` | For releases/MCP | Sentry project slug |
| `SENTRY_AUTH_TOKEN` | For releases/MCP | Sentry API auth token |
| `SENTRY_ENVIRONMENT` | No | Deployment environment (default: `production`) |
| `SENTRY_RELEASE` | No | Release version (default: git short SHA) |

### 3. Use the Plugin

- **Rules** activate automatically when you edit `.ts`, `.tsx`, `.js`, or `.jsx` files, providing inline guidance on Sentry best practices.
- **Skills** are available as step-by-step guides — ask Cursor to "set up Sentry" or "configure Sentry alerts."
- **The debug agent** can be invoked to triage Sentry issues — paste an error from Sentry and ask for analysis.
- **Hooks** run automatically during deployment workflows to create releases and upload source maps.
- **MCP Server** connects Cursor's AI to your Sentry data for querying issues, events, and performance metrics.

## Rules

### `sentry-integration.mdc`

Best practices for SDK initialization, DSN management, breadcrumbs, user context, error capturing, `beforeSend` filtering, React error boundaries, source maps, and release/environment tagging.

### `sentry-performance.mdc`

Best practices for custom transactions, child spans, transaction naming, sample rate configuration, CPU profiling, and Web Vitals tracking.

## Skills

### Setup Sentry (`skills/setup-sentry/SKILL.md`)

Framework-specific setup instructions for:
- **Next.js** — Wizard-based setup, client/server config, source maps, error boundaries.
- **React (Vite)** — Manual SDK setup, Vite plugin for source maps, error boundary.
- **Node.js (Express)** — Instrumentation, Express error handler, profiling.
- **Python (Django / Flask / FastAPI)** — `sentry-sdk` init, auto-instrumentation.

### Configure Alerts (`skills/configure-alerts/SKILL.md`)

- Issue alerts (new errors, regressions, volume spikes)
- Metric alerts (error rates, latency, Apdex, failure rates, crash-free rate)
- Uptime monitors (HTTP health checks)
- Cron monitors (scheduled job tracking)
- Alert routing best practices

## Pre-Deploy Hook

The `sentry-release.sh` script (triggered by `hooks.json`) performs:

1. Creates a new Sentry release
2. Associates git commits
3. Uploads source maps
4. Finalizes the release
5. Records the deployment

## MCP Server

The plugin uses the official `@sentry/mcp-server` package. Available tools:

- `list_issues` — Query unresolved issues
- `get_issue` / `get_event` — Detailed issue and event data
- `search_events` — Search with Sentry query syntax
- `resolve_issue` / `assign_issue` — Issue management
- `get_performance_summary` — Transaction performance metrics

## License

MIT — see [LICENSE](./LICENSE).
