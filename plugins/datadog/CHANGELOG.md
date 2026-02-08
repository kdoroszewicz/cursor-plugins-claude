# Changelog

All notable changes to the Datadog Cursor plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-08

### Added

- **Plugin manifest** (`.cursor/plugin.json`) with full metadata, keywords, and category.
- **Rules**
  - `datadog-instrumentation.mdc` — Best practices for dd-trace initialization, unified service tagging (env, service, version), custom spans for business logic, meaningful service/resource names, span tags for filtering, sampling rate configuration, distributed trace context propagation, trace–log correlation, sensitive data handling in traces, and error tracking.
  - `datadog-logging.mdc` — Best practices for structured JSON logging, trace_id and span_id correlation, proper log levels, meaningful structured attributes, avoiding sensitive data, log pipelines and processors, log indexes and retention, exclusion filters, and Datadog transports for pino, winston, bunyan, and Python logging libraries.
- **Agents**
  - `datadog-observability-agent.md` — Specialized agent for comprehensive observability setup, dashboard design, monitor configuration, SLO management, performance troubleshooting using APM data, error tracking, and cost optimization.
- **Skills**
  - `setup-datadog-apm/SKILL.md` — Framework-specific APM setup for Node.js (Express), Next.js, Python (Django), and Python (Flask), including dd-trace initialization, custom instrumentation, error handling, DogStatsD custom metrics, Docker Compose and Kubernetes Agent configuration.
  - `create-monitors/SKILL.md` — Guide for creating metric monitors, APM monitors, log monitors, and composite monitors via UI and API, with recommended monitor patterns, alert conditions, notification routing, escalation configuration, and monitor-as-code with Terraform.
- **Hooks**
  - `hooks.json` — Pre-deploy hook definition that runs `check-instrumentation.sh` to validate Datadog instrumentation before deployment.
- **Scripts**
  - `check-instrumentation.sh` — Shell script that validates dd-trace dependency, tracer initialization, unified service tags, log injection configuration, and scans for hardcoded secrets.
- **MCP Server**
  - `mcp.json` — Configuration for the Datadog MCP server with tools for querying monitors, traces, metrics, logs, services, dashboards, and SLOs.
- **Documentation**
  - `README.md` — Plugin overview, directory structure, setup instructions, and usage guide.
  - `CHANGELOG.md` — This file.
  - `LICENSE` — MIT license.
