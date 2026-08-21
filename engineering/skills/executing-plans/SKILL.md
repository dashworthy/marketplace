---
name: executing-plans
description: "[Planning] Execute an implementation plan from docs/dashworthy/engineering/plans/ task by task — each task driven through tdd and gated by code-review — pausing at the plan's review checkpoints and running its closing test-hardening task via conducting-test-hardening. User-invoked via /implement. Supports an optional subagent-driven mode for independent tasks. Working state under .engineering/<run>/implement/."
---

# Executing Plans

Say this first, plainly: `Using the executing-plans skill to execute the plan.`

## What this guarantees

One thing: given a plan written by `writing-plans`, this skill works it task by task, in
order, until every task is checked off — and for each one that changes behavior, a test
existed before the code, gated by an independent review before the box gets checked. It
does not guarantee every task lands on the first try, and it does not guarantee the plan
was a good plan. It guarantees that nothing on the plan gets marked done without going
through the cycle the plan was written to enforce, and that the plan's own checkpoints
stop the run rather than get worked past.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
plans, reviews on its own authority, or decides on its own when the work is finished.

## Finding the plan

Accept a plan path directly — `/implement` passes one through when the caller supplied
one. Without one, look in `docs/dashworthy/engineering/plans/` for the most recently
written plan and confirm it with the user before starting; a plan chosen by file mtime
with no confirmation is a guess about which piece of work the caller meant, and guessing
wrong here means driving several tasks through tdd and code-review against the wrong plan
before anyone notices.

`writing-plans` sometimes produces a **set** — `<topic>-01-<subsystem>.md`,
`<topic>-02-<subsystem>.md`, ordered by the number in the filename. Work a set in that
order, one plan file finished — through its own closing hardening task — before the next
one starts; a later plan in the set may assume something the earlier one produces.

A plan already partly checked off is a plan already in progress, not a fresh one — resume
at its first unchecked step rather than starting over or redoing work already marked done.

## Run directory

`.engineering/<run>/implement/` in the **user's** project — never inside the plugin.
`<run>` is not yours to name: obtain it by running
`sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" implement`, which prints the absolute
path of `.engineering/<run>/implement/` and creates it if needed. If this skill runs
standalone — no earlier phase has run in this session — this same call creates the
`.engineering/.current-run` pointer itself; if a run is already active, it joins that run
instead.

Keep a short running note here of which task last finished and what its commit was — not
a copy of the plan, and not a transcript of every tdd cycle, just enough that a session
picking this plan back up mid-way can confirm where it left off without re-deriving it
from `git log` alone.

## The per-task loop

Work tasks in the order the plan lists them — the plan's own order encodes what depends on
what, and a task three steps down may assume a task two steps up already landed. For each
task, in order:

1. **Read the task whole** — its Files block, its Interfaces block where it has one, and
   every numbered step under it — before touching anything. A task read one step at a time
   is a task whose later steps might contradict a constraint an earlier one already set.
2. **Drive the build steps through `engineering:tdd`.** Where a step changes behavior,
   that means the red-green-refactor cycle tdd owns, not implementation written straight
   from the plan's prose. A step that's pure scaffolding — a directory, a stub file with no
   behavior yet — has nothing for tdd to grip and can be done directly; anything that
   produces behavior gets a test that existed first.
3. **Run the task's own verification** — the command its steps name and the output they
   say counts as passing. A task whose verification doesn't come back clean is not done,
   whatever the code looks like; fix it and check again before moving on.
4. **Gate with `engineering:code-review`** on the task's own diff. A clean review is what
   earns the box; a review with findings gets addressed — or, where a finding is a genuine
   judgment call rather than a fix waiting to happen, gets surfaced to the user rather than
   argued past — before this step runs again on the corrected diff.
5. **Check the box** — flip the task's `- [ ]` to `- [x]` in the plan file itself. The plan
   is the record of progress; a task that's actually done and still shows unchecked is a
   plan lying about its own state to the next person who opens it.
