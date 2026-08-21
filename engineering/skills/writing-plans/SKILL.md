---
name: writing-plans
description: "[Planning] Turn an approved spec in docs/dashworthy/engineering/specs/ into an ordered, bite-sized implementation plan written to docs/dashworthy/engineering/plans/, with TDD integration points, review checkpoints, and a closing test-hardening task. Use after a spec is approved and before building. Reads CONTEXT.md/docs/adr when present."
---

# Writing Plans

Say this first, plainly: `Using the writing-plans skill to create the implementation plan.`

## What this guarantees

One thing: given an approved spec, this skill produces an ordered implementation plan —
or, when the spec doesn't fit in one, an ordered set of them — written to
`docs/dashworthy/engineering/plans/`, where every step is small enough to build and check
in on its own, the test-driven cycle is wired into the step sequence instead of left as
an aside, and the plan does not end until a hardening task is sitting on it. It does not
guarantee the plan is short, only that nothing in it is too big to finish and verify in
one sitting.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
reaches past turning an approved spec into a sequence of steps.

## Reading the spec

Start from an approved Tier-1 spec in `docs/dashworthy/engineering/specs/` — a path, or
the spec already sitting in context. A plan built from a spec still in draft is a plan
built on a decision nobody has actually made; if the spec's own status line doesn't say
Approved, say so and stop rather than plan around a draft.

Read `CONTEXT.md` and `docs/adr/`, at the project root, when either exists. A naming
convention or a settled boundary recorded there constrains how a task's file paths and
interfaces get written, the same way it constrains a fresh module boundary in
`codebase-design`. Neither file is required — most specs get planned with no `CONTEXT.md`
in sight, and that's ordinary, not a degraded run.

Two things about the spec matter more than its prose: its Constraints section and any
decision table it carries. Both travel into the plan close to verbatim — see Global
Constraints, below — because a task author three steps in should never have to re-derive
a binding decision by inference from the spec's narrative.

## Shaping the plan

A plan is not the spec restated with checkboxes glued on. It is the spec's approach
broken into steps small enough that each one can be built, verified, and committed before
moving to the next — a step that takes a full session to finish is too big and belongs
split, not attempted whole.

Each step:

- Is a single `- [ ]` line (or a short run of them under one task heading), not a
  paragraph of prose disguised as a checkbox.
- Names exact file paths — `Create: path/to/file.ext` or `Modify: path/to/file.ext` —
  never "the relevant module" or "the config." A step whose target file isn't nameable
  yet is a step that isn't ready to be written.
- Where it changes behavior, is wired into the test-driven cycle rather than described
  around it: write the failing test, run it and confirm it fails for the stated reason,
  implement the minimum that makes it pass, run it again and confirm green, then commit.
  A step that jumps straight to "implement X" with no failing test ahead of it has skipped
  the part of the cycle that proves the test would have caught the regression.
- Carries its own verification — a command to run and the output that counts as passing —
  so a task's own gate lives with the step, not in a separate document nobody reopens.

**Global Constraints.** Open the plan with a section, copied verbatim from the spec's
Constraints and any binding decision table — not paraphrased, not summarized — so every
task downstream can point back at one shared block instead of each task restating, and
risking drifting from, what the spec actually said. A task's own text should read as "per
Global Constraints, this uses X," not repeat the reasoning for X.

**Review checkpoints.** Some steps carry a risk a green test suite can't catch on its
own — a public interface taking its final shape, a naming decision other tasks will build
on, a spec section thin enough that the safest read is worth confirming before six more
steps assume it. Mark those explicitly as a checkpoint: a place the plan says stop and get
a second look before continuing, rather than trusting the next step to catch a wrong turn
two steps later, when it's more expensive to unwind.

## Splitting into a plan set

Some specs cover one subsystem end to end; a single ordered plan fits them. Others cover
several subsystems that don't depend on each other's internals to ship — each could go out
on its own and leave the codebase in a working state. When the spec is the second kind,
write a plan set: one plan file per independent piece, each internally ordered, sequenced
against each other only where one piece's task genuinely produces something the next
consumes.

