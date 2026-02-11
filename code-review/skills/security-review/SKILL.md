---
name: security-review
description: Conduct a focused security review for changed code and integration boundaries
---

# Conduct a security review

## Trigger

Reviewing PRs or code changes that can affect application security.

## Workflow

1. Map trust boundaries and user-controlled inputs.
2. Inspect authentication, authorization, and permission checks.
3. Review data access and command execution paths for injection risks.
4. Check secret management and sensitive logging behavior.
5. Report findings with severity, exploit scenario, and minimal fix.

## Guardrails

- Prioritize exploitable paths over theoretical concerns.
- Keep recommendations specific and implementation-ready.
- Separate confirmed vulnerabilities from hardening suggestions.

## Output

- Security findings by severity
- Concrete exploitation scenarios
- Suggested fixes and follow-up tests
