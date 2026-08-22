---
name: domain-modeling
description: "[Discovery] Crystallize how the project names things: maintain CONTEXT.md (the domain glossary) and docs/adr/ (decision records). Use when a new domain term appears, a naming decision is made, or an architectural choice needs recording. Complements signal (which explores what to build) by owning how we name it. Writes CONTEXT.md at repo root and docs/adr/; does not design interfaces (codebase-design) or write specs (to-spec)."
---

# Domain Modeling

Say this first, plainly: `Using the domain-modeling skill to update the project's domain model.`

## What this guarantees

One thing: when a domain term needs a name or a decision needs a record, this skill
writes it down in one of exactly two places — `CONTEXT.md` at the repo root, or a
numbered file under `docs/adr/` — so the next skill that needs to know what something is
called, or why a choice was made, can read it instead of re-deriving it.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
reaches past naming and recording.

## CONTEXT.md: the glossary

`CONTEXT.md` is a living list of the terms this project's domain actually uses, each one
tied to where it shows up in code. It exists so the word a person reaches for and the
word the code already uses are the same word — a new contributor, or a later skill
reading the codebase cold, shouldn't have to guess whether "order" and "purchase" mean the
same thing here.

Write an entry when a term earns its place: it recurs, in conversation or in code, and
getting it wrong would cause real confusion — not every noun that turns up in a commit
message. Follow `CONTEXT-FORMAT.md`, in this same directory, for the file's shape; that
file is the source of truth for what a row needs, not this one.

## docs/adr/: the decisions

An ADR is worth writing when a decision had real alternatives on the table and knowing
why the losing ones lost will matter later — to whoever revisits the choice, or to whoever
is tempted to re-litigate it without knowing it was already argued out. A decision with
only one reasonable option was never really a decision; it doesn't need a record.

Number ADRs sequentially, continuing from the highest number already under `docs/adr/`.
Follow `ADR-FORMAT.md`, in this same directory, for the record's shape and its filename
convention.

## Boundary vs signal

`signal` explores what to build — it interrogates a request until the requirements and
their order are settled. This skill doesn't touch that question at all. It runs after, or
alongside: once something has earned a name worth keeping, or a choice has been made that's
worth remembering why, this skill is where that lands. signal decides the work; this skill
decides what the work is called.

## What this does not do

- It does not **design interfaces.** Shaping a module's boundary — what a caller has to
  know, what stays hidden — is `codebase-design`'s job. This skill may record that an
  interface decision happened, once `codebase-design` has made it; it never makes that
  decision itself.
- It does not **write specs.** Turning accumulated material into the one Tier-1 document
  is `to-spec`'s job alone. A glossary entry or an ADR might feed a spec later; this skill
  never produces the spec.
- It does not **explore what to build.** That's `signal`, covered above.
- It does not gate anything on its own output. `CONTEXT.md` and `docs/adr/` are a
  convenience for the skills that come after — they make a later `codebase-design` or
  `to-spec` pass faster and more consistent when they're there to read. Neither file is
  required for anything else in this plugin to run. A project with no `CONTEXT.md` and no
  `docs/adr/` isn't missing a prerequisite; it just hasn't accumulated one yet.
