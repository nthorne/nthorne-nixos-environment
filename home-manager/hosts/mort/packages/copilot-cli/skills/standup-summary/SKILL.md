---
name: standup-summary
description: Summarize logged work for a user-specified date range as concise stand-up bullets.
---

# Stand-up Summary

Use for stand-up preparation and requests to summarize what the user worked on during a period. For time totals or timesheet reconciliation, use `time-reporting` instead.

## Workflow

1. **Confirm the range.** If the user has not supplied a clear range, ask for inclusive start and end dates, including the year. Treat date-only ranges as whole days. If missing years or relative wording leave multiple plausible ranges, clarify with `ask_user` rather than guessing.
2. **Read work records.** Use the `obsidian-vault` skill to locate the vault. Read available daily notes for the full range, then search relevant ticket notes in the inbox and archive. Include tickets created before the range when their dated work entries fall within it. Search for additional ticket keys mentioned in those records.
3. **Resolve ticket context selectively.** Daily and ticket notes are evidence of work performed. When a ticket key lacks a useful title or its current state matters, look up that Jira issue's summary and status. Use Jira to clarify, not to infer that work was performed; mention status only when supported by the notes or issue state. Do not fetch every issue when notes already explain the work.
4. **Summarize the evidence.** Group related work into concise bullets with ticket keys and outcomes or actions. Include notable non-ticket activities under their own labels. Call out ongoing work or blockers only when the records clearly support them. Do not calculate time totals or infer work from gaps.
5. **State coverage gaps.** If daily notes are missing for dates in the range, briefly disclose that the summary is based on available notes; do not treat missing notes as evidence of no work.

Keep the output brief and stand-up-ready. Lead with the date range, then provide the bullet list. Do not edit notes unless explicitly asked.
