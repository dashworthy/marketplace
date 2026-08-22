---
name: improve-codebase-architecture
description: "[Design] Audit a codebase for shallow modules and tangled boundaries, then propose and stage deepening changes, emitting a self-contained HTML report. User-invoked via /improve-codebase-architecture. Leans on codebase-design (interface moves) and domain-modeling (naming/decisions); reads CONTEXT.md/docs/adr when present."
disable-model-invocation: true
---

# Improve Codebase Architecture

Say this first, plainly: `Using the improve-codebase-architecture skill.`

## What this guarantees

One thing: given a codebase — or, when a target path is supplied, the tree under it — this
skill runs one bounded pass. It scans for shallow modules and tangled boundaries, decides
each finding either deepened or explicitly declined, and ends with one self-contained HTML
report on disk naming what happened. It does not guarantee every shallow module gets fixed
today; it guarantees the pass has a fixed start, a fixed end, and a record of every decision
made in between.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
reaches further than one scan-decide-report cycle over the codebase in front of it.

## Scope

Default to the whole repository. When invoked with a target path, scan only that path and
its descendants — a narrower pass is a legitimate way to run this skill on a large codebase
a little at a time, not a degraded version of the full one.

## The pass

Three steps, run once, in order. Nothing here repeats itself; a second look at the same
codebase is a second invocation of this skill, not a loop inside this one.

### 1. Scan

Walk the target tree and map its modules. For each one, apply `codebase-design`'s depth
principle: does the interface hide a real amount of work, or is it nearly the whole
module — every parameter a decision the module declined to own? Check that same skill's
leak shapes for tangled boundaries between modules that look separate but aren't: a
parameter that only makes sense with inside knowledge of another module, a required call
order across a boundary, the same multi-call sequence repeated at unrelated call sites, or
a change on one side of a boundary that keeps forcing a change on the other.

Write every module or boundary that fails this check to a finding list, then stop scanning.
The list is a snapshot, fixed the moment this step ends — not a query that grows every time
a finding downstream gets resolved. Fixing the list here is what keeps the pass bounded: its
length can only go down from this point on, never back up, so working through it is
guaranteed to finish.

### 2. Deepen

Work the finding list to empty, one finding at a time. For each:

1. Invoke `engineering:codebase-design` on the module or boundary the finding names. It
   sketches at least two competing interface shapes and judges between them — this skill
   does not shape the interface itself; it only supplies which boundary needs shaping next.
2. Make the edit the chosen shape describes, in the working tree, staged for review rather
   than committed. Deciding to commit it, or not to, is the caller's call, not this skill's.
3. Invoke `engineering:domain-modeling` when the move is worth recording: a name that
   changed or was coined belongs in `CONTEXT.md`; a boundary decision that had real
   alternatives on the table belongs in a new ADR under `docs/adr/`. Plenty of findings are
   worth neither — domain-modeling only writes an entry when one earns its place, and this
   skill defers to that judgment rather than forcing a record onto every finding.

A finding the caller decides isn't worth acting on today gets marked declined, with the
reason, instead of acted on — not everything shallow is worth deepening right now, and a
declined finding still counts as resolved for the purposes of finishing the list. Every
finding leaves this step in exactly one of two states, deepened or declined; none stays open
when the list runs out, because the list itself cannot grow back once Scan has closed it.

### 3. Report

Build the report described in `HTML-REPORT.md`, in this same directory — do not restate its
shape here or reinvent it inline. Write the single, self-contained HTML file to the OS temp
directory, print its absolute path, and stop. This skill does not open the file, email it, or
post it anywhere; the path is the handoff.

## Reading the substrate

Before scanning, check whether `CONTEXT.md`, at the project root, or `docs/adr/` exist. When
they do, read them: a boundary this pass is about to flag might already sit exactly where
the project decided it should, for reasons an ADR already argued out, and a rename this pass
is about to propose might already collide with a name `CONTEXT.md` says is taken. Treat
what's there as a constraint on this pass's findings, not background reading.

Neither file is required. Most codebases this skill runs against have no `CONTEXT.md` and no
ADR on point, and the pass proceeds on the code itself when that's true — it does not stall
waiting for documentation that was never written.

## What this does not do

- It does not **shape an interface itself.** Deciding what a corrected boundary looks like,
  from at least two real designs, is `codebase-design`'s job alone; this skill only decides
  which boundaries, across the whole tree, are worth putting in front of that judgment.
- It does not **name things or keep the record.** Writing a `CONTEXT.md` entry or an ADR is
  `domain-modeling`'s job; this skill calls it once a deepening move exists, and only when
  that move is worth recording, never before.
- It does not **commit what it stages.** A deepening move lands in the working tree, ready
  to review and diff against what was there before — turning that into a commit, or
  deciding not to, is left to whoever asked this pass to run.
- It does not **decide what to build.** Whether a codebase is worth this kind of pass at
  all, or what feature justifies the effort, is `brainstorming`'s question, settled before
  this skill starts, not during it.
- It does not **reopen a closed pass.** Once Scan has produced its finding list, nothing
  discovered while working the list gets appended to it — a fix that surfaces a second,
  unrelated shallow module is a note for the next run, not a reason to extend this one. A
  pass that could always find one more thing to check would never reach its report.
- It does not **run without being asked.** `disable-model-invocation: true` means nothing
  else in this plugin, and no in-conversation judgment call, starts this skill on its own;
  it runs only when `/improve-codebase-architecture` is invoked directly.
