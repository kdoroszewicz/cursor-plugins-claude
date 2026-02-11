---
name: build-frontend-feature
description: Plan and implement frontend features with accessibility and performance checks
---

# Build a frontend feature safely

## Trigger

Implementing or updating frontend UI behavior in a maintainable way.

## Workflow

1. Clarify scope, user flows, and acceptance criteria.
2. Identify impacted components, state, and API boundaries.
3. Implement UI changes with semantic markup and keyboard support.
4. Add or update tests for behavior and edge cases.
5. Verify accessibility and performance before finalizing.

## Guardrails

- Prefer composition over adding one-off component variants.
- Keep business logic out of view-only components.
- Avoid unsafe DOM rendering patterns.
- Preserve backward compatibility for shared component APIs.

## Output

- A concise implementation summary
- Updated tests
- Any follow-up recommendations for UX or performance
