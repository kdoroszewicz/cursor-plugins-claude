---
name: debug-with-browser-tools
description: Investigate frontend issues with a structured DevTools and network-debug workflow
---

# Debug with browser tools

## Trigger

UI bugs, rendering issues, network failures, and browser-only regressions.

## Workflow

1. Reproduce the issue with exact environment details.
2. Inspect console errors and stack traces first.
3. Capture network requests, timing, and failed responses.
4. Validate DOM state, computed styles, and event flow.
5. Produce a minimal repro and ranked root-cause hypotheses.

## MCP Notes

Lock before interactions. Unlock when done. See canonical browser docs for full lock/unlock sequence.

- Use `browser_handle_dialog` before actions that trigger `confirm()` or `prompt()` when testing dialog behavior.
- Iframe content is not accessible. Scope work to elements outside iframes.
- Use `browser_type` to append text. Use `browser_fill` to clear and replace. Use `browser_scroll` with `scrollIntoView: true` before clicking elements that may be obscured in nested scroll containers.

## Guardrails

- Distinguish client bugs from backend/API failures.
- Include request/response evidence for network claims.
- Confirm fix with the same repro steps used to detect the issue.

## Output

- Repro steps
- Root-cause analysis
- Candidate fixes and validation steps
