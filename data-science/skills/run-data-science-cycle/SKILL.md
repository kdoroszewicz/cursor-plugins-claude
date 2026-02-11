---
name: run-data-science-cycle
description: Run an analyst-first analysis loop from question framing through validated, decision-ready insights
---

# Run a data science cycle

## Trigger

Need analyst-grade answers from data: exploratory analysis, trend/slice comparisons, and clear recommendations.

## Workflow

1. Define the decision to support, then lock primary metrics, denominators, and success criteria.
2. Set up a reproducible notebook-first workflow (or script fallback) with documented data sources, filters, and time windows.
3. Audit data quality, joins, and assumptions before interpreting results.
4. Build baseline trend and segment analyses before introducing complex methods.
5. Validate findings with sensitivity checks, alternate cuts, and plausible confounders.
6. Summarize decision impact, confidence, caveats, and recommended next actions.

## Guardrails

- Keep cells focused and readable. One analytical intent per notebook cell.
- Keep transformations reproducible and ordered. Move reusable logic to scripts when needed.
- Track confounders and selection bias risks, not only metric movement.
- Report uncertainty and practical effect size, not only point estimates.
- Prefer simple baselines unless added complexity changes decisions.

## Output

- Reproducible analysis workflow (notebook or script)
- Metric definitions, assumptions, and data-quality notes
- Validated findings with uncertainty and caveats
- Clear recommendation and next steps
