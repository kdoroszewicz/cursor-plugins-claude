# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-23

### Added

- Initial release of the Audit Prompt Capture plugin
- Complete hook coverage for all Cursor agent hooks:
  - `pre-prompt` / `post-prompt` - Capture prompts
  - `pre-response` / `post-response` - Capture responses
  - `pre-tool-call` / `post-tool-call` - Capture tool executions
  - `pre-file-edit` / `post-file-edit` - Capture file changes
  - `pre-command` / `post-command` - Capture shell commands
  - `session-start` / `session-end` - Capture session lifecycle
  - `context-attach` - Capture context attachments
  - `model-switch` - Capture model changes
  - `error` - Capture errors
- Configurable HTTP/HTTPS endpoint for audit data
- Support for Bearer token and API key authentication
- Local file logging option
- Data anonymization for sensitive information
- Automatic retry with exponential backoff
- MCP server with tools for querying audit data:
  - `get_audit_stats` - Statistics about audit events
  - `query_audit_log` - Query local audit log
  - `export_audit_log` - Export to JSON/CSV/NDJSON
  - `test_endpoint` - Test endpoint connectivity
- Comprehensive documentation
