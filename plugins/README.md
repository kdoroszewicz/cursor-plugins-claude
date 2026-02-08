# Cursor Plugins

This directory contains official plugins for Cursor.

## Plugin Structure

Each plugin follows a standard structure:

```
plugin-name/
├── .cursor/
│   └── plugin.json        # Plugin manifest (required)
├── README.md              # Plugin documentation
├── rules/                 # Cursor rules (.mdc files)
├── agents/                # Subagents (markdown files)
├── skills/                # Agent skills (directories with SKILL.md)
├── hooks/
│   └── hooks.json         # Hook configuration
├── mcp.json               # MCP server definitions (optional)
├── extensions/            # VS Code extensions (.vsix files)
├── scripts/               # Utility scripts for hooks
├── LICENSE
└── CHANGELOG.md
```

## Plugin Components

| Component       | Location              | Purpose                                  |
|:----------------|:----------------------|:-----------------------------------------|
| **Manifest**    | `.cursor/plugin.json` | Required metadata file                   |
| **Rules**       | `rules/`              | Cursor rules (.mdc files)                |
| **Agents**      | `agents/`             | Subagent Markdown files                  |
| **Skills**      | `skills/`             | Agent Skills with SKILL.md files         |
| **Hooks**       | `hooks/hooks.json`    | Hook configuration                       |
| **MCP servers** | `mcp.json`            | MCP server definitions                   |
| **Extensions**  | `extensions/`         | VS Code extension bundles (.vsix files)  |

## Creating a Plugin

1. Create a new directory under `plugins/`
2. Add a `.cursor/plugin.json` manifest file
3. Add your components (rules, agents, skills, hooks, etc.)
4. Add a `README.md` documenting your plugin

See the `boilerplate` directory for a complete example.

## Plugin Manifest

The `.cursor/plugin.json` manifest is required and defines your plugin's metadata:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A brief description of what your plugin does",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "license": "MIT",
  "keywords": ["example"],
  "agents": "./agents/",
  "skills": "./skills/",
  "rules": "./rules/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./mcp.json",
  "extensions": "./extensions/"
}
```

## Available Plugins

### Template

| Plugin        | Category    | Description                                              |
|:--------------|:------------|:---------------------------------------------------------|
| `boilerplate` | utilities   | Complete example plugin demonstrating all components     |

### Developer Tools

| Plugin          | Category         | Description                                                              |
|:----------------|:-----------------|:-------------------------------------------------------------------------|
| `github`        | developer-tools  | GitHub Actions, API, CLI, Pull Requests, and repository management       |
| `docker`        | developer-tools  | Dockerfiles, Compose, multi-stage builds, and container best practices   |
| `launchdarkly`  | developer-tools  | Feature flags, experimentation, progressive rollouts, and targeting      |

### Backend & Database

| Plugin      | Category | Description                                                                  |
|:------------|:---------|:-----------------------------------------------------------------------------|
| `prisma`    | backend  | ORM, schema design, migrations, and database management                      |
| `supabase`  | backend  | Postgres database, authentication, storage, realtime, and Edge Functions     |
| `firebase`  | backend  | Firestore, Authentication, Cloud Functions, Hosting, and Storage             |
| `mongodb`   | backend  | Schema design, queries, aggregation, indexes, and Mongoose ODM               |

### Infrastructure & Deployment

| Plugin        | Category        | Description                                                            |
|:--------------|:----------------|:-----------------------------------------------------------------------|
| `aws`         | infrastructure  | Lambda, S3, DynamoDB, CDK, IAM, and cloud infrastructure              |
| `cloudflare`  | infrastructure  | Workers, Pages, R2, D1, KV, and edge computing                        |
| `vercel`      | deployment      | Deployments, serverless functions, Edge Runtime, and project config    |

### SaaS & APIs

| Plugin    | Category | Description                                                              |
|:----------|:---------|:-------------------------------------------------------------------------|
| `stripe`  | saas     | Payment processing, subscriptions, webhooks, and billing integration     |
| `twilio`  | saas     | SMS, Voice, WhatsApp, Verify, and communications APIs                    |
| `slack`   | saas     | Bolt framework, Block Kit, Events API, and Slack app development         |

### Observability

| Plugin    | Category       | Description                                                          |
|:----------|:---------------|:---------------------------------------------------------------------|
| `sentry`  | observability  | Error monitoring, performance tracking, session replay, and alerting |
| `datadog` | observability  | APM, logging, metrics, monitors, and observability                   |

## Installation

Plugins can be installed via CLI:

```bash
agent install <plugin-name>
```

Or from a marketplace:

```bash
agent install <plugin-name>@<marketplace>
```

## Contributing

When adding a new plugin:

1. Follow the standard directory structure
2. Include a comprehensive README.md
3. Use semantic versioning (MAJOR.MINOR.PATCH)
4. Include a LICENSE file
5. Test your plugin thoroughly before submitting
