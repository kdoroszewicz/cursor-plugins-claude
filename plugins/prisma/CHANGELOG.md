# Changelog

All notable changes to the Prisma Cursor Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-08

### Added

- Initial release of the Prisma Cursor Plugin.
- `prisma-schema.mdc` rule for Prisma schema best practices (PascalCase models, camelCase fields, relations, indexes, native types, cascade rules, enums, timestamps, composite types, model-level documentation, `@map`/`@@map` database mapping).
- `prisma-queries.mdc` rule for Prisma Client query best practices (singleton pattern, select/include, transactions, error handling with `PrismaClientKnownRequestError`, cursor-based pagination, batch operations, middleware for logging/soft-delete, `Prisma.validator` for type-safe queries, N+1 avoidance, `queryRawUnsafe` prohibition).
- Prisma Schema Design Agent for schema design, migration planning, query optimization, N+1 detection, and serverless configuration.
- Setup Prisma skill with step-by-step installation, schema creation, migration, seeding, and client generation workflow.
- Create Prisma Migration skill covering migration creation, breaking change handling, conflict resolution, production deployment, and squashing.
- File-change hooks for auto-generating Prisma Client and formatting schema on save.
- Notification hooks for new migrations and seed file changes.
- MCP server configuration for Prisma database introspection and schema management.
- `prisma-generate.sh` script for client generation, schema validation, formatting, push, pull, and migration management.
- `prisma-setup.sh` script for project initialization and common Prisma operations.
