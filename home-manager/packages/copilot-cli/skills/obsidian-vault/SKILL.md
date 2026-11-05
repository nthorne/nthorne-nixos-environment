---
name: obsidian-vault
description: >
  Search, create, or organize notes in the user's Obsidian vault. Use only when asked to work
  with Obsidian/vault notes, or to consolidate durable Copilot memory from relevant notes. Do not
  trigger merely because an answer could benefit from notes.
---

# Obsidian Vault

## Select vault

- Use a path named by the user when provided.
- Otherwise use `/home/nthorne/repos/notes/` as primary vault and
  `/home/nthorne/repos/private-notes/` as optional personal vault.
- If the secondary vault exists, treat primary as work and secondary as personal. Otherwise treat
  primary as personal.
- Confirm selected directory exists before searching. If expected vault is missing or roles are
  unclear, ask for its location; do not scan home or silently switch vaults.

## Search and edit

- Search only relevant index, project, or knowledge notes; never ingest the whole vault.
- Prefer targeted file tools: `glob` for paths and `rg` for note content. Scope searches to the
  selected vault and Markdown files.
- Treat notes as read-only unless user explicitly asks to create, edit, move, or delete them.
- Before writing, inspect the target note and related index. Never overwrite an existing note
  without preserving its content.
- Use Obsidian `[[wikilinks]]` for links. Use natural casing and filename format
  `YYYYMMDDHHmm Note title.md`. Check for filename collisions before creating.
- Write notes as focused units of learning and link related notes at the bottom.
- New notes use frontmatter:

  ```yaml
  ---
  id: YYYYMMDDHHmm Note title
  aliases:
    - Note title
  tags: []
  ---
  ```

## Organize notes

- Inspect existing folders and index notes before filing; preserve established structure.
- Use `0.inbox` for unfiled notes, `1.projects` for project notes, `2.knowledge` for general
  knowledge (`work` and `personal` subfolders), `4.archive` for inactive reference material, and
  `7.study` for learning notes.
- Move or archive notes only when user explicitly requests it.

## Memory consolidation

When consolidating durable Copilot memory, inspect only relevant index and project/knowledge notes.
Promote stable preferences, decisions, or recurring workflows only after checking current evidence
and existing memory. Do not copy secrets, sensitive personal details, or temporary work. Leave
Obsidian notes unchanged; add a source wikilink to memory when useful.
