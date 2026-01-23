# Boilerplate Plugin

A boilerplate Cursor plugin demonstrating all available plugin components.

## Installation

```bash
agent install boilerplate
```

## Components

| Component | Description |
|:----------|:------------|
| **Rules** | Cursor rules for coding standards and conventions |
| **Agents** | Specialized subagents for specific tasks |
| **Skills** | Reusable agent skills with tools and scripts |
| **Hooks** | Pre/post execution hooks for automation |
| **MCP Servers** | Model Context Protocol server integrations |
| **Extensions** | VS Code extension bundles |

## Directory Structure

```
boilerplate/
├── .cursor/
│   └── plugin.json        # Plugin manifest (required)
├── rules/                 # Cursor rules
│   └── example-rule.mdc
├── agents/                # Subagent definitions
│   └── example-agent.md
├── skills/                # Agent skills
│   └── example-skill/
│       └── SKILL.md
├── hooks/                 # Hook configurations
│   └── hooks.json
├── mcp.json              # MCP server definitions
├── extensions/           # VS Code extensions (.vsix)
├── scripts/              # Utility scripts for hooks
├── LICENSE
├── CHANGELOG.md
└── README.md
```

## Rules

Rules in the `rules/` directory are automatically applied based on their configuration. Each rule is a `.mdc` file with frontmatter defining when it applies.

## Agents

Agents in the `agents/` directory define specialized subagents that can be invoked for specific tasks.

## Skills

Skills in the `skills/` directory are self-contained capabilities that agents can use. Each skill has a `SKILL.md` file that describes what it does and how to use it.

## Hooks

Hooks in `hooks/hooks.json` define automation that runs before or after certain events.

## MCP Servers

MCP server configurations in `mcp.json` define integrations with external tools and services.

## License

MIT
