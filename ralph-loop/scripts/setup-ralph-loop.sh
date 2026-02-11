#!/bin/bash

# Ralph Loop Setup Script
# Creates state file for in-session Ralph loop

set -euo pipefail

# Parse arguments
PROMPT_PARTS=()
MAX_ITERATIONS=0
COMPLETION_PROMISE="null"

# Parse options and positional arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Ralph Loop - Interactive self-referential development loop

USAGE:
  /ralph-loop [PROMPT...] [OPTIONS]

ARGUMENTS:
  PROMPT...  Initial prompt to start the loop (can be multiple words without quotes)

OPTIONS:
  --max-iterations      Maximum iterations before auto-stop (default: unlimited)
  --completion-promise  Promise phrase (USE QUOTES for multi-word)
  -h, --help            Show this help message

DESCRIPTION:
  Starts a Ralph Loop in your CURRENT session. The stop hook prevents
  exit and feeds your output back as input until completion or iteration limit.

  To signal completion, you must output: <promise>YOUR_PHRASE</promise>

  Use this for:
  - Interactive iteration where you want to see progress
  - Tasks requiring self-correction and refinement
  - Learning how Ralph works

EXAMPLES:
  /ralph-loop Build a todo API --completion-promise 'DONE' --max-iterations 20
  /ralph-loop --max-iterations 10 Fix the auth bug
  /ralph-loop Refactor cache layer (runs forever)
  /ralph-loop --completion-promise 'TASK COMPLETE' Create a REST API

STOPPING:
  Only by reaching --max-iterations or detecting --completion-promise
  No manual stop - Ralph runs infinitely by default!

MONITORING:
  # View current iteration:
  grep '^iteration:' .cursor/ralph-loop.scratchpad.md

  # View full state:
  head -10 .cursor/ralph-loop.scratchpad.md
HELP_EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --max-iterations requires a number argument" >&2
        echo "" >&2
        echo "  Valid examples:" >&2
        echo "    --max-iterations 10" >&2
        echo "    --max-iterations 50" >&2
        echo "    --max-iterations 0 (unlimited)" >&2
        echo "" >&2
        echo "  You provided: --max-iterations (with no number)" >&2
        exit 1
      fi
      if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-iterations must be a positive integer or 0, got: $2" >&2
        echo "" >&2
        echo "  Valid examples:" >&2
        echo "    --max-iterations 10" >&2
        echo "    --max-iterations 50" >&2
        echo "    --max-iterations 0 (unlimited)" >&2
        echo "" >&2
        echo "  Invalid: decimals (10.5), negative numbers (-5), text" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --completion-promise requires a text argument" >&2
        echo "" >&2
        echo "  Valid examples:" >&2
        echo "    --completion-promise 'DONE'" >&2
        echo "    --completion-promise 'TASK COMPLETE'" >&2
        echo "    --completion-promise 'All tests passing'" >&2
        echo "" >&2
        echo "  You provided: --completion-promise (with no text)" >&2
        echo "" >&2
        echo "  Note: Multi-word promises must be quoted!" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    *)
      # Non-option argument - collect all as prompt parts
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

# Join all prompt parts with spaces
PROMPT="${PROMPT_PARTS[*]}"

# Validate prompt is non-empty
if [[ -z "$PROMPT" ]]; then
  echo "Error: No prompt provided" >&2
  echo "" >&2
  echo "  Ralph needs a task description to work on." >&2
  echo "" >&2
  echo "  Examples:" >&2
  echo "    /ralph-loop Build a REST API for todos" >&2
  echo "    /ralph-loop Fix the auth bug --max-iterations 20" >&2
  echo "    /ralph-loop --completion-promise 'DONE' Refactor code" >&2
  echo "" >&2
  echo "  For all options: /ralph-loop --help" >&2
  exit 1
fi

# Create state file for stop hook (markdown with YAML frontmatter)
mkdir -p .cursor

# Quote completion promise for YAML if it contains special chars or is not null
if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

cat > .cursor/ralph-loop.scratchpad.md <<EOF
---
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
---

$PROMPT
EOF

echo "Ralph loop initialized"
echo ""
echo "  Prompt: $PROMPT"
echo "  Max iterations: $([ "$MAX_ITERATIONS" -eq 0 ] && echo "unlimited" || echo "$MAX_ITERATIONS")"
if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo "  Completion promise: $COMPLETION_PROMISE"
fi
echo ""
echo "  State file: .cursor/ralph-loop.scratchpad.md"
echo ""
echo "The stop hook will now intercept exit attempts and feed the"
echo "same prompt back. Work on the task and iterate until completion."
echo ""

if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo "================================================="
  echo "COMPLETION SIGNAL"
  echo ""
  echo "  When done, output EXACTLY:"
  echo "  <promise> $COMPLETION_PROMISE </promise>"
  echo ""
  echo "STRICT REQUIREMENTS (DO NOT VIOLATE):"
  echo "  - Use XML tags EXACTLY as shown above"
  echo "  - The statement MUST be completely and unequivocally TRUE"
  echo "  - Do NOT output false statements to exit the loop"
  echo "  - Do NOT lie even if you think you should exit"
  echo ""
  echo "IMPORTANT - Do not circumvent the loop:"
  echo "  Even if you believe you're stuck, the task is impossible,"
  echo "  or you've been running too long - you MUST NOT output a"
  echo "  false promise statement. The loop is designed to continue"
  echo "  until the promise is GENUINELY TRUE. Trust the process."
  echo ""
  echo "  If the loop should stop, the promise statement will become"
  echo "  true naturally. Do not force it by lying."
  echo "================================================="
fi
