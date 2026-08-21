---
name: codebase-design
description: "[Design] Shape module interfaces so complexity is hidden behind narrow, deep boundaries. Use when defining a new module's interface, judging whether a boundary earns its keep, or before a larger architecture pass. Reads CONTEXT.md/docs/adr when present; never requires them. Not a codebase-wide audit (that is improve-codebase-architecture) and not product/approach design (that is brainstorming)."
---

# Codebase Design

Say this first, plainly: `Using the codebase-design skill to shape this interface.`

## What this guarantees

One thing: given a module — new or existing — this skill produces an interface shaped
deliberately, from at least two competing designs, judged against what it costs a caller
to use and what it hides from them. It does not guarantee the interface is small. It
guarantees the interface earned its shape instead of being whatever fell out of the first
draft.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
reaches further than a single module's boundary.

## The depth principle

A module has two costs: what it costs to build, and what it costs every caller to learn
and use. The second cost is paid over and over, by people who never read the
implementation. Judge a module by the ratio between what its interface asks a caller to
know and how much work happens once that caller has asked.

A **deep** module has a narrow, simple interface sitting in front of a large amount of
work. A caller states what it wants; the module decides how. A **shallow** module's
interface is nearly the whole module — every parameter the caller passes maps to a
decision the module makes no attempt to own, so reading the interface teaches you most of
what the implementation does anyway. A shallow module isn't wrong because it is small; it
is wrong because it charges callers close to the full cost of the complexity it contains,
while still keeping that complexity fenced off in a separate file, so nobody gets the
benefit of the fence.

Depth is the goal because a codebase's total cost to work in is closer to the sum of its
interfaces than the sum of its implementations. Every caller reads the interface; only the
maintainer reads the implementation. Trading implementation effort for interface
simplicity is usually a good trade, because it is paid once and collected on every call
site forever after.

Depth is not free and not always right — a module that hides too much becomes a black box
nobody can extend, and some seams belong to the caller (a widget library shouldn't decide
your layout for you). Judge each boundary on its own call sites, not by a rule that deeper
is always better.

`DEEPENING.md`, alongside this file, is the list of concrete moves that turn a shallow
module deep: pulling complexity down behind the interface, widening what one call is
responsible for, collapsing layers that only forward, and defaulting the case that shows
up nine times out of ten. Use it once you've decided a module is shallow and need to know
what to actually change.

## Information hiding and leakage

A module hides information when a caller cannot tell, from the interface alone, how the
module does its job — what data structure it keeps, what order it does things in, what
library or protocol sits underneath. Hiding that is the entire mechanism by which a deep
module stays deep: the caller pays for the interface, not the implementation, only as long
as the implementation stays invisible.

A leak is any place a caller has to know something about the inside to use the outside
correctly. Leaks rarely show up as a leak; they show up as friction at the seam, and the
friction has a small set of recognizable shapes:

- **A parameter that only makes sense with inside knowledge.** A flag whose correct value
  depends on which internal code path the module will take is not configuration — it is
  the caller doing part of the module's job from outside.
- **A required call order.** If callers must call `open` before `write` before `close`, or
  `validate` before `save`, the module has externalized its own state machine. The caller
  now has to hold invariants that belong to the module.
- **Repeated call-site choreography.** When two unrelated call sites contain the same
  three-call sequence in the same order, that sequence is a missing method, and every
  place it's copied is a place the module's internals are exposed and can drift out of
  sync.
- **A change inside the module forcing a change outside it.** This is the sharpest test.
  If renaming a private field, swapping a data structure, or changing an internal
  algorithm requires editing a caller, the interface was never actually hiding that
  detail — it was passing it through.

Not every exposed detail is a leak. A module built specifically to give the caller control
over something — a database transaction boundary, an event ordering guarantee — is meant
to expose that thing; the leak test is about accidental exposure, not designed contracts.

## Design-it-twice discipline

The first interface shape you sketch is anchored on whatever you were thinking about
right before you sketched it — usually the implementation, since that's what's in your
head. It is rarely the deepest available shape, and you cannot tell how good it is by
staring at it alone, because you have nothing to compare it to.

Before committing to a module's interface, sketch at least two genuinely different
shapes — not two phrasings of the same shape, but two different allocations of
responsibility between caller and module. `DESIGN-IT-TWICE.md`, alongside this file,
covers how to generate a second design that actually differs from the first, and the
criteria for choosing between them once both exist: what a call site has to know, how much
of the module's machinery never has to reach the interface, and whether the interface lets
a caller hold it wrong and not notice. Do this before writing the implementation, not
after — comparing two sketches costs minutes; comparing two finished modules costs a
rewrite.

## Reading the substrate

Before shaping a new boundary, check whether the project has already made decisions this
boundary should respect. `CONTEXT.md`, at the project root, and `docs/adr/` are the two
places those decisions tend to live — names already chosen for a concept, a boundary
already drawn between two modules, a tradeoff already argued out and settled.

Read them **when present**. When either exists, treat what's in it as a constraint on the
shape you're sketching, not a suggestion to route around: reusing an established name or
boundary is worth more than a locally cleaner one that fights the rest of the codebase.

Neither file is required. Most modules get designed with no `CONTEXT.md` in sight and no
ADR on point, and that is the ordinary case, not a degraded one. When present, they're
read; when absent, this skill proceeds on the module and its immediate neighbors alone,
and does not stall waiting for documentation that isn't there.

## Boundaries — what this does not do

- It does not **audit a codebase.** Looking across every module for shallow interfaces
  and drawing an improvement plan is `improve-codebase-architecture`, a command that runs
  this skill's vocabulary at a different scale. This skill shapes the one boundary in
  front of it and stops there.
- It does not **decide what to build.** Whether a feature is worth building, and roughly
  what approach it takes, is settled in `brainstorming`, before there's a spec and before
  any module exists to have an interface. This skill starts once there's a module — new or
  existing — whose boundary needs shaping; it does not weigh in on product direction.
- It does not **implement.** Sketching interface shapes and choosing between them is not
  writing the module. Once a shape is chosen, building it is ordinary implementation work,
  outside this skill.
- It does not **skip the second design.** A single sketch, however confident it looks, is
  not this skill's output. If there is only one shape on the table, the discipline in
  `DESIGN-IT-TWICE.md` has not run yet.
