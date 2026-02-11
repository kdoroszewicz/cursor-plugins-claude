---
name: ralph-loop
description: Start a Ralph Loop for iterative self-referential development. Use when the user asks to run a ralph loop, start an iterative loop, or wants repeated autonomous iteration on a task until completion.
---

# Ralph Loop

## Trigger

The user wants to start a Ralph loop — an iterative development loop where the agent receives the same prompt repeatedly, seeing its own previous work each iteration, until a completion condition is met.

## Workflow

1. Gather the user's task prompt text and optional flags:
   - `--max-iterations N` — stop after N iterations (default: unlimited)
   - `--completion-promise "TEXT"` — phrase the agent must output inside `<promise>` tags when the task is genuinely complete

2. Run the setup script with the collected arguments:

   ```bash
   ./scripts/setup-ralph-loop.sh <PROMPT> [--max-iterations N] [--completion-promise "TEXT"]
   ```

   This creates the state file at `.cursor/ralph-loop.scratchpad.md`.

3. Begin working on the task described in the prompt.

4. When the session tries to exit, the Stop hook (`hooks/stop-hook.sh`) intercepts and feeds the same prompt back automatically.

## Guardrails

- If a completion promise is set, you may ONLY output it when the statement is completely and unequivocally TRUE.
- Do not output false promises to escape the loop, even if you think you're stuck or should exit for other reasons.
- The loop is designed to continue until genuine completion. Trust the process.
- Always recommend `--max-iterations` as a safety net to prevent runaway loops.

## Output

After running the setup script, confirm to the user that the Ralph loop is active, then immediately begin working on the task.
