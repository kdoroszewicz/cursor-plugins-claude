---
name: review-pr-changes
description: Perform risk-focused code reviews with prioritized findings and test-gap analysis
---

# Review pull request changes

## Trigger

Reviewing code for bugs, regressions, reliability risks, and missing tests.

## Workflow

1. Understand intended behavior from PR context.
2. Review changed code paths for correctness and edge cases.
3. Check security-sensitive surfaces and data handling.
4. Evaluate test coverage for new and modified behavior.
5. Return findings ordered by severity with concrete fixes.

## Guardrails

- Prioritize user impact over style preferences.
- Separate confirmed issues from assumptions.
- Include at least one reproducible scenario for each high-severity finding.

## Output

- Findings by severity
- Open questions and assumptions
- Suggested follow-up tests
