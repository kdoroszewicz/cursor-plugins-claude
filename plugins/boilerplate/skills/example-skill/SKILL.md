# Example Skill

A demonstration skill showing the structure and capabilities of Cursor Agent Skills.

## When to Use

Use this skill when the user asks to:
- Demonstrate skill functionality
- Test skill integration
- Learn about skill structure

## Instructions

When this skill is activated:

1. **Acknowledge** - Confirm the skill has been activated
2. **Gather Context** - Understand what the user needs
3. **Execute** - Perform the requested action
4. **Report** - Provide a summary of what was done

## Available Tools

This skill can use:
- File reading and writing tools
- Shell commands for system operations
- Search tools for codebase exploration

## Example Usage

User: "Use the example skill to analyze this file"

Response: The skill will read the file, analyze its contents, and provide relevant insights based on the skill's capabilities.

## Configuration

This skill accepts the following configuration:
- `verbose`: Enable detailed output (default: false)
- `format`: Output format - "text" | "json" | "markdown" (default: "markdown")

## Notes

- Skills are self-contained and should not depend on external state
- Always provide clear feedback about what the skill is doing
- Handle errors gracefully and inform the user of any issues
