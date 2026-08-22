---
name: dispatching-parallel-agents
description: "[Foundation] Fan out 2+ genuinely independent tasks with no shared state to parallel agents and synthesize their results. Use when subtasks do not depend on each other's output. Distinct from executing-plans' plan-scoped subagent mode; a general primitive. Model-invoked; no command."
---

# Dispatching Parallel Agents

Say this first, plainly: `Using the dispatching-parallel-agents skill to run the independent
work in parallel.`

## What this guarantees

One thing: once a caller has framed two or more units of work that share no mutable state,
this skill sends every one of them out at the same time rather than one after another, and
brings every result back together before anything gets built from them — nothing silently
dropped because it returned last, nothing quietly picked as the answer because it returned
first. It does not guarantee the units were correctly judged independent in the first place,
and it does not guarantee any individual agent's work is any good. It guarantees only that
the fan-out and the gathering-back are done right.

Nothing else is guaranteed. Read `## What this does not do` below before assuming this skill
splits the work itself, decides what a dispatched agent owes, or judges what the combined
result means.

## The independence precondition

This is the gate everything else here stands on: dispatch in parallel only what shares no
mutable state. Two units are independent when neither one reads what the other writes and
neither one writes what the other reads — not when they merely sound separate, and not when
they merely touch different-looking parts of the same problem. Two agents editing the same
file, two agents appending to the same log, one agent needing an artifact only the other
produces partway through, both mutating the same session or database state — all of these
are shared mutable state, whatever the task descriptions look like sitting next to each
other. Two agents only *reading* the same file, in contrast, share nothing that breaks the
gate; reading in common is not the hazard, writing or depending on order is.

Establishing that the gate holds is the dispatching caller's job, grounded in what its own
tasks actually touch — this skill has no way to inspect a caller's domain and confirm it on
its own. What this skill does own is refusing to proceed past a run where that judgment
was never made. A task list that "seems like it should be fine to parallelize" is not
independence established; if a caller can't say concretely, for every pair in the run, which
of them reads or writes what the other one does, that is the signal to stop and either get
that answer or split the run into ordered waves instead — never to guess and fan out anyway
on the hope that nothing collides. Below two units, there's nothing to gate: a single task
goes straight to a single agent, sequentially, without this skill's machinery at all.

## Splitting the work

Once independence is established, shape each unit so one agent can finish it alone, start to
finish, with nothing it needs to ask another agent along the way — concurrent agents can't
trade questions or wait on each other's partial output, so a unit that needs mid-flight input
from a sibling was never actually independent, whatever the earlier check concluded. Hand
each agent only its own slice of context: the specific material that unit needs, not the
whole pile the caller is holding. An agent buried in material meant for three other units
spends its effort sorting relevance instead of doing the work, and the caller pays for that
confusion twice — once in the agent's context, once in reading past it in the returned
result.

Match the split to what's actually independent, not to a round number. Two genuinely
separate units dispatched as two agents beats five artificially separate slices of one
real unit dispatched as five — the second just multiplies synthesis work without adding any
real parallelism.

## Dispatching

Send the whole wave at once. In this harness that means issuing every unit's `Agent` call
inside the same message rather than one call, its reply, then the next — dispatched one at a
time and waited on serially, agents deliver none of the benefit of parallel work and all of
the risk of the independence gate being wrong, because a caller who dispatches serially never
finds out whether two of its "independent" units would actually have collided running side by
side. Give each agent enough to work from without another agent's context: what it's meant to
produce, the slice of material it needs, and the shape its return should take, so what comes
back is usable without a follow-up round trip to ask what was meant.

## Synthesizing the results

Wait for the entire wave before writing, deciding, or reporting anything. A synthesis built
from whichever agents happened to answer first is missing whatever the slower ones would
have added, and nothing about a synthesis assembled that way discloses that it's incomplete —
it just reads as though it were the whole picture.

An agent that errors, times out, or comes back with an unusable partial result is itself part
of the outcome, not a gap to paper over. Report it next to the units that did finish, plainly,
rather than dropping it silently or inventing a plausible stand-in for what it might have
found. Where two returns actually disagree with each other, write the disagreement down as a
finding in its own right, both sides named — resolving it by quietly favoring whichever one
sounds more confident turns a real gap in the work into a false appearance of agreement, and
whoever relies on the synthesis afterward inherits that false agreement without ever knowing
a choice got made on their behalf.

What shape the combined result takes — one merged file, a single report, a set of applied
edits — is the dispatching caller's to decide; this skill's part of the job ends at making
sure every agent's result is actually in hand, undropped and unaltered, before that shaping
starts.

## Boundary with executing-plans' subagent mode

`engineering:executing-plans` offers an optional subagent-driven mode for a plan whose tasks
don't depend on each other. That mode is scoped tightly to plan execution: it is the one that
decides which of a specific plan's tasks qualify as independent — by checking whether one
task's files overlap with another's — and it obligates every task it dispatches to the full
per-task loop an ordinary sequential task owes: its own TDD cycle, its own code-review gate,
its own checked box, its own commit. None of that is this skill's business.

This skill is the general mechanism that mode is built on, not a rival version of it. It has
no notion of a task, a checkbox, a build loop, or a commit; it knows only how to take units of
work something else has already framed and independence it has already confirmed, run them
concurrently, and bring every result back whole. `engineering:executing-plans` is one caller
among several — `engineering:research` dispatching one agent per framed question,
`engineering:code-review` dispatching one sub-reviewer per axis,
`engineering:conducting-test-hardening` dispatching one audit agent per suite — and each of
those callers supplies its own split and its own idea of what a dispatched agent owes on
return. This skill supplies none of that itself. It is the fan-out and the gathering-back,
shared underneath all of them, and nothing more.

## What this does not do

- It does not **decide which tasks are independent.** It states the gate and refuses to
  dispatch past a run where nobody checked it; confirming that a specific set of units
  actually satisfies it is the calling skill's judgment, made against what its own tasks
  touch, not something this skill can infer from task descriptions alone.
- It does not **serialize a run out of caution when independence is unclear.** An unclear
  case is a case to stop and get an answer, or to split into ordered waves, not a case to
  quietly run one after another and call the result "dispatched in parallel."
- It does not **own what a dispatched agent's own work requires.** A task's build loop, a
  review's axis, a research question's citation discipline — whatever the fanned-out work
  itself demands stays the dispatching caller's to specify; this skill never adds or waives
  any of it.
- It does not **judge what the synthesized result means.** Weighing findings against each
  other, picking a side in a disagreement, or deciding what the combined outcome implies for
  the caller's decision belongs to whoever posed the question in the first place — this skill
  only makes sure every return actually made it back, intact and accounted for.
- It does not **retry a failed agent on its own initiative.** A unit that came back empty,
  wrong, or not at all is reported as exactly that; deciding whether to retry it, reassign it,
  or accept the gap is the caller's call, made with the failure on the record.
