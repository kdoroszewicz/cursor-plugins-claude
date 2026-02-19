---
name: sync-fork
description: Use when the fork needs to be updated with new commits from upstream (cursor/plugins), or when upstream has added, removed, or renamed plugins
---

# Sync Fork with Upstream

## Overview

This repo is a fork of `cursor/plugins` that adds `.claude-plugin/` manifests for Claude Code compatibility. The fork maintains a single custom commit on top of upstream. Syncing means rebasing that commit onto the latest `upstream/main` and updating all Claude Code manifests to match.

## Workflow

### 1. Fetch and analyze

```sh
git fetch upstream
git log --oneline HEAD..upstream/main        # new upstream commits
git log --oneline upstream/main..HEAD        # our commits (should be 1)
git diff --stat HEAD..upstream/main          # what changed upstream
```

If `HEAD..upstream/main` is empty, there's nothing to sync.

### 2. Rebase

```sh
git rebase upstream/main
```

We maintain exactly one commit on top of upstream. Rebase keeps history linear.

### 3. Resolve conflicts

**README.md** will almost always conflict. Resolution approach:

- Start from **upstream's content** as the base (it has the current plugin list)
- Re-apply our fork-specific sections on top: title, description, quick-start, "What changed from upstream", "Keeping up to date"
- Update the plugin tables and install examples to reflect the current plugin set

**Do NOT** just keep "our version" — upstream's plugin list changes must be incorporated.

### 4. Handle plugin changes

Check the upstream diff for added, removed, or renamed plugin directories.

**For each ADDED plugin:**
- Create `<plugin>/.claude-plugin/plugin.json`:
  ```json
  {
    "name": "<plugin-slug>",
    "description": "<from upstream's .cursor-plugin/plugin.json>",
    "author": { "name": "Cursor", "email": "plugins@cursor.com" }
  }
  ```
- Add entry to `.claude-plugin/marketplace.json`
- Add row to README.md plugin table

**For each REMOVED plugin:**
- Delete `<plugin>/.claude-plugin/plugin.json` (use `git rm -f` during rebase)
- Remove entry from `.claude-plugin/marketplace.json`
- Remove row from README.md plugin table

**For each RENAMED plugin:**
- Treat as remove old + add new

### 5. Complete rebase

```sh
git add -A
git rebase --continue
```

### 6. Verify

```sh
git log --oneline -5                    # our commit on top
git diff upstream/main --stat           # only .claude-plugin/ files + README.md
```

Every plugin dir should have `.claude-plugin/plugin.json`. The marketplace.json `plugins` array should match the set of plugin directories exactly.

### 7. Push

```sh
git push --force-with-lease origin main
```

## Key files

| File | Purpose |
|:-----|:--------|
| `.claude-plugin/marketplace.json` | Root manifest — must list all plugins |
| `<plugin>/.claude-plugin/plugin.json` | Per-plugin manifest for Claude Code |
| `README.md` | Fork-specific docs with plugin tables |
| `.cursor-plugin/marketplace.json` | Upstream's manifest (reference only) |

## Why rebase + force push (not PRs)

This fork maintains a single commit on top of upstream. Rebase keeps that structure clean. PRs don't work well here because:

- GitHub PRs can't fast-forward merge — they'd create merge commits, breaking the single-commit structure
- A PR diff would show the entire upstream changeset as "changes", not just our manifest updates
- `git merge upstream/main` would accumulate merge commits over time

The verification step (step 6) serves as the review gate. If you want an extra safety net, do the rebase on a temporary branch first, inspect the diff, then fast-forward main to it.

## Common mistakes

- Keeping stale `.claude-plugin/plugin.json` files for plugins upstream removed
- Taking "our" README.md wholesale during conflicts instead of merging upstream's plugin changes
- Forgetting to update marketplace.json when plugins are added or removed
- Exploring upstream feature branches — only sync from `upstream/main`
