---
name: network-trace-debug
description: Trace and debug request/response failures with structured network analysis
---

# Network trace debug

## Trigger

Debugging request failures, response anomalies, or network timing issues in browser-based flows.

## Workflow

1. Identify failing requests and timing anomalies.
2. Validate request payload, headers, and auth context.
3. Inspect response status, body, and caching behavior.
4. Separate frontend handling issues from backend defects.
5. Return a root-cause hypothesis and next fix action.

Use `browser_network_requests` for request/response inspection to track API calls, payloads, status codes, and timing.

## MCP

Lock before interactions. Unlock when done. See canonical browser docs for full lock/unlock sequence.

## Guardrails

- Include request and response evidence for every root-cause claim (use `browser_network_requests` output).
- Distinguish transport, backend, and frontend handling failures based on network tool evidence.

## Output

- Network failure summary
- Root-cause hypothesis with evidence
- Next fix action
