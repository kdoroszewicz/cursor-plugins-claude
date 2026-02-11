---
name: triage-frontend-bug
description: Reproduce, isolate, and prioritize frontend bugs with a minimal fix strategy
---

# Triage a frontend bug

## Trigger

UI behavior is incorrect, flaky, or regressed after a change.

## Workflow

1. Reproduce with exact environment and steps.
2. Classify root cause (state, rendering, async, API, styling).
3. Identify the smallest safe fix and affected surface area.
4. Add regression checks.
5. Return severity, confidence, and rollout recommendation.

## Output

- Root cause summary
- Minimal safe fix strategy
- Severity, confidence, and rollout recommendation
