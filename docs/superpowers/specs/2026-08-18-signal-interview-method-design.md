# Design: Signal adopts the hypothesis-driven interview method

**Date:** 2026-08-18
**Status:** Approved for planning
**Source material:** `chrislema/claude-files`, `interview/instructions.md` and `interview/artifacts.md`

## Summary

Signal today converts a vague build request into one dependency-ordered brief. It
interrogates by asking open questions and refusing vague answers, in a single
session, producing a single artifact.

This design changes how signal asks and how a session survives ending. Two things
are adopted from the interview method:

1. **Hypothesis-driven probing.** Signal offers the conventional answer and invites
   correction, instead of asking open questions. Agreement means the ground is
   standard; correction marks a departure, and departures are where the real
   requirements live.
2. **Session continuity.** A new working file, `open-threads.md`, is written
   continuously during the interrogation. A session that ends before the
   advancement gate is met is now resumable rather than lost.

The advancement gate is unchanged. No brief ships until at least three rounds have
run and all six coverage dimensions are filled. Signal keeps its refusal to hand
off on a vague request; it stops throwing away partial work.

## What is deliberately not adopted

The source method extracts one expert's judgment across many sittings and often
many people. Signal interrogates one requester about one request. These parts of
the source do not transfer and are out of scope:

- `target.md` — the produced-artifact declaration and the judgment-bearing switch
- `claims.md` — extracted claims with Settled / Attributed / Contested status
- Per-person transcript files
- `baselines.md` — the map of which conventional priors held
- Multi-person interviewing: attribution by name, prior claims as unverified
  hypotheses, mining disagreements toward a discriminator

Adopting them would turn signal into an interview platform that happens to emit a
brief. That is a different product.

## Approach

One new working file, `open-threads.md`, written by stage 1 in the main thread.

Two alternatives were considered and rejected:

- **Two files** (`coverage.md` for established answers, `open-threads.md` kept pure
  to the source spec). Rejected: the two are read together, written together, and
  by the same writer in the same breath. Splitting them produces one file with a
  seam, plus a second thing to keep in sync.
- **An early partial `brief.md`** with unfilled dimensions marked empty. Rejected:
  the conductor's resume logic depends on the presence of `brief.md` meaning "the
  advancement gate was met," and the conductor may not open the file to learn
  otherwise. This would make presence ambiguous — precisely the ambiguity the
  current design spends a user-facing question to avoid.

## Architecture

### Run directory

```
.signal/runs/<YYYY-MM-DD>-<slug>/
  00-request.md       the raw request, verbatim (conductor)
  open-threads.md     working state (stage 1, main thread)          [NEW]
  brief.md            THE deliverable — §1–§6 stage 1, §7–§8 stage 2
```

`brief.md` remains the deliverable. `open-threads.md` is working state and is never
confused with it.

### The Iron Rule is clarified, not amended

The conductor's Iron Rule prohibits reading artifacts **a dispatched subagent
authored**. `open-threads.md` is written by stage 1 in the main thread — the
conductor's own hand, exactly like `00-request.md`. It is therefore readable.

The design states this explicitly rather than leaving it to be derived. A future
reader deriving it wrongly in either direction causes a real defect: forbidding the
read breaks warm resume, and permitting reads of subagent artifacts breaks the
architecture.

Stage 2 (`sequencing-requirements`, a dispatched subagent) may **read**
`open-threads.md`. The rule governs what the conductor reads back from subagents,
not what subagents read from main-thread files. Stage 2 never writes it.

## Component: `interrogating-requirements`

The heaviest change. This skill owns the question form, the probe families,
continuous capture, the returning-session opening, and the honest gap list.

### Question form

Replace open questioning with hypothesis-and-correction. Offer the conventional
answer, with the reasoning visible, and invite correction.

> "You want SSO. I'm assuming, like most teams this size, that's to kill the
> password-reset support load rather than a compliance requirement. Is that the
> driver, or is something else?"

Rules governing the baseline:

- **Set it at the field default, never tuned to what the user already said.** A
  tuned baseline that draws agreement tells you only that you were listening. A
  field-default baseline that draws agreement tells you the ground is standard and
  needs no further probing — fill it in cheaply and move on.
- **Keep it inline and local.** One baseline per probe. Never a lecture up front.
- **When signal does not know the convention for a domain, say so inside the
  probe** rather than inventing a baseline.

  > "I don't have a strong sense of what's typical here, so correct me freely: I'd
  > guess most teams in your position would..."

  A wrong baseline makes ordinary practice look like a departure and lets a real
  departure pass as unremarkable. It corrupts the depth map in both directions.
