---
name: capture-browser-repro
description: Build a precise browser reproduction record for debugging and handoff
---

# Capture browser repro

## Trigger

Browser issue needs a reproducible, evidence-backed record for debugging or handoff.

## Workflow

1. Capture environment details (browser, OS, app version).
2. Record exact steps and observed versus expected behavior.
3. Collect console and network evidence.
4. Define impact scope (who is impacted, how often).
5. Include a temporary workaround if available.

## Evidence Collection

Use `browser_snapshot` with `take_screenshot_afterwards: true` for visual evidence. Use `browser_network_requests` for HTTP request/response evidence (API calls, status codes, payloads).

## MCP

Lock before interactions. Unlock when done. See canonical browser docs for full lock/unlock sequence.

## Output

- Reproduction packet with environment and steps
- Console and network evidence
- Impact scope and workaround notes
