---
name: quiz-me
description: Test whether the user's mental model still matches work that already exists — code the agent wrote, a PRD, a plan, a document tree — usually because they delegated it, skimmed it, or were away while it was built. Derives a tree from the artifact, then asks one multiple-choice question at a time; general framing first, then hard into the decision points, with distractors drawn from the alternatives actually rejected, or from the conventional choice this artifact departed from. Every wrong answer is triaged — did the agent drift from the user's intent (→ punch list), or is it a gap in the user's knowledge (→ explained)? Needs an artifact that already exists? For a subject nothing was built for use `tutor`, and for a plain re-orientation with no questions asked use `catchup`. Triggered by /quiz-me, "quiz me on what we built", "test me on this plan", "grill me on the code you wrote", "do I actually understand what we built", "am I still in sync with what you wrote", "I approved that without reading it".
license: MIT
---

# quiz-me — is your model still the artifact's model?

A lot got built while the user steered at a distance. Reading all of it defeats the point of
delegating; assuming they're current is how drift survives. quiz-me tests the delta.

The ground truth is an **artifact**, which is the only reason this works: the answer key is
checkable on disk, so a wrong answer can mean the *artifact* is wrong and not the user.

## Target — what's under test

- **No argument** → the work of the current session. Derive the tree and the answer key from
  the **current state of the files** — re-read what changed. Your recollection is not the
  artifact: edits get reverted, failing tests force silent rewrites, context gets compacted.
  The transcript supplies the *rejected alternatives*; it is never the answer key. If the
  session produced no durable artifact, say so — drift findings are weak without one.
- **With an argument** → that target, cold. A file, a directory, a PRD, a document subtree, a
  diff, a branch. Nothing needs to be in context.
- **Ambiguous** → ask once, in one line.

Before question 1, state the scope in one line and name the two affordances: `D — not sure`,
and that saying **object** at any point flags a choice the user dislikes. **Don't show the
tree** — its structure telegraphs the answers.

## Build the tree first

Derive it breadth-first: every top-level area, drilling only where a decision is visible.
Build wider than you will ask, so you know where to go when an answer goes wrong and can
report honestly what you never touched.

**Size the quiz to the tree, not to the budget.** A 3-question quiz on a 3-decision artifact
is a complete quiz — never promote a non-decision to fill a quota. If the target is too large
to cover in one pass, name the subtree you *can* cover and get agreement instead of sampling
silently. If it is empty, missing, too thin, or holds no decisions at all, say so and stop.

## Two kinds of question, and where their options come from

- **Fact questions** — there was only ever one answer. A miss is always a gap, unless the item
  was demoted from a decision (below), which keeps its triage. Distractors are plausible variants.
- **Decision questions** — the artifact made a choice where another was live. A miss can mean
  drift, and everything rests on where the wrong options come from.

Two tiers, in priority order.

**1. Recovered alternatives — best.** An option counts as recovered only if **you can point to
where it was rejected**. Dig for it: reverted commits; code that lived a few commits and
vanished; a dependency added then removed; commented-out config; comments of the form "we don't
use X because"; PR review threads; design docs; this session's transcript. *Deleted code is the
richest vein and the easiest to forget to look at.* A recovered distractor is worth most,
because a miss says exactly which option the user believed was there.

**2. The conventional default.** Most rejections were never written down; the reasoning lived
in a conversation and evaporated. So where nothing is recoverable, make the wrong option **what
most projects would do here** — what the user would assume if they weren't watching. Most
projects retry, cache, put auth in middleware. Where this artifact went the other way, the
question quietly asks whether they noticed.

**A convention qualifies only if it changes a prediction.** State what the user would expect to
happen if the convention held, and check that the expectation is observably wrong. *"Most
projects retry, so you'd expect a hiccup to recover — this one hangs forever"* qualifies.
*"Most projects build amd64-only, so you'd expect an amd64 image — which is what you get"* does
not: that's a different parameter value wearing a convention's clothes, and a miss on it reveals
nothing. Judge conventions against **present-day** practice, since that is what the user's
assumption is made of.

