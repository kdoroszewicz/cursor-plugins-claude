# Prisma Cursor Plugin

A comprehensive Cursor plugin for [Prisma ORM](https://www.prisma.io/) that helps developers design database schemas, write efficient queries, manage migrations, and optimize performance.

## Features

- **Schema Design Rules** — Best practices for Prisma schema files, including model naming, relations, indexes, database mapping, composite types, and referential actions.
- **Query Best Practices Rules** — Guidelines for using Prisma Client effectively with singleton patterns, error handling, pagination, middleware, soft-delete, and type-safe queries with `Prisma.validator`.
- **Schema Design Agent** — An AI agent specialized in database schema design, migration planning, query optimization, and N+1 detection.
- **Setup Skill** — Step-by-step guide for adding Prisma to a new or existing project.
- **Migration Skill** — Complete workflow for creating, managing, and deploying database migrations safely.
- **Auto-generation Hooks** — Automatically regenerate the Prisma Client and format the schema when files change.
- **MCP Server Integration** — Database introspection and schema management via MCP.
- **Helper Scripts** — CLI scripts for common Prisma operations (generate, migrate, seed, reset, etc.).

## Structure

```
plugins/prisma/
├── .cursor/
│   └── plugin.json                  # Plugin manifest
├── agents/
│   └── prisma-schema-agent.md       # Schema design AI agent
├── rules/
│   ├── prisma-schema.mdc            # Schema best practices
│   └── prisma-queries.mdc           # Query best practices
├── skills/
│   ├── setup-prisma/
│   │   └── SKILL.md                 # Project setup guide
│   └── create-prisma-migration/
│       └── SKILL.md                 # Migration workflow guide
├── hooks/
│   └── hooks.json                   # File-change hooks
├── scripts/
│   ├── prisma-generate.sh           # Generate and schema management script
│   └── prisma-setup.sh              # Setup and migration helper script
├── extensions/                      # Reserved for extensions
├── mcp.json                         # MCP server configuration
├── README.md                        # This file
├── CHANGELOG.md                     # Version history
└── LICENSE                          # MIT License
```

## Usage

### Rules

Rules are automatically applied when editing matching files:

- **`prisma-schema.mdc`** — Activates when editing `.prisma` files. Provides guidance on model naming, relations, indexes, native types, cascade rules, enums, composite types, model documentation, and database mapping with `@map`/`@@map`.
- **`prisma-queries.mdc`** — Activates when editing `.ts`, `.tsx`, or `.js` files. Covers singleton patterns, select/include, error handling, transactions, pagination, middleware, soft-delete, `Prisma.validator`, and avoiding N+1 queries and `queryRawUnsafe`.

### Agent

The **Prisma Schema Agent** can be invoked to help with:

- Designing new database schemas from requirements
- Adding relations, indexes, and constraints
- Planning multi-step migrations for breaking changes
- Detecting and fixing N+1 query patterns
- Optimizing queries with `EXPLAIN ANALYZE`
- Configuring connection pooling for serverless deployments

### Skills

- **Setup Prisma** — Follow the step-by-step guide to add Prisma to your project, from installation through seeding.
- **Create Prisma Migration** — Learn the complete migration workflow: creating, reviewing, deploying, handling breaking changes, resolving conflicts, and squashing migrations.

### Hooks

When Prisma schema files are modified, the plugin automatically:

1. Runs `npx prisma generate` to regenerate the client
2. Runs `npx prisma format` to format the schema

### Helper Scripts

```bash
# Make the scripts executable
chmod +x plugins/prisma/scripts/prisma-generate.sh
chmod +x plugins/prisma/scripts/prisma-setup.sh

# Generate Prisma Client (default)
./scripts/prisma-generate.sh

# Validate schema
./scripts/prisma-generate.sh validate

# Format schema
./scripts/prisma-generate.sh format

# Create a migration
./scripts/prisma-generate.sh migrate add_users_table

# Deploy to production
./scripts/prisma-generate.sh deploy

# Initialize Prisma with PostgreSQL
./scripts/prisma-setup.sh init postgresql

# Seed the database
./scripts/prisma-setup.sh seed

# Open Prisma Studio
./scripts/prisma-setup.sh studio
```

## Requirements

- Node.js v18 or later
- Prisma CLI (`npm install prisma --save-dev`)
- A supported database (PostgreSQL, MySQL, SQLite, SQL Server, MongoDB, CockroachDB)

## License

MIT — see [LICENSE](./LICENSE) for details.
