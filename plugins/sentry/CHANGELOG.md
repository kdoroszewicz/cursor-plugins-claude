# Changelog

All notable changes to the Sentry Cursor plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-07

### Added

- **Plugin manifest** (`.cursor/plugin.json`) with full metadata, keywords, and category.
- **Rules**
  - `sentry-integration.mdc` — Best practices for Sentry SDK initialization, DSN management, breadcrumbs, user context, error capturing with tags/extra/contexts, scoped context with `Sentry.withScope`, source map configuration, `beforeSend` data filtering, React error boundaries, and environment/release tagging.
  - `sentry-performance.mdc` — Best practices for custom transactions, child spans, meaningful transaction naming, `tracesSampleRate` configuration, CPU profiling with `@sentry/profiling-node`, and Web Vitals tracking.
- **Agents**
  - `sentry-debug-agent.md` — Specialized agent for triaging Sentry issues, analyzing stack traces and breadcrumbs, identifying common error patterns, and suggesting concrete fixes.
- **Skills**
  - `setup-sentry/SKILL.md` — Framework-specific Sentry setup for Next.js, React (Vite), Node.js (Express), and Python (Django/Flask/FastAPI), including source map configuration, error boundaries, and release management.
  - `configure-alerts/SKILL.md` — Guide for configuring issue alerts, metric alerts, uptime monitors, and cron monitors via UI and API, with recommended alert rules and routing best practices.
- **Hooks**
  - `hooks.json` — Pre-deploy hook definition that runs `sentry-release.sh` to create releases, upload source maps, and record deployments.
- **Scripts**
  - `sentry-release.sh` — Shell script for creating Sentry releases with commit association, source map upload, finalization, and deployment recording.
- **MCP Server**
  - `mcp.json` — Configuration for the `@sentry/mcp-server` with tools for listing issues, fetching events, managing releases, and querying performance data.
- **Documentation**
  - `README.md` — Plugin overview, directory structure, setup instructions, and usage guide.
  - `CHANGELOG.md` — This file.
  - `LICENSE` — MIT license.