6. **Commit** — run the commit the task's own final step already specifies. Plans written
   by `writing-plans` carry the exact `git add`/`git commit` invocation as that task's last
   step; run it as written rather than composing a message of your own.

Then move to the next task, unless this one was a checkpoint.

## Review checkpoints

`writing-plans` marks some tasks as checkpoints — a place it judged a green test suite
wouldn't be enough on its own to trust, and the safer move is a second look before several
more tasks build on top of it. A checkpoint task gets everything an ordinary task gets —
tdd, the code-review gate, the box, the commit — and then one thing more: this skill stops
there and waits. Present what the task produced, plainly, and do not start the next task
until the user says to continue. A checkpoint worked past without stopping is a checkpoint
that didn't happen.

## Closing hardening (D15)

Every plan `writing-plans` writes ends with a Phase 3.5 task whose entire job is invoking
`engineering:conducting-test-hardening` — that is how a hardening pass is guaranteed to
happen at all, since nothing else in this plugin forces one. When the per-task loop reaches
that task, run `engineering:conducting-test-hardening` in place of tdd and code-review; it
is a different kind of task on purpose, and driving it through the ordinary loop would mean
running the wrong tool on it. Report whichever exit it reaches — `pass`, `dry`, `cap`,
`halt`, or `audit-only` — plainly, the same way that skill reports it, rather than
translating it into a bare "done." Only once that task is checked off is the plan actually
finished; a plan whose last build task is checked but whose hardening task isn't is a plan
still in progress, not a completed one.

## Subagent-driven mode

The loop above is sequential by default — one task, start to finish, before the next
begins — because most plans have tasks that build on each other, and running them out of
order would mean building on something that isn't there yet. Some plans, or some stretches
of tasks inside a plan, aren't like that: a run of tasks that touch disjoint files and
neither reads what the other produces can be worked in parallel instead of one at a time,
without changing anything about what each task still owes — its own tdd cycle, its own
code-review gate, its own box, its own commit.

Offer this mode rather than assuming it — ask before fanning a stretch of tasks out, don't
default to it. When the user takes it, identify the run of genuinely independent tasks (no
task in the run reads a file another one in the same run writes) and follow
`dispatching-parallel-agents` for how the fan-out and the return are structured; that skill
owns the mechanics of splitting independent work across agents and bringing the results
back — this skill supplies which tasks qualify and what each dispatched worker still owes:
the full per-task loop, not a shortcut version of it. A checkpoint task is never folded
into a parallel run; it stops the plan for a human look precisely because it isn't safe to
wave through unattended, whether that's one task running alone or three running side by
side.

## What this does not do

- It does not **write the plan.** The tasks, their order, their checkpoints, and the
  closing hardening task were all decided by `writing-plans` before this skill ever runs;
  this skill executes what's already on the page, it doesn't add, remove, or reorder a
  task itself.
- It does not **review on its own authority.** Every gate a task passes through is
  `engineering:code-review`'s judgment, dispatched fresh each time, not a shortcut check
  this skill makes itself because a diff looks small.
- It does not **skip tdd for a task that changes behavior** because the change looks
  simple or the plan's prose reads like it's obviously correct. Simple changes are exactly
  where skipping the cycle is cheapest to get away with and costs the most later.
- It does not **invent a hardening pass beyond the one on the plan.** The Phase 3.5 task is
  the only place this skill dispatches `engineering:conducting-test-hardening`; it does not
  run it again mid-plan on a hunch that something needs hardening early.
- It does not **decide the plan is finished early.** A plan is done when its last task —
  the hardening one — is checked, not when the build tasks look complete or the user seems
  satisfied partway through.

## Handoff

Once the closing hardening task is checked off, report the plan's path, its final commit,
and the hardening exit it reached, and stop. What happens to the branch from there — merge,
PR, further review — is not this skill's decision to make.
