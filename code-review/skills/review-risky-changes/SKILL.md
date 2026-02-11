---
name: review-risky-changes
description: Deep review of high-risk changes involving auth, data, infra, or shared core logic
---

# Review high-risk changes

## Trigger

Changes with elevated risk in:

- Auth and authorization logic
- Data layer and migrations
- Build, deploy, and runtime configuration
- Shared libraries used across services

## Workflow

1. Identify the highest-risk surfaces and likely failure modes.
2. Evaluate correctness, security, and blast radius for each critical path.
3. Check missing tests, observability, and rollback readiness.
4. Return the top risks with prioritized mitigations.

## Output

1. Top risks with severity and impact
2. Missing tests or observability
3. Safe rollout recommendations
