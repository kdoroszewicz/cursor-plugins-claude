---
name: create-plugin-scaffold
description: Create a new Cursor plugin scaffold with a valid manifest, component directories, and marketplace wiring. Use when starting a new plugin or adding a plugin to a multi-plugin repository.
---

# Create plugin scaffold

## Trigger

You need to create a new Cursor plugin from scratch and make it ready for local use or marketplace submission.

## Required Inputs

- Plugin name (lowercase kebab-case)
- Plugin purpose and target users
- Component set to include (`rules`, `skills`, `agents`, `commands`, `hooks`, `mcpServers`)
- Repository style (`single-plugin` or `multi-plugin marketplace`)

## Workflow

1. Validate plugin name format: lowercase kebab-case, starts and ends with an alphanumeric character.
2. Create base files:
   - `.cursor-plugin/plugin.json`
   - `README.md`
   - `LICENSE`
   - optional `CHANGELOG.md`
3. Populate `plugin.json`:
   - Required: `name`
   - Recommended: `version`, `description`, `author`, `license`, `keywords`
   - Add explicit component paths only when non-default discovery is needed.
4. Create component files with valid frontmatter:
   - Rules: `.mdc` with `description`, `alwaysApply`, optional `globs`
   - Skills: `skills/<skill-name>/SKILL.md` with `name`, `description`
   - Agents: `agents/*.md` with `name`, `description`
   - Commands: `commands/*.(md|txt)` with `name`, `description`
5. If repository uses `.cursor-plugin/marketplace.json`, add plugin entry:
   - `name`
   - `source`
   - optional metadata (`description`, `keywords`, `category`, `tags`)
6. Ensure all manifest paths are relative, valid, and do not use absolute paths or parent traversal.

## Guardrails

- Keep the plugin focused on one use case.
- Prefer concise, actionable skill and rule text over long prose.
- Do not reference files that do not exist.
- Use folder discovery defaults unless custom paths are required.

## Output

- Created file tree for the plugin
- Final `plugin.json`
- Marketplace entry (if applicable)
- Short validation report of required fields and component metadata
