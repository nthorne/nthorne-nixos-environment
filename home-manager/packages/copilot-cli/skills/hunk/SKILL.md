---
name: hunk
description: >
  Opt-in workflow for running the `hunk` CLI. Trigger only when the user explicitly asks to run
  Hunk for a review or diff (for example, invokes `/hunk` or says "use hunk to review this diff").
  Never trigger for generic reviews, diff requests, or discussion/editing of Hunk itself.
---

# Hunk Skill

## Activation gate

Use this skill only when the user explicitly asks to run the Hunk CLI or invokes `/hunk` for a
review or diff. Merely mentioning Hunk, asking about its skill, or requesting a generic code review
or diff is not authorization to run it. Do not infer consent from repository changes or prior
conversation context.

## Run Hunk

After the activation gate passes, load Hunk's bundled instructions and follow them instead of this
file:

```sh
hunk skill path
```

Attach the returned skill file to the ongoing session. If the command fails, report the failure;
do not silently substitute another review workflow.
