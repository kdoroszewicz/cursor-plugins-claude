---
name: debug-android-issue
description: Reproduce and debug Android issues in Compose, lifecycle, and data layers
---

# Debug an Android issue

## Trigger

Android defects involving UI rendering, app lifecycle, concurrency, or data flow.

## Workflow

1. Reproduce with exact app state and device/emulator context.
2. Inspect logs, crashes, and lifecycle transitions.
3. Isolate fault domain (UI, state, data, or platform interaction).
4. Implement minimal safe fix and confirm behavior.
5. Add regression checks for the failing path.

## Output

- Root-cause summary
- Proposed fix with risk notes
- Verification checklist