**And only if the convention is real.** Name who does this and where the user would have seen
it — a framework's default, a standard library's behaviour, the official image for this service.
A behaviour you can imagine but cannot attribute is not a convention: it's an invention with a
prediction attached, which is the same noise under a better label. The prediction test alone
will pass anything the artifact happens not to do.

That is not a downgrade. Drift *is* the gap between what the user assumed and what exists, and
absent information they assume the default — so a miss on a qualifying conventional distractor
localizes as well as a miss on a recovered one.

**Never invent a third kind** — on a decision question; fact questions take the near-miss rule
below. An option that is neither recovered nor a qualifying conventional default is noise, and
noise makes a wrong answer mean only "they didn't know." Never present an option as having been
*considered* unless it was recovered: the conventional default is offered as an option, never as
history.

**Let the option count flex, and expect it to.** Two options plus `D` is a complete question —
never pad to fill an A–C shape. Tier 2 is a fallback, not a supply of filler: where it produces
nothing that changes a prediction, ship two options.

**Vary the polarity.** Tier 2 only fires where the artifact departed from convention, so on
those questions the conventional-looking option is always the wrong one, and a user who knows
nothing but "this project is unusual" scores by reflex. Break the pattern with questions where
the artifact *did* follow convention — those need a recovered alternative, since tier 2 can't
supply a distractor when the convention is the right answer, so look for them while you dig.
This is a dividend of tier 1, not an independent quota: on a repo with thin history it may not
fire at all, and that's the correct outcome. Never force a weak question to flip the polarity.

**Randomize which letter is correct** — concretely, never let the same letter be right three
times running. Writing strongest-first parks every answer on `A`, which is a tell within three
questions.

**Fact distractors are near-misses**, not filler: each should be true of a *neighbouring* part
of the artifact, so a miss says which part the user confused this one with. Never write a
self-refuting option — it makes the question free.

### Test reasoning, not retrieval

**What separates the right option from the wrong one must be a *why*, never a stored value or a
stored state.** The artifact remembers values and states perfectly and a grep retrieves them in
seconds; the user's *model of the problem* is the only thing that can silently go stale, so it is
the only thing worth testing.

Two disqualifiers, both lookups wearing a question's clothes:

- **Values.** Options differing by a threshold, version, count, rate, size, name, path, or date.
  Ask the logic the value encodes: not *"is the bar 1.31 or 1.34"* but *"does the bar sit on the
  raw score or the noise-corrected one."*
- **Status and location.** Which module received a fix, how many of N items are done, what's
  still open, where something lives, how far along a migration is. That is progress reporting —
  it belongs in `catchup`, and a miss on it means only "hasn't read it lately."

Values and locations may appear *inside* an option as incidental colour. They may never be the
thing being chosen between.

**The test — could a colleague who understands the problem but has never opened the artifact
reason their way to the right option?** If yes, the question probes a model, and a miss localizes
a wrong belief about the constraints, which is what drift actually is. If the only route to the
answer is having read the file, it probes reading. Rewrite it or drop the node.

So prefer questions whose answer is *derivable*: why an alternative was unsound rather than
merely unpromising, what a design pays for what, which constraint forces a choice, what a
pre-committed falsifier is guarding against, what breaks downstream if this flips. Where a value
genuinely *is* the decision — a magic constant chosen over the obvious default — ask why that
regime was chosen, not what digits it has.

**"Why did we do X" questions** work the same way, except the options are the rejected
*rationales* where recovered, and otherwise the reason most projects would give for the
conventional choice.

**Watch the stem for leaks — and the run.** The context that makes a recovered alternative
legible often telegraphs the answer: naming the old rule and the symptom that killed it hands
over the fix. Keep the stem to the question; the history belongs in the reveal. Then check each
distractor against the rest of the run's answer key, because on a small tree the likeliest leak
is an option that another question's answer already refutes.

Open with a few fact questions to set the frame, then bias hard toward decision points. **Demote
a decision to a fact question** when it had no live alternative, and also when nothing is
recoverable and no convention qualifies — which leaves no legal distractor at either tier. A
demoted item keeps its triage: it was a real decision, so a miss on it can still be drift.
Demotion isn't an unconditional escape, though — a fact question still needs a near-miss from a
neighbouring part, and on a uniform module there may be none. Then drop the node.

