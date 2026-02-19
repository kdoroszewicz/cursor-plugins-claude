# cursor-plugins-claude

[Cursor's official plugins](https://github.com/cursor/plugins) adapted for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

Cursor ships a set of high-quality agent plugins — rules, skills, and MCP integrations — but they target Cursor's own runtime. This fork adds the `.claude-plugin/` manifests that Claude Code needs, so you can install the same plugins with a single command.

## Quick start

```sh
# 1. Add the marketplace
/plugin marketplace add kdoroszewicz/cursor-plugins-claude

# 2. Install any plugin
/plugin install cursor-team-kit@cursor-plugins-claude
```

You can install as many plugins as you need:

```sh
/plugin install continual-learning@cursor-plugins-claude
/plugin install teaching@cursor-plugins-claude
```

## Available plugins

| `name` | Plugin | Author | Category | `description` (from marketplace) |
|:-------|:-------|:-------|:---------|:-------------------------------------|
| `continual-learning` | [Continual Learning](continual-learning/) | Cursor | Developer Tools | Incremental transcript-driven memory updates for AGENTS.md using high-signal bullet points only. |
| `cursor-team-kit` | [Cursor Team Kit](cursor-team-kit/) | Cursor | Developer Tools | Internal team workflows used by Cursor developers for CI, code review, shipping, local automation, and verification. |
| `thermos` | [Thermos](thermos/) | Cursor | Developer Tools | Thermo-nuclear branch review: deep security/correctness audits, harsh code-quality rubrics, parallel subagents, thermos orchestration, and optional merge-ready PR flows. |
| `create-plugin` | [Create Plugin](create-plugin/) | Cursor | Developer Tools | Scaffold and validate new Cursor plugins. |
| `agent-compatibility` | [Agent Compatibility](agent-compatibility/) | Cursor | Developer Tools | CLI-backed repo compatibility scans plus Cursor agents that audit startup, validation, and docs against reality. |
| `cli-for-agent` | [CLI for Agents](cli-for-agent/) | Cursor | Developer Tools | Patterns for designing CLIs that coding agents can run reliably: flags, help with examples, pipelines, errors, idempotency, dry-run. |
| `pr-review-canvas` | [PR Review Canvas](pr-review-canvas/) | Cursor | Developer Tools | Render PR diffs as interactive Cursor Canvases organized for reviewer comprehension — groups changes by importance, separates boilerplate from core logic, and highlights tricky or unexpected code. |
| `docs-canvas` | [Docs Canvas](docs-canvas/) | Cursor | Developer Tools | Render documentation — architecture notes, API references, runbooks, and codebase walkthroughs — as a navigable Cursor Canvas with sections, table of contents, diagrams, and cross-references. |
| `cursor-sdk` | [Cursor SDK](cursor-sdk/) | Cursor | Developer Tools | Build apps, scripts, CI pipelines, and automations on top of the Cursor TypeScript SDK (@cursor/sdk) — runtime selection, auth, streaming, MCP, error handling, and ready-to-extend integration patterns. |
| `orchestrate` | [Orchestrate](orchestrate/) | Cursor | Developer Tools | Fan large tasks out across parallel Cursor cloud agents with planners, workers, verifiers, and structured handoffs. |
| `pstack` | [pstack](pstack/) | Lauren Tan | Developer Tools | if you want to go fast, go deep first. pstack helps you write less, but higher quality code. rigorous agent workflows you can parallelize with confidence. |
| `ralph-loop` | [Ralph Loop](ralph-loop/) | Cursor | Developer Tools | Iterative self-referential AI loops using the Ralph Wiggum technique. |
| `teaching` | [Teaching](teaching/) | Cursor | Developer Tools | Skill maps, practice plans, and feedback loops. |

## What changed from upstream

This fork adds a `.claude-plugin/` directory at the repo root and inside each plugin, containing the marketplace and plugin manifests required by Claude Code. No plugin logic or rules have been modified — the plugins behave identically to their upstream versions.

## Keeping up to date

This repo tracks [cursor/plugins](https://github.com/cursor/plugins). When upstream publishes new plugins or updates, this fork will be rebased to include them. The sync workflow is documented in the [sync-fork skill](.claude/skills/sync-fork/SKILL.md) — use it to ensure all manifests stay in sync.

## License

MIT
