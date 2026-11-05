---
name: jira-ticket-note
description: Create a Jira ticket note in the notes repo inbox from a Jira issue key.
disable-model-invocation: true
---

# Jira Ticket Note

Invoke with a Jira issue key, for example `jira-ticket-note SWSE-1234`.

1. Fetch the issue through Jira MCP using the supplied key. Resolve the Jira site through MCP if needed; ask if the key or site is ambiguous.
2. Consult the `documented-code-snippets` Copilot memory for Jira-note content rules.
3. Use the `obsidian-vault` skill to locate the notes repo, Ticket template, and inbox. Read and use the template at execution time; keep its contents and note-format rules out of this skill.
4. Use the `caveman` skill in `lite` mode while composing the note.
5. Check for an existing note for this issue before writing. If one exists, report it instead of overwriting or duplicating it.
6. Create the note from the template, following the referenced memory and Obsidian conventions. Report its path.
