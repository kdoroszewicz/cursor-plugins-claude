# Datadog Plugin for Cursor

A Cursor plugin that helps developers integrate [Datadog](https://www.datadoghq.com) APM, logging, metrics, monitors, and observability into their projects.

## Features

- **Rules** — Coding best practices for Datadog APM instrumentation and structured logging, applied automatically when editing JS/TS/Python files.
- **Agents** — A specialized observability agent that helps set up dashboards, monitors, SLOs, and troubleshoot performance issues using APM data.
- **Skills** — Step-by-step guides for setting up Datadog APM in Express, Next.js, Django, and Flask projects, and for creating monitors.
- **Hooks** — Pre-deploy hook that validates dd-trace instrumentation, unified service tags, and checks for hardcoded secrets.
- **MCP Server** — Connects to the Datadog MCP server to expose metrics, traces, logs, monitors, and dashboards directly to AI agents.

## Directory Structure

```
plugins/datadog/
├── .cursor/
│   └── plugin.json              # Plugin manifest
├── agents/
│   └── datadog-observability-agent.md  # Observability agent
├── extensions/                  # Reserved for future extensions
├── hooks/
│   └── hooks.json               # Pre-deploy hook definitions
├── mcp.json                     # MCP server configuration
├── rules/
│   ├── datadog-instrumentation.mdc  # APM & tracing best practices
│   └── datadog-logging.mdc         # Logging best practices
├── scripts/
│   └── check-instrumentation.sh # Instrumentation validation script
├── skills/
│   ├── create-monitors/
│   │   └── SKILL.md             # Monitor creation guide
│   └── setup-datadog-apm/
│       └── SKILL.md             # APM setup guide
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Quick Start

### 1. Install the Plugin

Copy or symlink the `plugins/datadog/` directory into your Cursor workspace.

### 2. Set Environment Variables

The plugin requires the following environment variables for full functionality:

| Variable | Required | Description |
|---|---|---|
| `DD_API_KEY` | Yes | Datadog API key |
| `DD_APP_KEY` | For MCP/monitors | Datadog Application key |
| `DD_SITE` | No | Datadog site (default: `datadoghq.com`) |
| `DD_SERVICE` | Yes | Logical service name |
| `DD_ENV` | Yes | Deployment environment (`production`, `staging`, `development`) |
| `DD_VERSION` | Recommended | Application version (git SHA or semver) |
| `DD_AGENT_HOST` | For APM | Datadog Agent hostname (default: `localhost`) |
| `DD_TRACE_AGENT_PORT` | No | APM trace port (default: `8126`) |
| `DD_LOGS_INJECTION` | Recommended | Enable trace–log correlation (default: `false`) |

### 3. Use the Plugin

- **Rules** activate automatically when you edit `.ts`, `.js`, or `.py` files, providing inline guidance on Datadog APM and logging best practices.
- **Skills** are available as step-by-step guides — ask Cursor to "set up Datadog APM" or "create Datadog monitors."
- **The observability agent** can help design dashboards, configure monitors, define SLOs, and troubleshoot performance issues.
- **Hooks** run automatically during deployment workflows to validate instrumentation before deploying.
- **MCP Server** connects Cursor's AI to your Datadog data for querying metrics, traces, logs, and monitors.

## Rules

### `datadog-instrumentation.mdc`

Best practices for dd-trace initialization, unified service tagging (`env`, `service`, `version`), custom spans for business logic, meaningful service/resource names, tag usage, sampling rate configuration, distributed trace context propagation, trace–log correlation, sensitive data handling, and error tracking in traces.

### `datadog-logging.mdc`

Best practices for structured JSON logging, trace_id/span_id correlation, proper log levels, meaningful attributes, avoiding sensitive data in logs, log pipelines and processors, log indexes and retention, exclusion filters, and Datadog-compatible transports for pino, winston, bunyan, and Python logging.

## Skills

### Setup Datadog APM (`skills/setup-datadog-apm/SKILL.md`)

Framework-specific APM setup instructions for:
- **Node.js (Express)** — dd-trace initialization, custom spans, error handling, DogStatsD.
- **Next.js** — Instrumentation hook, API route tracing, Server Component spans.
- **Python (Django)** — ddtrace-run, manual initialization, custom spans.
- **Python (Flask)** — ddtrace-run, manual patching, route tracing.
- **Infrastructure** — Docker Compose and Kubernetes (Helm) Agent configuration.

### Create Monitors (`skills/create-monitors/SKILL.md`)

- Metric monitors (CPU, memory, disk, custom business metrics)
- APM monitors (P95 latency, error rate, Apdex, request volume)
- Log monitors (error volume, specific patterns, auth failures, missing logs, slow queries)
- Composite monitors (latency + errors, infra + app, multi-service, canary)
- Alert conditions, notifications, escalation, and monitor-as-code (Terraform)

## Pre-Deploy Hook

The `check-instrumentation.sh` script (triggered by `hooks.json`) validates:

1. dd-trace / ddtrace is listed as a project dependency
2. Tracer is initialized in source files
3. Unified service tags are configured (`DD_ENV`, `DD_SERVICE`, `DD_VERSION`)
4. Log injection is enabled for trace–log correlation
5. No hardcoded API keys or secrets in source files

## MCP Server

The plugin connects to the Datadog MCP server. Available tools:

- `list_monitors` / `get_monitor` — Query and inspect monitors
- `search_traces` / `get_trace` — Search and retrieve APM traces
- `query_metrics` — Query Datadog metrics with aggregation
- `search_logs` — Search logs with Datadog query syntax
- `list_services` / `get_service_summary` — Service catalog and APM summaries
- `list_dashboards` — List available dashboards
- `get_slo` — SLO status and error budget
- `create_monitor` / `mute_monitor` — Monitor management

## License

MIT — see [LICENSE](./LICENSE).
