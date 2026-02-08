# Changelog

All notable changes to the MongoDB Cursor Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-08

### Added

- Initial release of the MongoDB Cursor Plugin.
- `mongodb-schema.mdc` rule for MongoDB schema design best practices (embedding vs referencing, data types, JSON Schema validation, discriminators, schema versioning, Subset/Bucket patterns, sharding, field naming, TTL indexes, capped collections).
- `mongodb-queries.mdc` rule for MongoDB query best practices (compound indexes with ESR rule, projections, aggregation pipelines with `$match`/`$lookup`/`$group`, cursor-based pagination, `bulkWrite`, duplicate key error handling, transactions with retry logic, change streams with resume tokens, `explain()` analysis, read/write concerns, native driver vs Mongoose guidance, connection management, error handling).
- MongoDB Schema Design Agent for document modeling, embedding vs referencing decisions, index strategies, aggregation pipeline optimization, sharding, change streams, Mongoose ODM guidance, and performance analysis.
- Setup MongoDB skill with step-by-step Node.js/TypeScript integration for both native driver and Mongoose, Docker Compose setup, connection singleton patterns, model definitions, and database seeding.
- Design Schema skill covering entity/access pattern analysis, embedding vs referencing decision framework, design pattern application (Subset, Bucket, Computed, Extended Reference), index creation, `explain()` validation, and JSON Schema collection validation.
- File-change hooks for model/schema file modifications, migration files, and Docker Compose changes.
- MCP server configuration using `mongodb-mcp-server` for database introspection and query execution.
- `mongodb-health.sh` script for connection checks, server info, database stats, collection details, replica set status, and index usage statistics.
