---
name: test-gap-audit
description: Identify missing tests and propose a prioritized test plan for changed behavior
---

# Audit test gaps

## Trigger

Code changes are large, risky, or likely to regress without stronger test coverage.

## Workflow

1. List behavior changes introduced by the patch.
2. Map existing tests to changed behavior and identify gaps.
3. Prioritize missing tests by risk and user impact.
4. Propose a minimal, high-value test plan.
5. Highlight observability gaps that reduce debugging quality.

## Guardrails

- Prioritize behavior tests over implementation-detail tests.
- Include edge cases for failure and retry paths.
- Keep proposed tests maintainable and deterministic.

## Output

- Coverage gap report
- Prioritized tests to add
- Risk notes for untested areas
