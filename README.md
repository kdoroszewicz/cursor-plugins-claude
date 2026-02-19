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

### Developer Tools

| Plugin | Description |
|:-------|:------------|
| [Continual Learning](continual-learning/) | Incremental transcript-driven AGENTS.md memory updates with high-signal bullet points |
| [Cursor Team Kit](cursor-team-kit/) | Internal-style workflows for CI, code review, shipping, and testing |
| [Create Plugin](create-plugin/) | Scaffold and validate new Cursor plugins |
| [Ralph Loop](ralph-loop/) | Iterative self-referential AI loops using the Ralph Wiggum technique |

### Utilities

| Plugin | Description |
|:-------|:------------|
| [Teaching](teaching/) | Skill maps, practice plans, and feedback loops |

## What changed from upstream

This fork adds a `.claude-plugin/` directory at the repo root and inside each plugin, containing the marketplace and plugin manifests required by Claude Code. No plugin logic or rules have been modified — the plugins behave identically to their upstream versions.

## Keeping up to date

This repo tracks [cursor/plugins](https://github.com/cursor/plugins). When upstream publishes new plugins or updates, this fork will be rebased to include them. The sync workflow is documented in the [sync-fork skill](.claude/skills/sync-fork/SKILL.md) — use it to ensure all manifests stay in sync.

## License

MIT
