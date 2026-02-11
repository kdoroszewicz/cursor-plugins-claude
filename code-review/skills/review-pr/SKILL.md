---
name: review-pr
description: Perform a risk-focused pull request review and return prioritized findings
---

# Review pull request

## Trigger

Reviewing a pull request for behavior-impacting risks and actionable fixes.

## Workflow

1. Understand the intended behavior and changed scope.
2. Identify correctness, security, and regression risks.
3. Evaluate test coverage for modified behavior.
4. Return findings ordered by severity with fix suggestions.

## Guardrails

- Keep feedback concise and actionable.
- Focus on behavior-impacting issues before style-only comments.

## Output

- Prioritized findings with severity and impact
- Concrete fix suggestions
- Coverage gaps that should be tested
