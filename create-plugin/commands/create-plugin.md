---
name: create-plugin
description: Scaffold a new Cursor plugin with manifest, component files, and marketplace wiring when needed
---

# Create Plugin

Create a new plugin scaffold using this flow:

1. Gather inputs:
   - Plugin name (kebab-case)
   - Description and target users
   - Components to include (`rules`, `skills`, `agents`, `commands`, `hooks`, `mcpServers`)
2. Create required files:
   - `.cursor-plugin/plugin.json`
   - `README.md`
   - `LICENSE`
3. Add selected component folders and starter files with frontmatter.
4. In multi-plugin repositories, update `.cursor-plugin/marketplace.json` with a new plugin entry.
5. Return a summary of created files and any remaining manual setup.
