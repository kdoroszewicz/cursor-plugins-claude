# MongoDB Cursor Plugin

A comprehensive Cursor plugin for [MongoDB](https://www.mongodb.com/) that helps developers design document schemas, write efficient queries, build aggregation pipelines, manage indexes, and work with both the native MongoDB driver and Mongoose ODM.

## Features

- **Schema Design Rules** — Best practices for MongoDB document modeling, embedding vs referencing, data types, JSON Schema validation, discriminators, schema versioning, sharding, and field naming conventions.
- **Query Best Practices Rules** — Guidelines for indexing, projections, aggregation pipelines, cursor-based pagination, bulkWrite, duplicate key handling, transactions, change streams, explain() analysis, read/write concerns, and connection management.
- **Schema Design Agent** — An AI agent specialized in document schema design, embedding vs referencing decisions, index strategies (ESR rule), aggregation pipeline optimization, and Mongoose-specific guidance.
- **Setup Skill** — Step-by-step guide for connecting a Node.js/TypeScript application to MongoDB with both the native driver and Mongoose ODM.
- **Schema Design Skill** — Complete workflow for designing MongoDB schemas, choosing data patterns, creating indexes, and validating design decisions.
- **File-Change Hooks** — Notifications when model files, migrations, or Docker Compose files are modified.
- **MCP Server Integration** — Database introspection, querying, and aggregation via the MongoDB MCP server.
- **Health Check Script** — CLI script for checking MongoDB connectivity, server status, database stats, and index usage.

## Structure

```
plugins/mongodb/
├── .cursor/
│   └── plugin.json                  # Plugin manifest
├── agents/
│   └── mongodb-schema-agent.md      # Schema design AI agent
├── rules/
│   ├── mongodb-schema.mdc           # Schema design best practices
│   └── mongodb-queries.mdc          # Query and performance best practices
├── skills/
│   ├── setup-mongodb/
│   │   └── SKILL.md                 # MongoDB + Node.js setup guide
│   └── design-schema/
│       └── SKILL.md                 # Schema and index design workflow
├── hooks/
│   └── hooks.json                   # File-change hooks
├── scripts/
│   └── mongodb-health.sh            # Connection and health check script
├── extensions/                      # Reserved for extensions
├── mcp.json                         # MCP server configuration
├── README.md                        # This file
├── CHANGELOG.md                     # Version history
└── LICENSE                          # MIT License
```

## Usage

### Rules

Rules are automatically applied when editing matching files:

- **`mongodb-schema.mdc`** — Activates when editing `.ts`, `.js` files and files under `models/` or `schemas/` directories. Provides guidance on document modeling, embedding vs referencing, data types, validation, discriminators, schema versioning, sharding, and naming conventions.
- **`mongodb-queries.mdc`** — Activates when editing `.ts` and `.js` files. Covers indexing strategies, projections, aggregation pipelines, cursor-based pagination, bulkWrite, transactions, change streams, explain() analysis, read/write concerns, connection management, and error handling.

### Agent

The **MongoDB Schema Design Agent** can be invoked to help with:

- Designing document schemas from application requirements
- Choosing between embedding and referencing for each relationship
- Building compound, text, geospatial, and partial indexes
- Creating and optimizing aggregation pipelines
- Analyzing query performance with explain()
- Planning sharding strategies and shard key selection
- Configuring Mongoose schemas, middleware, virtuals, and discriminators
- Setting up change streams for real-time data patterns

### Skills

- **Setup MongoDB** — Follow the step-by-step guide to connect a Node.js/TypeScript app to MongoDB, including Docker setup, connection singletons, model creation, and seeding.
- **Design Schema** — Walk through the complete schema design workflow: identify entities and access patterns, choose embedding vs referencing, apply design patterns (Subset, Bucket, Computed, Extended Reference), create indexes, and validate with explain().

### Hooks

When model or schema files are modified, the plugin notifies you to:

1. Verify indexes match your query patterns
2. Review migration files before applying them
3. Restart Docker Compose if the MongoDB service configuration changed

### Health Check Script

```bash
# Make the script executable
chmod +x plugins/mongodb/scripts/mongodb-health.sh

# Basic health check (uses MONGODB_URI env var or localhost:27017)
./scripts/mongodb-health.sh

# Health check with a specific URI
./scripts/mongodb-health.sh "mongodb://localhost:27017/myapp"

# Detailed status including replica set info
./scripts/mongodb-health.sh --status

# Show index usage for all collections
./scripts/mongodb-health.sh --indexes
```

### MCP Server

The plugin configures the [MongoDB MCP server](https://github.com/mongodb-js/mongodb-mcp-server) for database introspection and management. Set the `MONGODB_URI` environment variable to enable it.

## Requirements

- Node.js v18 or later
- MongoDB 6.0+ (local, Docker, or MongoDB Atlas)
- mongosh CLI (for health check script)
- One of:
  - `mongoose` — for ODM-based development
  - `mongodb` — for native driver development

## License

MIT — see [LICENSE](./LICENSE) for details.
