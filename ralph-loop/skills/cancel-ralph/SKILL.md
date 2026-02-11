---
name: cancel-ralph
description: Cancel an active Ralph Loop. Use when the user wants to stop, cancel, or abort a running ralph loop.
---

# Cancel Ralph

## Trigger

The user wants to cancel or stop an active Ralph loop.

## Workflow

1. Check if `.cursor/ralph-loop.scratchpad.md` exists:

   ```bash
   test -f .cursor/ralph-loop.scratchpad.md && echo "EXISTS" || echo "NOT_FOUND"
   ```

2. **If NOT_FOUND**: Tell the user "No active Ralph loop found."

3. **If EXISTS**:
   - Read `.cursor/ralph-loop.scratchpad.md` to get the current iteration number from the `iteration:` field in the YAML frontmatter.
   - Remove the file:
     ```bash
     rm .cursor/ralph-loop.scratchpad.md
     ```
   - Report: "Cancelled Ralph loop (was at iteration N)" where N is the iteration value.

## Output

A short confirmation message with the iteration count, or a message that no loop was active.