- **Mine the reason, not just the correction.** When someone corrects a baseline,
  get why they hold their position.
- **When agreement arrives fast on something that should have been hard, ask what
  would make it wrong.** A plausible hypothesis waved through encodes a guess as a
  requirement.

### Probe families

Four, run in this relationship to each other:

1. **Omissions.** Never ask about an absence directly. "Did you leave that out on
   purpose?" invites the user to construct a principled reason for an accidental
   gap. Probe the absence as a hypothesis:

   > "I'd expect anyone shipping this to also want X. My guess is you're not, and
   > my guess at why is Y."

   Deliberate and accidental omissions react visibly differently to that.

2. **Surface, then depth.** A broad pass first, planting conventional priors
   cheaply across all six coverage dimensions. Then allocate depth wherever those
   priors broke. Corrections are the depth map. Signal does not decide in advance
   which dimension sounds hard.

3. **Systems.** Gated on §6 Existing Context. Runs once §6 is filled **and** shows a
   system that has actually been operated — there is lived consequence to mine.
   Greenfield with no prior art skips it, and §6 records that it was skipped and
   why.

   - **Backward:** what did you stop doing, and how long did it take to work out
     why? Find the effect, walk back to the cause that was invisible at the time.
   - **Forward:** where do you make a call and never find out whether it was right?
     Missing feedback loops mark where a downstream builder will be most
     confidently wrong, because no correction signal exists anywhere in the world
     to have taught anyone better.

4. **Stated process versus real behavior.** People describe the process they
   believe they follow; it is tidier than the one they run. When an account of the
   current workaround sounds cleaner than the behavior probably was, push once on
   the specific discrepancy. If they hold, drop it and move on. Once, not twice.

### Rules that survive unchanged

Named explicitly because the rewrite could plausibly eat them:

- One question per turn. Never batch.
- Reject non-answers. "Whatever makes sense" / "the usual" / "you decide" are not
  answers.
- Force the written non-goals list.
- The advancement gate: 3+ rounds AND all six dimensions filled. Both.
- The escape valve for genuinely trivial requests.
- The confirm-or-correct checklist under hard pushback.
- Write `brief.md` §1–§6 the moment the gate is met, before any dispatch.

### Continuous capture

`open-threads.md` is written **during** the interrogation, never in a synthesis pass
at the end. A session that dies mid-round has already banked what it learned. This
is the same argument signal already makes for writing `brief.md` the moment the gate
is met, applied one level earlier.

**Anything noticed and not pulled goes in before the session ends.** This is an
obligation, not a nicety. It is the single rule that makes a short session compound
instead of accumulate.

File shape:

```markdown
# Open Threads — <slug>
Working state for this run. Not the deliverable; `brief.md` is.

## Coverage So Far
| Dimension | Status | Established |
|---|---|---|
| 1. Problem | filled | Support load from password resets, ~40/wk, felt by the 2-person helpdesk |
| 2. Users & Stakeholders | thin | Admins named; nobody named as sign-off yet |
| 3. Success Criteria | empty | — |
| 4. Constraints | empty | — |
| 5. Scope | empty | — |
| 6. Existing Context | empty | — |

## Open Threads
- [ ] **reset-volume-baseline** — 40/wk was offered with low confidence and never checked
      *Opened:* 2026-08-18 · *Kind:* unchecked-baseline
- [ ] **sso-vs-magic-link** — corrected my SSO baseline, didn't say why magic links were ruled out
      *Opened:* 2026-08-18 · *Kind:* corrected-not-dug
```

`Status` is one of `filled`, `thin`, `empty`. `Established` holds what the user
actually said, in their own words where possible.

**Only `filled` satisfies the advancement gate.** `thin` exists to record that a
dimension has an answer which is not yet concrete enough to write into `brief.md` —
it is a gap the next round must close, not a weaker form of coverage. A run whose
coverage table still shows a `thin` or `empty` row has not met the gate.

Four thread kinds, taken from the source:

| Kind | Means |
|---|---|
| `corrected-not-dug` | A baseline was corrected but the reason was never mined |
| `unresolved-conflict` | Two requirements collide with no condition that resolves them |
| `next-probe` | The obviously-next probe when time ran out |
| `unchecked-baseline` | A figure or assumption offered with low confidence, never checked |

