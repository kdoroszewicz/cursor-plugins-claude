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
| `teaching` | [Teaching](teaching/) | Cursor | Utilities | Skill mapping, practice plans, and learning retrospectives. |
| `continual-learning` | [Continual Learning](continual-learning/) | Eric Zakariasson | Developer Tools | Incremental transcript-driven memory updates for AGENTS.md using high-signal bullet points only. |
| `cursor-team-kit` | [Cursor Team Kit](cursor-team-kit/) | Eric Zakariasson | Developer Tools | Internal team workflows for CI, code review, shipping, local automation, and verification. |
| `thermos` | [Thermos](thermos/) | Cursor | Developer Tools | Thermo-nuclear branch review: deep security/correctness audits, harsh code-quality rubrics, parallel subagents, thermos orchestration, and optional merge-ready PR flows. |
| `create-plugin` | [Create Plugin](create-plugin/) | Cursor | Developer Tools | Scaffold and validate new agent plugins. |
| `ralph-loop` | [Ralph Loop](ralph-loop/) | Cursor | Developer Tools | Iterative self-referential AI loops using the Ralph Wiggum technique. |
| `agent-compatibility` | [Agent Compatibility](agent-compatibility/) | Cursor | Developer Tools | CLI-backed repo compatibility scans plus agents that audit startup, validation, and docs against reality. |
| `cli-for-agent` | [CLI for Agents](cli-for-agent/) | Eric Zakariasson | Developer Tools | Patterns for designing CLIs that coding agents can run reliably: flags, help with examples, pipelines, errors, idempotency, dry-run. |
| `pr-review-canvas` | [PR Review Canvas](pr-review-canvas/) | Cursor | Developer Tools | Render PR diffs as review canvases grouped by importance. |
| `docs-canvas` | [Docs Canvas](docs-canvas/) | Cursor | Developer Tools | Render documentation as a navigable canvas. |
| `cursor-sdk` | [Cursor SDK](cursor-sdk/) | Cursor | Developer Tools | Build apps, scripts, and automations with the TypeScript SDK. |
| `origin-apps` | [Origin Apps](origin-apps/) | Cursor | Developer Tools | Skills for building on the Cursor Origin API. Fetch the live spec first, then follow the Origin rules for credentials, scopes, webhooks, paging, and errors. Includes a skill that plans the port of an existing GitHub App. |
| `orchestrate` | [Orchestrate](orchestrate/) | Cursor | Developer Tools | Fan large tasks out across parallel cloud agents with planners, workers, verifiers, and structured handoffs. |
| `pstack` | [pstack](harness/pstack/claude-code/) | Lauren Tan | Developer Tools | if you want to go fast, go deep first. pstack helps you write less, but higher quality code. rigorous agent workflows you can parallelize with confidence. |
| `dyl-stack` | [dyl-stack](dyl-stack/) | Dylan Gattey | Developer Tools | Dylan's agent style on top of pstack: root causes over symptom patches, The Algorithm before design, terse verified delivery, a PR review that fits in a paste, and Figma-to-UI with a visual judge. |
| `grok-voice` | [Grok Voice](grok-voice/) | Eric Zakariasson | Developer Tools | Add Grok voice to an app: realtime speech-to-speech, speech-to-text dictation, text-to-speech read-aloud, and a log-driven fix loop for voice sessions. |

Author values match each plugin's `plugin.json` `author.name` (Cursor lists `plugins@cursor.com` in the manifest).

Not included: `advisor` (it runs on Cursor-only hook events) and the MCP integrations under [`third_party/`](third_party/).

## What changed from upstream

Upstream's own `.claude-plugin/marketplace.json` lists only `origin-apps` and `pstack`. This fork extends it to the plugins above by adding a `.claude-plugin/plugin.json` inside each one. `pstack` installs from upstream's generated Claude Code tree in `harness/pstack/claude-code/`. No plugin logic or rules have been modified — the plugins behave identically to their upstream versions.

## Keeping up to date

This repo tracks [cursor/plugins](https://github.com/cursor/plugins). When upstream publishes new plugins or updates, this fork will be rebased to include them. The sync workflow is documented in the [sync-fork skill](.claude/skills/sync-fork/SKILL.md) — use it to ensure all manifests stay in sync.

## License

MIT
