# Code review plugin

Code review workflows: correctness, security, regressions, and actionable feedback.

## Installation

```bash
agent install code-review
```

## Components

### Skills

| Skill | Description |
|:------|:------------|
| `review-pr-changes` | Perform risk-focused code reviews with prioritized findings and test-gap analysis |
| `security-review` | Conduct a focused security review for changed code and integration boundaries |
| `test-gap-audit` | Identify missing tests and propose a prioritized test plan for changed behavior |
| `review-pr` | Perform a risk-focused pull request review and return prioritized findings |
| `review-risky-changes` | Deep review of high-risk changes involving auth, data, infra, or shared core logic |

### Rules

| Rule | Description |
|:-----|:------------|
| `security-review-checklist` | Security checklist for auth, input handling, and secret exposure risks |
| `regression-risk-checklist` | Regression checklist for behavior changes and compatibility risks |

### Agents

| Agent | Description |
|:------|:------------|
| `security-reviewer` | Security-focused reviewer for pull requests and critical code paths |

## License

MIT