Closing a thread means checking it off and moving what it produced into the
coverage table. Nothing is deleted. The record of what was dangling is what makes
the next session cheap.

### Returning-session opening

A returning session opens by offering a choice, never by making one:

> "Do you want to start from your own spot, or pick up one of the open threads from
> last time?"

Threads are listed underneath, short, so the user sees what is dangling even if
they go elsewhere. Signal does not silently resume where it stopped, and does not
re-ask any dimension the coverage table already records as filled.

### "Do you have enough yet?"

Answered with a **list of what still has to be tackled**, generated fresh against
the six coverage dimensions as they stand. Never a verdict. Never a readiness score
or percentage.

Thin parts are named as thin. The failure mode is agreeableness: the user asks,
signal says yes, and a confident brief ships with a hole where a contested
requirement should have been.

### Expansion beat: three dispositions

Every candidate returned by `expanding-scope` resolves to **IN-SCOPE**, **NON-GOAL**,
or **DEFER**.

- IN-SCOPE and NON-GOAL behave exactly as they do today.
- DEFER writes the candidate to `open-threads.md` as kind `next-probe`, **and** names
  it in §5 as deferred with a pointer to `open-threads.md`.

The "nothing reaches the brief undisposed" rule survives intact — a deferred
candidate leaves two traces, not zero. What changes is that a user who genuinely
does not know is no longer forced to fabricate a rejection reason.

## Component: `conducting-discovery`

### Iron Rule

One sentence added, per **Architecture** above. Nothing existing is amended.

### Resume table

| On disk | Behavior |
|---|---|
| `00-request.md` only | Stage 1 cold, as today. The session was abandoned before anything was learned. |
| **`open-threads.md`, no `brief.md`** | **New.** The gate was never met, but the work survived. Stage 1 **warm**: open by offering the threads, honor the coverage table, never re-ask a filled dimension. |
| `brief.md` exists | Ask the user: re-run stage 2, or start over at stage 1? As today. "Start over at stage 1" is now warm — it reads the coverage table rather than starting from nothing. |
| Trivial exit recorded in `00-request.md` | As today. |

The conductor still **asks** rather than inspecting `brief.md` to determine which
stage a resumed run is at. That is untouched. It has only gained a file it may
legitimately read.

### Release

Reports both paths: `brief.md`, and `open-threads.md` if any thread is still open,
with a count of open threads.

Everything else about release is unchanged. Signal does not read the brief, does not
summarize it, and does not offer to build.

### Line-count check

Unaffected. `open-threads.md` is a separate file. The `sections_1_6_lines` tripwire
on `brief.md` is unchanged in every respect.

## Component: `sequencing-requirements`

Two changes, both small:

- A §7 component's **Open risks** field may cite an open thread by its handle.
- **§8 names `open-threads.md`** so a downstream reader knows the brief has a live
  companion listing what was never resolved.

§8 remains a pointer, not a plan. Naming an unresolved thread is not a
recommendation about what to do next, and the existing prohibition on §8 making any
claim about what happens next stands.

Stage 2 reads `open-threads.md` and never writes it.

## Component: `expanding-scope`

One line: dispositions are three, not two. The skill proposes and never decides;
that is unchanged. It still writes no file, still caps at five candidates, and still
returns candidates in its RETURN block's `actionable` field.

## Component: `README.md` and `commands/signal.md`

Updated to match: the mermaid flow, the stages table, the run-artifacts listing, and
the "here is what to expect, honestly" prose. The README's claim that an abandoned
pre-gate run leaves nothing but `00-request.md` becomes false under this design and
must be corrected.

## Risks

**A confidently-wrong baseline is a new failure mode.** Hypothesis-first questioning
can encode a requirement nobody actually stated, if the user waves a plausible
baseline through. That is worse than a blank section, because it ships with
confidence.

The mitigations are in the design — field-default baselines, saying "I don't know
what's typical here" inside the probe, mining the reason behind every correction,
and one push on fast agreement over something that should have been hard — but all
of them are behavioral. There is no mechanical check that catches an encoded guess,
in the way the `sections_1_6_lines` tripwire catches a crossed two-writer boundary.
This is accepted, and named here so it is not mistaken for free upside.

**`open-threads.md` can rot.** A thread opened and never closed across many sessions
is noise that makes the returning-session menu useless. No automatic expiry is
specified; closing threads is an obligation on the interrogation, enforced the same
way its other obligations are.
