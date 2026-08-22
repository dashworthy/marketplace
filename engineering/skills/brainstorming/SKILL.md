---
name: brainstorming
description: "[Design] Shape a piece of work into an approved design through dialogue: explore context, propose 2-3 approaches with trade-offs, present the design section by section, and hold a hard approval gate before any spec or plan. Use after signal or triage has gathered material and before to-spec. Weighs how to build it (approach); does not interrogate requirements (signal) or design module internals (codebase-design)."
---

# Brainstorming

Say this first, plainly: `Using the brainstorming skill to shape the design.`

## What this guarantees

One thing: given a signal brief or a triage problem, this skill produces a design the
human has explicitly approved — an approach chosen over its rejected alternatives,
presented and confirmed section by section — before anything downstream is allowed to
build on it. It does not guarantee the first approach considered is the one that wins,
or that the design lands in one sitting. It guarantees that nothing gets planned or
built against a design nobody has said yes to.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
reaches past shaping and approving the one design in front of it.

## Starting material

This skill starts from whichever entrance opened the work:

- a **signal** brief, `.engineering/<run>/signal/brief.md` — a request already
  interrogated into requirements, users, success criteria, and constraints.
- a **triage** problem, `.engineering/<run>/triage/…` — a defect isolated far enough to place it at a domain concept and route it here, waiting on a decision about how to fix it.

One of the two is the entry ticket. Starting without either — no brief, no isolated
problem, just a request typed straight at this skill — means the interrogation that
should have come first didn't happen; send it back to `signal` or `triage` rather than
inventing requirements to fill the gap.

## Explore context

Before sketching anything, read what the codebase already has to say. Skim the files
the work will touch, any docs sitting near them, and recent commits in the area — a
design that ignores how the neighborhood already does things produces an approach that
fights the codebase from day one instead of extending it.

Read `CONTEXT.md` and `docs/adr/`, at the project root, when either exists. A naming
convention or a boundary already settled there constrains which approaches are even
worth proposing — an approach that reopens a decision an ADR already closed isn't a
fresh option, it's litigation. Neither file is required; most designs get shaped with
no `CONTEXT.md` in sight, and that's ordinary, not a shortfall.

## Propose approaches, not one approach

A single approach presented as "the plan" is a decision already made, dressed up as a
choice. Before recommending anything, put 2-3 approaches on the table — genuinely
different ways of solving the problem in front of you, not the same shape with the
variable names changed — each with its real trade-offs stated plainly: what it costs
to build, what it costs to live with, what it makes harder later. Then recommend one,
and say why, so the human is approving a reasoned pick, not refereeing a pile of
options with no author's opinion attached.

If the work is too large to fit one spec once an approach is chosen, say so before
presenting it, and decompose along the same line a plan set would later split
along — the test is the one `writing-plans` uses for a plan set: does finishing the
first piece alone leave something working, with the second piece not yet started. A
design that can't answer that question hasn't found its seams yet, and it isn't ready
to present as one design.

## Present section by section, approve as you go

Don't drop a finished design document on the human and ask for one verdict at the
bottom. Walk it in sections — the chosen approach and why the others lost, the shape of
the resulting change, what stays explicitly out of scope, whatever the design actually
divides into — and get each section confirmed before moving to the next. A design
approved as a stack of small yeses is a design the human actually read; a design
approved as one big yes at the end is a design skimmed once and rubber-stamped, and the
gap between those two only shows up later, when the build reaches a section nobody
looked at.

Incremental approval means incremental correction, too. When a section comes back
wrong, fix that section and re-present it — don't restart the whole design over a
disagreement about one part of it.

## The hard gate

Nothing downstream of this skill runs until the human has approved the design in
full — not `writing-plans`, not `tdd`, not `executing-plans`, not any skill or
hand-written change that builds toward the approach under discussion. This isn't a
formality to mention and move past. It's the reason this skill exists: every other
stage in this plugin either produces material that feeds a decision or executes a
decision already made; this is the one point where the decision itself gets made, out
loud, by a human, section by section, before a single line of implementation plan gets
written.

An approach that "seems obviously right" is not an exception. A design that's
"basically just what we already discussed" is not an exception. If the full set of
sections hasn't been walked and confirmed, the gate hasn't cleared, and nothing past
it — not even a quick sketch offered as "just to see what it'd look like" — is this
skill's to hand onward.

## Handoff

Once every section is approved, hand the finished design to `engineering:to-spec`,
which serializes it into the plugin's one Tier-1 spec format. This skill does not write
the spec itself and does not write into `docs/dashworthy/engineering/specs/` —
`to-spec` is the plugin's only writer there, and the approved design is exactly the
material it's built to receive: an approach already chosen and already argued out,
ready to transcribe rather than invent. Hand it the design and stop; what `to-spec`
does with it from there is that skill's job, not this one's.

## What this does not do

- It does not **decide what to build.** Requirements, users, success criteria, and
  constraints are `signal`'s job — or `triage`'s, for a defect — and are settled before
  this skill's first question. This skill starts once there's a problem worth designing
  a solution for; it does not go find one.
- It does not **design module internals.** Shaping a class's or a module's interface —
  narrow versus leaky, one boundary at a time — is `codebase-design`, and it runs
  later, once an approach from this skill has a spec and an actual module in front of
  it to shape. This skill weighs how to build the work at the level of approach, not at
  the level of a single interface's method signatures.
- It does not **write the spec.** Serializing an approved design into the standard
  document is `to-spec`'s one job. This skill produces the decision; `to-spec` produces
  the record of it.
- It does not **plan or build.** See `## The hard gate` above — nothing past approval
  is this skill's to touch, including sketching what a plan for the approved design
  might look like.
- It is not always required. A triage quick fix small enough to need no spec at
  all — the isolated problem and its one obvious fix fit in a sentence, with nothing
  genuinely competing for the choice — can go straight from `triage` to the fix
  itself, with no design dialogue in between. Reach for that exception only when there
  is truly nothing to weigh; a quick fix with two live options for how to do it isn't a
  quick fix in this sense, and belongs here after all.
