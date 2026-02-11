---
name: build-ios-feature
description: Implement iOS features with clear architecture, state handling, and test coverage
---

# Build an iOS feature

## Trigger

Need Swift or SwiftUI implementation support for production features.

## Workflow

1. Confirm target OS versions, architecture, and constraints.
2. Model state transitions and data flow before UI coding.
3. Implement views and view models with explicit responsibilities.
4. Add unit and UI tests for critical flows.
5. Verify accessibility and performance impacts.

## Guardrails

- Keep side effects isolated from view rendering.
- Avoid tightly coupling networking with UI layers.
- Handle loading, empty, and error states explicitly.

## Output

- Implementation plan and code changes
- Test coverage notes
- Follow-up hardening recommendations
