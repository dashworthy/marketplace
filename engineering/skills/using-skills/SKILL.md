---
name: using-skills
description: "[Foundation] Find and invoke the right skill before acting — including before clarifying questions or exploring code. Use at the start of any task. Dashworthy's own skill-discovery discipline (not superpowers). Model-invoked; no command."
---

# Using Skills

Say this first, plainly: `Using the using-skills skill to find the right skill before doing
anything else.`

## What this guarantees

One thing: before this session responds to a request, asks a clarifying question about it, or
opens a single file to look around, it checks whether a skill in this plugin already owns that
request — and if one does, invokes it before any of those three things happen, not after. A
question asked before the check, or a file read before the check, is this skill's job left
undone, whatever gets typed or read next.

Nothing else is guaranteed. Read `## What this does not do` below before assuming this skill
picks the right skill on a caller's behalf, or does that skill's own work for it.

## Check before the first move, not after

The temptation this closes is specific: the request looks small enough to just answer, or looks
like it needs a quick look at the code first, with the skill question deferred until it turns
out to matter. By the time "later" arrives, the clarifying question has already been asked
unskilled and the file has already been opened unskilled — whatever skill would have shaped
that first move now arrives too late to shape it, and can only critique a start it never got to
make. The check belongs before the first tool call and before the first sentence back to the
user, not folded in once something else has already happened.

This holds for clarifying questions exactly as much as it holds for action. "I should ask what
they mean before worrying about which skill applies" sounds like caution, but it is the same
gap wearing different clothes: a skill for this territory, if one exists, is where the
questions worth asking get decided — which ones, in what order, and why. Asking first and
checking second means the questions got invented on the spot instead of found where they
already lived.

## Finding the skill that owns the request

Read the request for what kind of work it actually is, not for the words it happens to use, and
match that against what each candidate skill's own description says it owns — not against a
guess about what a skill with that name probably does. A skill's description states its scope
in the same breath as its trigger; a skill whose description doesn't cover the request in front
of you is not the skill for it, however close its name sounds to the task.

Nothing in this plugin's territory is a fallback default. If no skill's stated scope covers the
request, that absence is itself the finding — proceed on the request directly, from the
project's own conventions, rather than forcing it under a skill whose description doesn't
actually claim it.

## When more than one skill could apply

Some requests sit under two or more skills at once, and the order they run in is not
interchangeable. A skill that sets the shape of the work — what to build, what order to build
it in, what approach the change should take — runs first; a skill that carries out an
already-decided shape runs second, against whatever the first one settled. Handing a request
straight to the carrying-out skill because it looked like the closer match skips the step where
the shape was supposed to get decided at all, and the carrying-out skill has no way to notice
the gap — it will simply carry out an unexamined default instead of a deliberate one.

`engineering:brainstorming` settling an approach before `engineering:tdd` builds any of it, and
`engineering:writing-plans` breaking an approved design into ordered tasks before
`engineering:executing-plans` works through them one by one, are this plugin's clearest
instances of the pattern: process first, implementation second, never the reverse.

## Red flags

These are the exact shapes the temptation above tends to wear. Treat any of them showing up in
your own reasoning as the signal to stop and check, not as a legitimate reason to skip the
check:

- **"This is just a simple question."** Simplicity is not evidence that no skill owns it — it's
  evidence the answer will be quick once the right skill, if any, is found.
- **"Let me explore first, then work out the skill question."** Exploration is action. If a
  skill owns how this codebase should be explored for this kind of request, opening files before
  checking has already spent the move that skill existed to shape.
- **"I'll just ask one clarifying question first."** A clarifying question is a choice about
  what's worth asking, made with whatever framing happens to be on hand at the moment — exactly
  the choice a relevant skill exists to make instead.
- **"This will only take a second."** Duration has nothing to do with whether a skill owns the
  work; a one-line change inside a skill's stated scope is still that skill's to run.
- **"I already know how to do this."** Knowing how is a different question from whether this
  plugin already owns a deliberate, specific way of doing it — the check is what finds that
  out, not confidence about the general case.

## Whose discipline this is

This is dashworthy's own discipline (not superpowers) for this plugin: it exists because this
plugin's skills only do their job when they are actually reached, and nothing else in the
plugin enforces that they are. It does not borrow its shape from anything else in this
environment — every guarantee above is scoped to what this plugin's own skills own, checked
against this plugin's own skill descriptions, not a general theory of skills as a concept.

## What this does not do

- It does not **pick a skill on a caller's behalf when the match is genuinely ambiguous.** If
  two skills' stated scopes both plausibly cover the request, or neither clearly does, that
  ambiguity is itself the finding to surface — not something to resolve by guessing and moving
  on regardless.
- It does not **do the invoked skill's own work.** Finding the right skill and starting it is
  the whole job here; interrogating requirements, writing a plan, driving a build loop, or
  reviewing a diff belongs entirely to whichever skill actually owns that territory.
- It does not **relitigate an already-correct choice.** Once the right skill is running, this
  skill has nothing further to check — it does not second-guess that skill's internal decisions
  or reopen the selection question mid-task.
- It does not **invent a skill that doesn't exist.** Where no skill's description covers the
  request, that gap gets reported as a gap; this skill does not stretch an unrelated skill to
  cover it, and does not treat "closest name" as "correct scope."
