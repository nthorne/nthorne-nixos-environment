# Global Agent Guidelines

If you are unsure how to performe some coding task, use the `github_grep` tool to search code examples from GitHub.

## Memory (Knowledge Graph)
- At the start of complex or multi-session tasks, read the knowledge graph for relevant context
- Persist to memory: user preferences, architectural decisions, recurring patterns, project-specific conventions not captured elsewhere
- Use consistent entity types: `user`, `host`, `project`, `preference`, `decision`, `pattern`
- Keep entities focused - prefer specific observations over broad ones
- Clean up outdated observations when information changes
- Do NOT store information that's already in project files (like per-repo AGENTS.md) - memory is for things that aren't captured in the repo
- Before running verification steps, check memory for relevant context. It can for example be the case that the user wants manual verification.
