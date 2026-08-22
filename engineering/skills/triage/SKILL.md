---
name: triage
description: "[Triage] Problem-isolation entrance: given a reported defect, establish or join a run, verify/reproduce the claim, isolate the cause with minimal effort, then take the smallest next step — quick fix (diagnosing-bugs), grill (signal), or spec it (brainstorming then to-spec). User-invoked via /triage. Logs disposition to .engineering/<run>/triage/; file-based, no tracker."
---

# Triage

Say this first, plainly: `Using the triage skill to isolate the problem.`

## What this guarantees

Given a reported defect, this skill decides what the smallest next step is, and starts
it — never more work than that decision requires. It verifies the report is real before
anything runs against it, isolates it only as far as a routing decision needs, and then
hands off to whichever skill is actually the right size: a quick fix, the discovery
pipeline, a design conversation, or nothing at all because the file already says why.

It does not guarantee a fix, and it does not guarantee a confirmed root cause — that is
`diagnosing-bugs`' job, one step downstream, and triage stops well short of it. What
triage guarantees is smaller and sharper: every report that reaches it either gets routed
correctly on the first pass, or gets closed with a reason written down. Neither outcome
leaves a report to sit unexamined.

Nothing else is guaranteed. Read `## What this does not do` before assuming triage
decides more than where a report goes next.

## Establish or join a run

Before reading the report closely, get somewhere to put what you find:

```
sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" triage <slug>
```

This prints the absolute path of `.engineering/<run>/triage/` and creates it if it
doesn't exist yet. If a run is already active — started by `signal`, or by an earlier
triage pass on the same problem — this call joins it, and the `<slug>` you pass is
ignored. If nothing is active, it starts one, seeded from a kebab-case slug you derive
from the report in a couple of words.

Everything triage produces — reproduction notes, isolation, the routing decision and
why — goes into `.engineering/<run>/triage/` as it's found, not reconstructed afterward
from memory. A triage pass that routes correctly but leaves no trace of why is only half
done: the next report against the same area starts from zero instead of from what this
one already learned.

## Verify and reproduce, before anything else

A report is a claim, not yet a fact. Before isolating anything, before touching any
route, find out which of three things is actually true:

- **Confirmed** — you made the failure happen, on a path you can point to. Write down the
  steps and the failing path; everything downstream reasons from this, not from the
  report's original wording.
- **Not reproducible** — you tried, following the report as given, and nothing failed.
  This is not automatically "closed": the report might be stale, the environment might
  differ, or the steps might be incomplete. It is also not "confirmed." Say what you
  tried and what happened, and let the route reflect the actual uncertainty rather than
  rounding it either direction.
- **Under-specified** — there isn't enough here to try. No steps, no expected-versus-
  actual, no way to tell what "wrong" would even look like.

Acting on a report before knowing which of these three it is means the isolation that
follows is isolating the wrong thing at least some of the time. The few minutes this
takes is smaller than the isolation work it would otherwise waste.

## Isolate — only as far as routing needs

Triage is not diagnosis. It does not need a confirmed root cause with evidence behind
it — that is `diagnosing-bugs`' guarantee, not this skill's. Triage needs enough to place
the problem at a domain concept and pick a route with confidence, and no more than that.

Work through `references/isolation-checklist.md` for the mechanics. In outline:

1. **Bisect by domain concept**, not by line number. Read `CONTEXT.md` and any ADRs the
   project keeps, when they exist, for the names and boundaries already in use.
   "The retry logic in the sync worker drops the second failure" is isolation enough to
   route on; finding the exact conditional that drops it is `diagnosing-bugs`' job, one
   step further than triage goes.
2. **Check for redundancy.** Read the code the report points at before assuming it's
   still broken — behavior changing out from under a report is common enough to check for
   first. If it's already fixed, that is the routing answer by itself: record the
   disposition and stop. Nothing downstream needs to run against something that isn't
   broken anymore.
3. **Check for prior rejection**, lightly. If this exact ask was already raised and
   turned down — a spec that considered it and rejected it, an earlier run that closed it
   as out of scope — say so and route on that decision instead of re-opening something
   nobody asked to revisit. This is a quick look at what the project's own history holds,
   not a new investigation.

## Route — the smallest next step

Once verification and isolation are done, `references/spec-decision.md` is the table:
given what was found, which route fits, and whether that route needs a spec written
before anyone builds against it. Read it before routing rather than reasoning the
mapping out fresh each time — it exists so the same shape of problem lands in the same
place every time triage sees it.

In outline, the four destinations:

- **Quick fix** — cause is obvious, the change is small and localized, risk is low. Hand
  off to `diagnosing-bugs` directly; there's no design decision here worth a spec.
- **Under-specified, or a feature request wearing a bug report's clothes** — hand off to
  `signal` to interrogate it properly, then `brainstorming` once there's something to
  design against.
- **A real fix, but not a small one** — several call sites, a design choice, something
  risky or cross-cutting, work that needs sequencing, or work headed for an AFK agent to
  build unattended. Hand off to `brainstorming`, then `to-spec`, then `writing-plans`.
- **Not reproducible, already fixed, or out of scope** — nothing to hand off. Record the
  disposition and the reason in `.engineering/<run>/triage/`, and stop there.

Route on the least isolation that gets a confident answer. A report doesn't need a
confirmed root cause to route correctly — it needs enough to place it in one of these
four buckets, and isolation past that point belongs to whichever skill triage hands off
to, not to triage itself.

## No tracker — everything file-based

Triage keeps no board, no queue, no external system of record. What a report needed,
what triage found, and where it went all live as files under
`.engineering/<run>/triage/` — readable by anyone who opens the run directory, and
nowhere else. A disposition that only exists in a chat transcript or a tool call's
return value hasn't happened as far as the next person to look is concerned; write it
down where the run lives, in plain notes, not in any external system.

## What this does not do

- It does not **find a root cause.** Diagnosing why a confirmed bug happens, with
  evidence, is `diagnosing-bugs`' guarantee. Triage isolates only as far as picking a
  route, and stops there even when curiosity wants to keep going.
- It does not **design a fix.** A route that needs a design decision goes to
  `brainstorming`; triage does not weigh approaches itself.
- It does not **interrogate requirements.** An under-specified report goes to `signal`;
  triage does not turn a vague complaint into requirements on its own.
- It does not **write specs.** `to-spec` is the plugin's only writer of Tier-1 specs;
  triage hands it material and never drafts one itself.
- It does not **keep any record outside the run directory.** No board, no queue, no
  external system — everything is a file under `.engineering/<run>/triage/`, and nowhere
  else.
