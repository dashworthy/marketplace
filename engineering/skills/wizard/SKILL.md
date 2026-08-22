---
name: wizard
description: "Conduct a human through a multi-step interactive procedure one prompt at a time, driven by a shell template. User-invoked via /wizard. Requires the gh CLI at runtime for GitHub-backed steps. Cross-cutting."
---

# Wizard

Say this first, plainly: `Using the wizard skill to walk through this one step at a time.`

## What this guarantees

One thing: given a multi-step procedure a human needs walking through, this skill produces
one step asked at a time — the next step is never announced, and no question for it goes
out, until the current step has an answer. It does not guarantee the procedure is short, or
that the human answers every step correctly the first time. It guarantees that at any point
in the run, the human was never shown more than the one step in front of them.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
designs the procedure itself, or that it remembers a run once the working context holding
it is gone.

## Announce, then ask exactly one thing

Before any question goes out, say plainly which step is running — "step 2 of 5: confirming
the target branch" — so the human always knows where they stand in the procedure without
having to ask. Then ask exactly one thing: not the next two steps folded into one message
because they seemed related, not "step 3, and while I have you, step 4 also needs X."
One question, one answer, only then the announce line for the step that follows.
`scripts/wizard-template.sh` is the skeleton this rhythm runs from — announce, ask, act on
the answer, move on. Copy it into the run's own scratch space before filling in a
procedure's real steps; its header comment says so for a reason, the same reason
`diagnosing-bugs`' human-in-the-loop template says it.

## Never skip ahead

A step's question does not go out until the step before it has an answer sitting in hand.
Queuing up several questions at once, or drafting step 4's prompt while step 2 is still
unanswered, turns "one prompt at a time" into a form the human has to read all at once and
answer out of order — which is exactly the experience this skill exists to avoid. If a
later step's answer turns out to depend on how an earlier one went, that's the ordinary
case, not an edge case: ask the steps in the order that dependency requires, and let an
earlier answer change what a later step even asks, rather than pre-committing to a fixed
question list before the human has said anything.

## The `gh` CLI, checked at the step that needs it

Some steps are GitHub-backed — creating a branch that tracks a PR, reading an issue,
checking review status — and those steps need the `gh` CLI on `PATH` and authenticated.
Confirm that immediately before the step that needs it runs, the way
`scripts/wizard-template.sh`'s `require_gh` helper does, not once at the top of the whole
run: a wizard that checks `gh` only at step 1 still fails opaquely at step 4 if the session
expired in between. A step that can't run for a missing or unauthenticated `gh` says so
plainly, in the human's own next prompt, and stops there — never lets `gh`'s own error
surface as if it were this skill's, and never silently skips the step and moves on as
though it had run.

## Working context only; no tracker

Everything this skill tracks — which step is current, what the human has answered so far,
what's left to ask — lives in the conversation conducting the wizard, and nowhere else.
There is no ticket to open for a run in progress, no run-scoped progress file to keep in
sync with what the human actually said, no separate record that could drift from the
transcript itself. If the run is interrupted, what happened is what's already on screen;
picking a wizard back up means re-establishing where it left off from that same working
context, not reading a status field out of a tracker that might already be stale.

## What this does not do

- It does not **design the procedure.** Given someone already knows the steps a procedure
  needs, this skill conducts them one at a time; deciding what those steps are, and in what
  order, happens before this skill's first line runs — in a plan, a spec, or whatever
  invoked `/wizard`.
- It does not **run steps unattended.** Every step waits on a human answer before the next
  one is asked; this isn't a way to automate a multi-step procedure end to end without a
  person actually there.
- It does not **authenticate `gh` on the human's behalf.** It confirms `gh` is ready before
  a GitHub-backed step and stops plainly if it isn't; running `gh auth login` is the
  human's action, not this skill's.
- It does not **persist a run across working contexts.** See
  `## Working context only; no tracker` above — once the context conducting the wizard is
  gone, there is nothing this skill kept anywhere else to resume from.