## Asking

One question at a time; options `A` onward — two is enough — and **`D — not sure` keeps that
letter fixed**, so a two-option question runs `A`, `B`, `D` and the gap is deliberate. Accept the
letter in any case, or prose that unambiguously names exactly one option; otherwise ask which
letter, never guess the mapping. A question back instead of an answer isn't a miss: answer it in
one line and re-ask. If the user says **object**, take the note before continuing: what they'd
have preferred, and why. Never ask two at once, and never explain before asking.

## After the answer

**Right** → one line restating why, then the next question. No ceremony.

**Wrong, or `D`** → give the ground truth and its reason in two or three lines, then triage it
back to the user, because you cannot make this call yourself — you know what was built, not
what was wanted:

> *"That's what we did and why. Is that what you wanted?"*

- **"No, I wanted X"** → **drift.** Record it.
- **"Fine, I just didn't know"** → **gap.** Move on.
- **`D`** → gap by definition; skip the triage question.

**When the choice traces to the user's own instruction, cite it before triaging** — *"that's
what we did, because you asked for X — still what you want?"* A "no" there is a **reversal**,
not drift; log it as such. You hold the receipt, so produce it.

A *correct* answer can hide drift too — the user can know a choice, hate it, and sail through.
That is what the standing **object** affordance covers, and an objection goes on the punch list
like any drift. Do not append an objection prompt to individual reveals: on a wrong answer it
duplicates the triage question, and on a right one it either doubles the turn count or gets
buried under the next question.

## Where to go next, and how far

Budget **10–12 questions** on a clean run, and branch on the triage rather than the score.

- **Gap → go up.** Missing a specific usually means the frame above it is missing; more
  siblings at that depth just manufactures more misses. Re-establish the parent, then descend.
- **Drift → go down**, into that decision's dependents. Drift propagates and every question
  there is actionable, so run past the budget until the affected subtree is clear.
- **Three `D`s in a row, anywhere in the run** → stop early. The tree is above the user's frame,
  and more questions at that depth will only repeat the result. Make the same offer as below.
- **Gap rate still high once the budget is spent** → stop and say it plainly: *"You're not
  behind on details, you're missing the frame."* Offer to walk the artifact, or hand off to
  `tutor` with the artifact as its source and this session's gaps as the syllabus.

## What it leaves behind

- **Clean run** → chat only. Close with the score and **what the tree holds that was never
  touched**. Never let a spent budget silently read as full coverage.
- **Any drift, reversal, or objection** → write `quiz-findings-<target>-<date>.md` in the working
  directory and give the path in the closing line; for a session target, name it after the thing
  that was built. Per entry: **the type** (drift / reversal / objection), the question that
  raised it — or what the user was reacting to, for an objection raised between questions — what
  they expected, what exists, where it lives, and, for a decision question, **whether the
  alternative was recovered or was the conventional default**. For a reversal, the instruction
  you cited. Without the provenance field the punch list outlives its own caveat.

## Example

> **Scope** — the crawler rewrite from this session, re-read from disk; 11 decision points.
> Answer with a letter, `D` if unsure, and say **object** any time you dislike a choice.

Two options, because only one alternative was recoverable — the shape to expect, not a
degenerate case:

> **Q3.** When a fetch fails mid-batch, what happens to the rest of the batch?
> **A** — the whole batch is retried from the start
> **B** — the batch continues; the failure is collected and reported at the end
> **D** — not sure
>
> *user: A*
>
> **B.** Failures are collected and surfaced after the batch finishes. Whole-batch retry (your
> A) was weighed and dropped — the fetches aren't idempotent, so a retry double-posts. Was
> that the call you wanted?
>
> *user: no, I assumed we'd retry. I want retries.*
>
> **Drift**, logged. That choice has two dependents — the checkpoint format and the CLI's exit
> code — so the next questions go there.

A tier-2 reveal, where the distractor is the convention rather than a recovered proposal. Note
it is never framed as something that was weighed:

> **A.** The pool waits on the port with no deadline at all. Most services bound that wait and
> exit non-zero so the orchestrator restarts them — this one blocks forever instead, so a
> database that never arrives hangs the container rather than crashing it. Is that what you
> wanted?