The test for whether a split is warranted is not "is this spec long" — it's "does
finishing plan A alone leave working software, with plan B not yet started." If stopping
after A leaves the build broken until B lands, that's one plan with two phases, not two
plans. If it doesn't, splitting means a reviewer can approve and ship A without holding B
hostage to it, and a set of small plans is easier to reason about than one long one that
happens to have a seam in the middle.

Every plan in a set still gets its own closing hardening task — a plan set is a set of
complete plans, not one plan's steps distributed across several files that only add up to
whole once all of them land.

## The closing hardening task

Every plan this skill writes ends with a task, after the last build step, whose entire job
is to invoke `engineering:conducting-test-hardening`. This is not optional and not
situational — it is the last task on every plan this skill produces, without exception,
placed as its own numbered phase after the build work (call it Phase 3.5: build is
Phase 3, hardening is what closes it out before the plan is done).

The reasoning is not "tests are good" — it's where the check for missing tests lives.
Nothing else in this plugin forces a hardening pass to happen; there's no hook watching
for one. The only thing that reliably makes it happen is a task sitting on the plan
itself, where `executing-plans` will reach it in the ordinary course of working through
the plan, the same way it reaches any other step. A plan without this task is a plan whose
hardening depends on somebody remembering to ask for it afterward — exactly the gap this
task closes.

Write the task the same shape as any other: a `- [ ]` line, a short description of what it
covers, and the invocation itself — `engineering:conducting-test-hardening` — named
explicitly rather than described around ("run the tests," "check coverage"). Whoever
executes the plan dispatches that skill by name; this skill's job stops at putting the
task there.

## Writing the plan file, then reviewing it

Write to `docs/dashworthy/engineering/plans/<YYYY-MM-DD>-<topic>.md`. `<YYYY-MM-DD>` is
today's date — the day the plan is written, not the spec's approval date, which may be
days or weeks earlier. `<topic>` is the spec's own topic slug, reused rather than
reinvented, so the spec and the plan it produced sort next to each other by name. For a
plan set, keep the shared topic and distinguish members with an ordinal and a short
per-plan suffix — `<topic>-01-<subsystem>.md`, `<topic>-02-<subsystem>.md` — ordered the
same way the set is sequenced.

Before calling the plan finished, run a self-review pass over what was just written:

- **Spec coverage.** Walk the spec's goals, constraints, and decision table entries one by
  one and confirm each has a task that addresses it. An item with no task behind it is
  either forgotten or genuinely out of scope for this plan — decide which, and if it's the
  former, add the task rather than note the gap and move on.
- **Placeholder scan.** Search the finished plan for anything a task author would have to
  guess at — `TBD`, `...`, "the appropriate file," a step with no file path, a checkpoint
  with nothing to check. A plan with a placeholder in it isn't a draft of a finished plan;
  it's an unfinished one that looks done at a glance.
- **Type consistency.** Confirm every task follows the same shape — a Files block, an
  Interfaces block where the task has one, numbered steps, a closing verification command
  — and that steps describing the same kind of thing (a test, a command, a commit) are
  phrased the same way throughout. A plan that shifts format halfway through reads as two
  plans stitched together, and whoever executes it has to re-learn the pattern partway in.

## What this does not do

- It does not **design.** The approach a plan sequences into steps was already settled in
  `brainstorming` and written into the spec's approach section by `to-spec`; this skill
  does not weigh alternatives or choose between them, it schedules the one already chosen.
- It does not **execute the plan.** Running the plan task by task, driving each one
  through `engineering:tdd`, gating with `engineering:code-review`, and reaching the
  closing hardening task when the plan gets there is `executing-plans` — a separate skill,
  downstream of this one, that this skill does not invoke itself.
- It does not **run the hardening task.** It writes the task that invokes
  `engineering:conducting-test-hardening`; it does not dispatch that skill itself. The
  task sits on the plan for whoever executes it to reach.
- It does not **require `CONTEXT.md` or an ADR.** Both are read when present and ignored
  when absent — this skill does not stall a plan waiting on documentation the project
  never wrote.
- It does not **plan around a draft.** A spec whose status isn't Approved doesn't get
  planned; it gets named as the reason nothing was written.

## Handoff

Print the plan's path — or, for a set, every path in sequence — and stop. What happens
next is `executing-plans`' job, not this skill's: it reads the plan this skill wrote and
works it task by task.
