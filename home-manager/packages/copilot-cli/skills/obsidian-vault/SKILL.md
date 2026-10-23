---
name: obsidian-vault
description: Search, create, and manage notes in the Obsidian vault with wikilinks and index notes. Use when user wants to find, create, or organize notes in Obsidian.
---

# Obsidian Vault

## Vault location

`/home/nthorne/repos/notes/`

Secondary vault location (only available on some hosts): `/home/nthorne/repos/private-notes/` . If this one exists, then the primary vault is for work-related information, and the secondary vault is for personal information. If the secondary vault does not exist, then the primary vault is for personal information.

# Folder structure

These are the most important folders in the vault that you are most likely to interact with:

`0.inbox` - for new notes to be processed and organized. This is typically where new notes are created before being moved to the appropriate topic or index.

`1.projects` - for notes related to specific personal or work projects (sorted into the respective subfolder).

`2.knowledge` - for general knowledge notes. Work specific knowledge notes go into the `work` subfolder, while personal knowledge notes go into the `personal` subfolder. General knowledge notes that don't fit into work or personal can go directly in `2.knowledge`.

`4.archive` - for old notes that are no longer actively referenced but may be useful for historical context or future reference. Think JIRA tickets that are closed but may be useful to keep for reference.

`7.study` - for notes related to learning and skill development. This can include notes on specific topics, concepts, or skills being studied.

## Naming conventions

I use a Zettlekasten structure so name notes like `YYYYMMDDHHmm Note title.md` , where "Note title" is a descritive title and the date prefix is the creation date. Also add below frontmatter at the top of each note (example follows file name example):

```yaml
---
id: YYYYMMDDHHmm Note title
aliases:
  - Note title
tags: []
---
```

## Linking

- Use Obsidian `[[wikilinks]]` syntax: `[[Note Title]]`

## Workflows

### Review notes for durable memory

When consolidating Copilot memory, use the vault as a source of context without importing it wholesale:

1. Search relevant index notes and project or knowledge notes for durable user preferences, decisions, and recurring workflows.
2. Read only the notes needed to understand each candidate fact, then check whether it is current and already represented in memory.
3. Add useful, stable facts to the appropriate global or project memory file and update its index. Keep the memory concise and include an Obsidian wikilink to its source when that helps preserve context.
4. Do not copy secrets, sensitive personal details, or temporary/in-progress information into memory. Leave Obsidian notes unchanged unless the user asks to edit them.

### Search for notes

```bash
# Search by filename
find "/home/nthorne/repos/notes/" -name "*.md" | grep -i "keyword"

# Search by content
grep grep -rl "keyword" "/home/nthorne/repos/notes/" --include="*.md"
Or use Grep/Glob tools directly on the vault path.

### Create a new note

1. Use **Natrual casing** for filename
2. Write content as a unit of learning (per vault rules)
3. Add `[[wikilinks]]` to related notes at the bottom
4. If part of a numbered sequence, use the hierarchical numbering scheme

### Find related notes

Search for `[[Note Title]]` across the vault to find backlinks:

```bash
grep grep -rl "\\[\\[Note Title\\]\\]" "/home/nthorne/repos/notes/"
### Find index notes

```bash
find find "/home/nthorne/repos/notes/" -name "*Index*"
