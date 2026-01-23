# Audit Prompt Capture Plugin

A comprehensive Cursor plugin that captures all prompts, responses, tool calls, and other agent interactions using hooks and sends them to a configurable audit endpoint.

## Features

- **Complete Hook Coverage**: Captures all available Cursor hooks for comprehensive auditing
- **Configurable Endpoint**: Send audit data to any HTTP/HTTPS endpoint
- **Flexible Authentication**: Support for Bearer tokens and API keys
- **Local Logging**: Optional local file logging for offline audit trails
- **Data Anonymization**: Optional sensitive data redaction
- **Retry Logic**: Automatic retry with exponential backoff on failures
- **MCP Tools**: Query and export audit data via MCP tools

## Installation

```bash
cursor plugin install audit-prompt-capture
```

Or manually add the plugin to your workspace.

## Configuration

Configure the plugin using environment variables:

### Required

| Variable | Description |
|:---------|:------------|
| `AUDIT_ENDPOINT_URL` | URL to send audit events to |

### Optional

| Variable | Default | Description |
|:---------|:--------|:------------|
| `AUDIT_API_KEY` | - | API key for endpoint authentication |
| `AUDIT_LOG_LOCAL` | `false` | Also log events to local file |
| `AUDIT_LOG_PATH` | `./audit.log` | Path for local audit log |
| `AUDIT_BATCH_SIZE` | `1` | Events to batch before sending |
| `AUDIT_TIMEOUT_MS` | `5000` | Request timeout in milliseconds |
| `AUDIT_RETRY_COUNT` | `3` | Retry attempts on failure |
| `AUDIT_INCLUDE_CONTENT` | `true` | Include full content in audit |
| `AUDIT_ANONYMIZE` | `false` | Redact sensitive data |

### Example Configuration

```bash
# In your shell profile or .env file
export AUDIT_ENDPOINT_URL="https://your-audit-server.com/api/events"
export AUDIT_API_KEY="your-api-key"
export AUDIT_LOG_LOCAL="true"
export AUDIT_LOG_PATH="/var/log/cursor-audit.log"
```

## Captured Hooks

The plugin captures all available Cursor hooks:

### Prompt & Response Hooks

| Hook | Description |
|:-----|:------------|
| `pre-prompt` | Before a prompt is sent to the model |
| `post-prompt` | After a prompt has been processed |
| `pre-response` | Before a response is displayed |
| `post-response` | After a response is complete |

### Tool & Command Hooks

| Hook | Description |
|:-----|:------------|
| `pre-tool-call` | Before a tool is executed |
| `post-tool-call` | After a tool execution completes |
| `pre-command` | Before a shell command is executed |
| `post-command` | After a shell command completes |

### File Hooks

| Hook | Description |
|:-----|:------------|
| `pre-file-edit` | Before a file is edited |
| `post-file-edit` | After a file has been edited |

### Session & Context Hooks

| Hook | Description |
|:-----|:------------|
| `session-start` | When an agent session starts |
| `session-end` | When an agent session ends |
| `context-attach` | When context is attached (files, URLs) |
| `model-switch` | When the model is switched |
| `error` | When an error occurs |

## Audit Event Schema

Each audit event includes:

```json
{
  "id": "evt_1706000000000_abc123def456",
  "timestamp": "2024-01-23T12:00:00.000Z",
  "timestampUnix": 1706000000000,
  "hookType": "pre-prompt",
  "category": "prompt",
  "sessionId": "session_abc123",
  "metadata": {
    "hostname": "your-machine",
    "platform": "linux",
    "nodeVersion": "v20.0.0",
    "workingDirectory": "/path/to/workspace",
    "user": "username"
  },
  "payload": {
    "prompt": "Your prompt content here",
    "model": "claude-3-opus"
  }
}
```

## Endpoint Requirements

Your audit endpoint should:

1. Accept `POST` requests with `Content-Type: application/json`
2. Return `2xx` status codes on success
3. Handle the following headers:
   - `Authorization: Bearer <token>` (if API key configured)
   - `X-API-Key: <key>` (if API key configured)
   - `X-Audit-Event-Id: <event-id>`
   - `X-Audit-Hook-Type: <hook-type>`
   - `X-Audit-Session-Id: <session-id>`

### Example Endpoint (Express.js)

```javascript
const express = require('express');
const app = express();

app.use(express.json());

app.post('/api/events', (req, res) => {
  const event = req.body;
  console.log(`[${event.hookType}] ${event.id}`);
  
  // Store event in your database
  // await db.auditEvents.insert(event);
  
  res.status(200).json({ received: true });
});

app.listen(3000);
```

## MCP Tools

The plugin provides MCP tools for querying audit data:

### `get_audit_stats`

Get statistics about captured audit events.

```
Parameters:
- since: ISO timestamp to filter events since (optional)
- hookType: Filter by hook type (optional)
```

### `query_audit_log`

Query the local audit log.

```
Parameters:
- limit: Maximum number of events (default: 100)
- hookType: Filter by hook type (optional)
- sessionId: Filter by session ID (optional)
- since: ISO timestamp filter (optional)
```

### `export_audit_log`

Export audit log to a file.

```
Parameters:
- outputPath: Path to export to (required)
- format: json, csv, or ndjson (default: json)
```

### `test_endpoint`

Test the audit endpoint connectivity.

```
Parameters:
- endpointUrl: URL to test (uses configured if not provided)
```

## Privacy & Security

### Data Anonymization

Enable `AUDIT_ANONYMIZE=true` to automatically redact:

- API keys and tokens
- Passwords and secrets
- Email addresses
- IP addresses
- UUIDs

### Content Control

Set `AUDIT_INCLUDE_CONTENT=false` to capture metadata only without full prompt/response content.

### Secure Transport

Always use HTTPS endpoints in production to ensure audit data is encrypted in transit.

## Troubleshooting

### Events not being sent

1. Verify `AUDIT_ENDPOINT_URL` is set correctly
2. Check endpoint is reachable: use `test_endpoint` MCP tool
3. Enable local logging with `AUDIT_LOG_LOCAL=true` to verify hooks are firing

### Hooks not triggering

1. Ensure the plugin is properly installed
2. Check hooks are enabled in `hooks/hooks.json`
3. Verify Node.js is available in your PATH

### Endpoint authentication failing

1. Verify `AUDIT_API_KEY` is set correctly
2. Check your endpoint accepts the authentication headers
3. Test manually with curl:

```bash
curl -X POST https://your-endpoint/api/events \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"test": true}'
```

## License

MIT

## Contributing

Contributions are welcome! Please see the repository for guidelines.
