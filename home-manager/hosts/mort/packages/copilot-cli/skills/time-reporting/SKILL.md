---
name: time-reporting
description: Summarize and reconcile work time from daily notes, ticket notes, Jira categories, and stopwatch totals.
---

# Time Reporting

Use this workflow for weekly or other date-bounded work summaries, time-sheet reconciliation, and requests to update daily time notes.

## Workflow

1. **Confirm the range.** Ask for exact inclusive start and end dates (with year) if the user has not supplied them or a relative range is ambiguous. Use `ask_user` for clarification.
2. **Read all relevant records.** Use the `obsidian-vault` skill to locate the notes vault. Read daily notes for every date in range, plus relevant ticket notes in the inbox or archive. Daily notes are required; ticket notes alone may miss work. Search for additional ticket keys mentioned in those records.
3. **Resolve categories.** Use a ticket note's stated time-reporting category when present. Otherwise fetch the Jira issue's **Category (for time reporting)** field. Keep non-ticket activities under their recorded labels and list them explicitly; do not hide them in a generic “non-ticket” bucket. If a category cannot be verified, mark it unknown rather than guessing.
4. **Resolve incomplete intervals.** Before totaling, identify every entry with a missing start or end. Ask for the missing clock-in/start time or clock-out/end time; for an open-ended entry, ask for that day's clock-out. If multiple entries overlap or a time range could refer to one or several periods, clarify before counting. Do not infer work from gaps between entries.
5. **Calculate time consistently.** Calculate elapsed time per interval. Deduct **0.50h** from each recorded period spanning the lunch break around 11:30–12:00. Do not deduct lunch from separate periods that do not span that break. Sum unrounded minutes, then convert to decimal hours using a decimal comma (for example, 15 minutes = `0,25h`); display totals to two decimal places.
6. **Reconcile stopwatch totals.** If the user supplies a stopwatch total, compare it with the note-based total. Recheck all daily notes for omitted activities, explain the remaining difference, and ask which date/activity it belongs to before adding it. Do not assign unexplained time to a ticket or category.
7. **Report or update.** Give a short bullet list grouped by ticket category, with ticket/activity names and category subtotals, followed by a grand total. State any unresolved or excluded time explicitly. Edit daily notes only when asked; preserve their format, use a duration-only entry if requested, and verify the saved content.
