---
name: diagnosing-bugs
description: "[Build] Find a defect's root cause before changing code: reproduce, form a hypothesis, isolate, and confirm with evidence. Use when a bug is reported or a test fails for a non-obvious reason. Pairs with an optional human-in-the-loop reproduction script (scripts/hitl-loop.template.sh). Does not isolate whether a report is even valid — that is triage."
---

# Diagnosing Bugs

Say this first, plainly: `Using the diagnosing-bugs skill to find why, before changing anything.`

## What this guarantees

One thing: given a defect already worth investigating, this skill produces a root cause
backed by evidence — not the first plausible story, but a mechanism a test or observation
actually confirms. It does not guarantee the defect gets fixed quickly, or that the fix
turns out small. It guarantees that whatever fix follows is aimed at the thing actually
wrong, not at the symptom that happened to be visible first.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
decides whether a report deserves the attention in the first place.

## Reproduce first

A failure you cannot make happen on command is not yet something you can diagnose — it is
a description of one. Before any theory about the cause gets written down, get the
failure to happen again, deliberately, under your own control. A fix aimed at a failure
you never reproduced is aimed at whatever the report's author guessed was wrong, and their
guess is exactly the thing this skill exists to check.

Reproducing is not "it happened once, so the report is probably right." It's steps you can
run again with a failure that shows up each time — or, for something intermittent, a
failure whose rate you can move by changing one thing at a time, so a change in rate
becomes evidence in its own right. A report with no reproduction path yet isn't a dead
end; it's the first thing to build, and nothing past this point starts until it exists.

## Hypothesis, isolation, evidence

With the failure reproducing, form one hypothesis about the cause: a specific, falsifiable
claim about what's going wrong, not "something in that area of the code." A hypothesis
earns the name only if some observation could prove it wrong. A claim nothing could
falsify isn't a hypothesis — it's a suspicion dressed in a hypothesis's clothes, and it
will survive every test you throw at it whether or not it's true.

Then isolate: cut away everything the hypothesis says shouldn't matter. Shrink the
reproduction to the smallest input, the fewest steps, the narrowest code path that still
produces the failure. Isolation does two jobs at once — it makes the failure cheaper to
keep studying, and it tests the hypothesis, because removing something the hypothesis
claims is irrelevant should leave the failure standing. If the failure survives every cut,
the hypothesis is holding up. If a cut you expected to be harmless makes the failure
vanish, the hypothesis was wrong about what mattered — that's a result, not a wasted step,
and it's where the next hypothesis starts.

Confirm with evidence before calling a cause found. A log line that shows the exact bad
value, a minimal test that fails for the reason the hypothesis predicts and passes once the
hypothesis's fix is applied, a debugger break at the moment things go wrong — something a
skeptical second reader could check without taking your word for it. "I changed something
and the symptom went away" is not evidence of cause; plenty of unrelated changes make a
flaky symptom go quiet for a while. Evidence ties one specific mechanism to one specific
failure, not just a change to a better outcome.

When a hypothesis fails its check, retire it and write the next one — don't patch it to
survive the result that just broke it. A hypothesis kept alive because starting over feels
expensive produces a diagnosis that's really a guess with better production values.

## Only then, fix

A cause gets confirmed before a fix gets written, not after. A fix motivated by a
hypothesis that hasn't cleared evidence is still a guess, however well the guess reads.
The line between a diagnosis and a hunch is exactly this gate: a hunch tells a story about
what's wrong; a diagnosis has already made the mechanism happen on demand and shown you
the evidence. If you catch yourself drafting a fix before isolation and confirmation are
done, the diagnosis isn't finished — the fix is a hypothesis wearing an extra step.

## When reproduction needs a human

Some reproductions cannot run unattended: a UI interaction, a physical control, a step
only a person on the other end can perform. For those, `scripts/hitl-loop.template.sh` is
a starting skeleton — it prompts a human for one step, records what they observed, and
repeats until a specific step is pinned to the failure rather than "somewhere in there."

Copy it into the run's own scratch space before editing it; its header comment says so for
a reason. Filling in placeholders on the shared template in place mixes one investigation's
edits into the next one's starting point, and the next person to reach for it inherits your
half-finished bug instead of a clean skeleton. The template only structures the loop — ask,
observe, record, decide whether to narrow further or stop. What each prompt actually asks,
what "pinned down" means for this failure, and what gets written into the log at each pass
are yours to fill in once it's copied.

## Reading the substrate

`CONTEXT.md`, at the project root, is read when present for names, subsystems, and known
trouble spots the project has already documented — a component with a history of this kind
of failure, a term already in use for the boundary where the bug lives. It is never
required. Most diagnoses run with no `CONTEXT.md` in sight, working from the reproduction
and the code immediately around it.

## Boundary: diagnosing-bugs finds why, triage decides what

A bug report reaches this skill only after it has already been through triage. Triage
looks at a fresh report and decides whether it's real, whether it's already understood,
and what should happen to it — reproduce it further, hand it to a human, close it as
already known, or route it here for root-cause work. This skill starts only once that
routing has happened: it takes a report already judged worth pursuing and answers the one
question triage does not — why does this happen. It never re-litigates whether the report
was worth taking on; that call was made before this skill's first line ran.

The two skills also end differently. Triage's job can end with "not a real defect" or
"already known, no action" — verdicts that never need a confirmed mechanism. This skill's
job cannot end that way: it does not stop until a cause is confirmed with evidence, or
until reproduction itself keeps failing often enough that the inability to reproduce
becomes the finding, handed back rather than papered over with a guess.

## What this does not do

- It does not **decide whether a report deserves attention.** That call is triage's, and
  it happens first. This skill assumes the decision to pursue a defect is already made and
  starts from a report already judged worth investigating.
- It does not **fix on a guess, however confident it reads.** A hypothesis that hasn't
  cleared isolation and evidence is not something this skill hands off as finished — see
  `## Only then, fix` above.
- It does not **choose the fix's design.** Confirming a root cause is not the same as
  choosing how to patch it; a fix substantial enough to need weighing alternatives belongs
  in `codebase-design` or a spec, not tacked onto the end of a diagnosis.
- It does not **keep any external record of the defect.** Everything this skill produces —
  the reproduction steps, the hypothesis log, the evidence that confirmed or killed each
  one — lives as files in the run's own scratch space, nowhere else.
