# Signal Interview Method Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Teach signal to interrogate by offering conventional baselines and mining the corrections, and to survive a session that ends before the advancement gate is met.

**Architecture:** Two changes to a four-skill prose plugin. First, `interrogating-requirements` swaps open questioning for hypothesis-and-correction and gains four probe families. Second, a new working file `open-threads.md` — written by stage 1 in the main thread, alongside the existing `brief.md` — carries coverage state and loose ends between sessions, making a pre-gate session resumable. The conductor gains a warm-resume row and one clarifying sentence on the Iron Rule; `sequencing-requirements` gains a read of the new file; `expanding-scope` gains one line.

**Tech Stack:** Markdown only. No code, no tests, no hooks — signal is four `SKILL.md` files, one command file, a README, and two JSON manifests. Verification is fixed-string assertion via `grep -F` plus a human read-through.

**Spec:** [docs/superpowers/specs/2026-08-18-signal-interview-method-design.md](../specs/2026-08-18-signal-interview-method-design.md)

## Global Constraints

- **Run every command from the repository root.** Paths below are repo-relative.
- **The advancement gate does not change.** 3+ rounds AND all six coverage dimensions filled. No task weakens it.
- **`brief.md` remains THE deliverable.** `open-threads.md` is working state and is never called the deliverable, never contains brief content, and never replaces it.
- **The Iron Rule is clarified, never amended.** The conductor may not read artifacts a dispatched subagent authored. `open-threads.md` is written by stage 1 in the main thread, so it is readable — the same standing `00-request.md` already has.
- **Signal ships no code.** Do not add a test harness, a script, or a hook. The README's claim "No hooks and no code — four skills and one command, all prose" must stay true.
- **Section markers are the literal `§` character** throughout, e.g. `§1–§6`. The dash in `§1–§6` is an en dash (U+2013), matching existing files.
- **Not in scope, from the spec's own exclusion list:** `target.md`, `claims.md`, per-person transcripts, `baselines.md`, multi-person attribution, discriminators. Do not add them.
- **Every task ends with a commit** using a Conventional Commits prefix scoped `signal`.

## File Structure

| File | Responsibility | Tasks |
|---|---|---|
| `signal/skills/interrogating-requirements/SKILL.md` | Question form, probe families, capture contract, returning sessions, gap list, DEFER | 1, 2, 3, 4, 5 |
| `signal/skills/expanding-scope/SKILL.md` | One line: dispositions are three | 5 |
| `signal/skills/conducting-discovery/SKILL.md` | Iron Rule sentence, run directory, resume table, release, red flags; stage-2 dispatch gains a second path | 6, 7 |
| `signal/skills/sequencing-requirements/SKILL.md` | Reads `open-threads.md`; §7 open risks cite handles; §8 names the file | 7 |
| `signal/README.md` | Expectations prose, mermaid, stages table, run artifacts | 8 |
| `signal/commands/signal.md` | Pipeline summary shown at invocation | 8 |
| `signal/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` | Version bump 0.1.0 → 0.2.0 | 8 |

Tasks 1–5 all edit one file and must run in order — each appends or replaces a distinct section, and later tasks reference headings earlier tasks create. Tasks 6 and 7 both edit the conductor and must run in that order. Task 8 is last because it describes the finished behavior of all of them.

---

### Task 1: The `open-threads.md` contract

Defines the file every later task refers to. Nothing else works until this heading exists.

**Files:**
- Modify: `signal/skills/interrogating-requirements/SKILL.md` (frontmatter `description`; `## The Advancement Gate`; new section after `## The Advancement Gate`)

**Interfaces:**
- Produces: the heading `## Capturing As You Go — \`open-threads.md\``; the status vocabulary `filled` / `thin` / `empty`; the four thread kinds `corrected-not-dug`, `unresolved-conflict`, `next-probe`, `unchecked-baseline`; the table heading `## Coverage So Far` and the list heading `## Open Threads` inside the generated file.
- Consumes: nothing.

- [ ] **Step 1: Write the assertions**

Save as a shell function you re-run — do not commit it, it is a scratch check:

```bash
check1() {
  F=signal/skills/interrogating-requirements/SKILL.md
  grep -Fq '## Capturing As You Go' "$F" && echo "PASS heading" || echo "FAIL heading"
  grep -Fq 'unchecked-baseline' "$F" && echo "PASS kinds" || echo "FAIL kinds"
  grep -Fq 'Only `filled` satisfies the gate' "$F" && echo "PASS thin-rule" || echo "FAIL thin-rule"
  grep -Fq 'open-threads.md' signal/skills/interrogating-requirements/SKILL.md && echo "PASS ref" || echo "FAIL ref"
}
check1
```

- [ ] **Step 2: Run it to verify it fails**

Run: `check1`
Expected: four `FAIL` lines.

- [ ] **Step 3: Add the gate clarification**

In `## The Advancement Gate`, find this exact line:

```markdown
Count alone is not enough. Coverage alone is not enough. **Both.**
```

Insert immediately after it:

```markdown
**Only `filled` satisfies the gate.** You track each dimension in the coverage table
in `open-threads.md` (see `## Capturing As You Go` below) as `filled`, `thin` or
`empty`. `thin` means a dimension has an answer that is not yet concrete enough to
write into `brief.md` — a gap the next round must close, not a weaker form of
coverage. A coverage table still showing a `thin` or `empty` row means the gate is
not met.
```

- [ ] **Step 4: Add the capture section**

Insert this complete new section immediately before the existing `## How to Interrogate` heading:

````markdown
## Capturing As You Go — `open-threads.md`

You write a second file into the run directory: `open-threads.md`. It is **working
state, not the deliverable.** `brief.md` is the deliverable, and nothing about that
changes.

**Write it during the interrogation, never in a synthesis pass at the end.** A
session that ends mid-round has already banked what it learned. This is the same
argument that makes you write `brief.md` §1–§6 the moment the gate is met, applied
one level earlier: until it is on disk it lives in a conversation that a crash, a
closed terminal, or a user walking away takes with it.

Update it whenever a dimension moves, a baseline gets corrected, or you notice
something you are not going to chase this session.

### Shape

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
- [ ] **sso-vs-magic-link** — corrected my SSO baseline, never said why magic links were ruled out
      *Opened:* 2026-08-18 · *Kind:* corrected-not-dug
```

`Status` is one of `filled`, `thin`, `empty`. `Established` holds what the user
actually said, in their own words wherever you have them.

### The four thread kinds

| Kind | Means |
|---|---|
| `corrected-not-dug` | A baseline was corrected but the reason behind the correction was never mined |
| `unresolved-conflict` | Two requirements collide and no condition has been found that resolves them |
| `next-probe` | The obviously-next probe when the session ran out of time |
| `unchecked-baseline` | A figure or assumption offered with low confidence and never checked |

### Obligations

- **Anything noticed and not pulled goes in before the session ends.** This is not a
  nicety. It is the single rule that makes a ten-minute session compound instead of
  accumulate.
- **Close a thread by checking it off and moving what it produced into the coverage
  table.** Never delete it. The record of what was dangling is what makes the next
  session cheap.
- **Never write `brief.md` content here, and never write threads into `brief.md`.**
  Two files, two jobs. §5 may point at a deferred expansion candidate's thread
  handle; that pointer is the only crossing.
````

- [ ] **Step 5: Update the frontmatter description**

Replace this exact fragment inside the `description:` line:

```
then runs a scope-expansion beat and writes sections 1 to 6 of brief.md once, complete.
```

with:

```
then runs a scope-expansion beat and writes sections 1 to 6 of brief.md once, complete. It probes by offering conventional baselines and mining the corrections, and records coverage state and loose ends continuously in open-threads.md so a session that ends early is resumable.
```

- [ ] **Step 6: Run the assertions to verify they pass**

Run: `check1`
Expected: four `PASS` lines.

- [ ] **Step 7: Read the section back**

Read `signal/skills/interrogating-requirements/SKILL.md` from `## The Advancement Gate` through the end of `## Capturing As You Go`. Confirm: the fenced block inside the new section uses four backticks on the outer fence so the inner three-backtick markdown block renders; `brief.md` is still called the deliverable; no thread kind is invented beyond the four.

- [ ] **Step 8: Commit**

```bash
git add signal/skills/interrogating-requirements/SKILL.md
git commit -m "feat(signal): open-threads.md carries coverage state between sessions"
```

---

### Task 2: Hypothesis-and-correction question form

**Files:**
- Modify: `signal/skills/interrogating-requirements/SKILL.md` (replace `## How to Interrogate` in full)

**Interfaces:**
- Consumes: nothing from Task 1 structurally, but must land after it so the capture section sits above this one.
- Produces: the heading `## How to Interrogate — Hypothesis, Then Correction`, and the subheading `### Rules that do not change` which Task 3 refers to by name.

- [ ] **Step 1: Write the assertions**

```bash
check2() {
  F=signal/skills/interrogating-requirements/SKILL.md
  grep -Fq '## How to Interrogate — Hypothesis, Then Correction' "$F" && echo "PASS heading" || echo "FAIL heading"
  grep -Fq 'Do not ask open questions' "$F" && echo "PASS mode" || echo "FAIL mode"
  grep -Fq 'Set it at the field default' "$F" && echo "PASS baseline" || echo "FAIL baseline"
  grep -Fq 'One question per turn' "$F" && echo "PASS survives" || echo "FAIL survives"
  grep -Fq 'Force the non-goals' "$F" && echo "PASS non-goals" || echo "FAIL non-goals"
}
check2
```

- [ ] **Step 2: Run it to verify it fails**

Run: `check2`
Expected: `FAIL heading`, `FAIL mode`, `FAIL baseline`, `FAIL survives`. `PASS non-goals` is expected here — that line already exists and must survive the replacement, which is exactly why it is asserted.

- [ ] **Step 3: Replace the section**

Delete the entire existing `## How to Interrogate` section — the heading and all six bullets, ending at the blank line before `## Escape Valve` — and put this in its place:

```markdown
## How to Interrogate — Hypothesis, Then Correction

**Do not ask open questions. Offer a hypothesis and invite correction.**

The hypothesis is the **conventional answer**: what most competent practitioners in
this domain would do, stated plainly, with the reasoning visible.

> "You want SSO. I'm assuming, like most teams this size, that's to kill the
> password-reset support load rather than a compliance requirement. Is that the
> driver, or is something else?"

- **They agree** — the ground is standard here. Fill it in and move on. Cheap.
- **They correct you** — this is a departure. Dig.

Departures are where the requirements actually live. Everything else you could have
guessed, and guessing it is fine — which is precisely what their agreement licenses
you to do.

### Rules for the baseline

- **Set it at the field default. Never tune it to what the user already told you.**
  A tuned baseline that draws agreement tells you only that you were listening. A
  field-default baseline that draws agreement tells you something about the world.
- **Keep it inline and local.** One baseline per probe, never a lecture up front.
- **When you do not know what is conventional in this domain, say so inside the
  probe** rather than inventing a baseline.

  > "I don't have a strong sense of what's typical here, so correct me freely: I'd
  > guess most teams in your position would..."

  A wrong baseline makes ordinary practice look like a departure and lets a real
  departure pass as unremarkable. It corrupts the depth map in both directions, and
  you will not notice either failure from the inside.
- **When someone corrects you, get the reason, not just the correction.** The
  correction tells you what. Only the reason tells you what else it implies.
- **When agreement arrives fast on something that should have been hard, ask what
  would make it wrong.** A plausible hypothesis waved through encodes your guess as
  a requirement — worse than an empty section, because it ships with confidence.

### Rules that do not change

- **One question per turn.** Never batch, never offer "a few things I'm wondering
  about". Given ten questions a person answers one. Ten at once produces summaries;
  one at a time produces stories.
- **Quote the vague phrase back.** "You said 'it should be fast' — fast meaning
  what? p95 latency under what, on what payload?"
- **Reject non-answers.** "Whatever makes sense" / "the usual" / "you decide" are
  not answers.
- **Force the non-goals.** People define scope by what they will build; make them
  state what they will not build.
```

Two bullets from the old section are deliberately gone, not lost: "surface hidden assumptions — ask the question whose answer you're tempted to assume" becomes the omissions probe in Task 3, and "prefer concrete choices over open-ended prompts" is subsumed by the hypothesis form, which is a concrete choice by construction.

- [ ] **Step 4: Run the assertions to verify they pass**

Run: `check2`
Expected: five `PASS` lines.

- [ ] **Step 5: Confirm nothing else moved**

Run: `git diff --stat signal/skills/interrogating-requirements/SKILL.md`
Expected: one file changed. Then run `git diff signal/skills/interrogating-requirements/SKILL.md` and confirm every removed line belongs to the old `## How to Interrogate` section and nothing else.

- [ ] **Step 6: Commit**

```bash
git add signal/skills/interrogating-requirements/SKILL.md
git commit -m "feat(signal): interrogate by offering a baseline and mining the correction"
```

---

### Task 3: The four probe families

**Files:**
- Modify: `signal/skills/interrogating-requirements/SKILL.md` (new section after `## How to Interrogate — Hypothesis, Then Correction`)

**Interfaces:**
- Consumes: the heading `## How to Interrogate — Hypothesis, Then Correction` from Task 2.
- Produces: the heading `## The Probe Families` and the §6 gate wording that Task 8's README summary restates.

- [ ] **Step 1: Write the assertions**

```bash
check3() {
  F=signal/skills/interrogating-requirements/SKILL.md
  grep -Fq '## The Probe Families' "$F" && echo "PASS heading" || echo "FAIL heading"
  grep -Fq 'Never ask about an absence directly' "$F" && echo "PASS omissions" || echo "FAIL omissions"
  grep -Fq 'Corrections are your depth map' "$F" && echo "PASS depth" || echo "FAIL depth"
  grep -Fq 'gated on §6' "$F" && echo "PASS systems-gate" || echo "FAIL systems-gate"
  grep -Fq 'push once' "$F" && echo "PASS stated-vs-real" || echo "FAIL stated-vs-real"
}
check3
```

- [ ] **Step 2: Run it to verify it fails**

Run: `check3`
Expected: five `FAIL` lines.

- [ ] **Step 3: Insert the section**

Insert immediately after the last line of `### Rules that do not change` and before the `## Escape Valve` heading:

```markdown
## The Probe Families

Four of them. This is not a running order — 1 and 2 shape the whole interrogation;
3 and 4 fire when their trigger appears.

### 1. Omissions

Find what the user holds as central, then find what is conspicuously missing.

**Never ask about an absence directly.** "Did you leave that out on purpose?" invites
them to construct a principled reason for an accidental gap, and you will never
learn which of the two it was. Probe the absence as a hypothesis instead:

> "I'd expect anyone shipping this to also want audit logging on it. My guess is
> you're not, and my guess at why is that nobody has asked you for it yet."

Deliberate and accidental omissions react visibly differently to that.

### 2. Surface, Then Depth

**Broad pass first**, planting conventional baselines cheaply across all six
coverage dimensions. **Then allocate depth wherever those baselines broke.**

Do not decide in advance which dimension sounds hard. Corrections are your depth
map, and a dimension nobody corrected does not need another round.

### 3. Systems — gated on §6

**Run this only once §6 Existing Context is filled and shows a system that has
actually been operated.** Greenfield with nothing running has no lived consequence
to mine; skip it, and record in §6 that it was skipped and why.

Delayed-consequence knowledge has no written trace anywhere. A proposal, a thread, a
post — those exist. "We structured it this way, it looked fine for two quarters,
then it killed our margin" never gets written down, because by the time the
consequence landed nobody connected it back to the decision. It survives only in
someone who lived it.

Probe both directions:

- **Backward.** What did you stop doing, and how long did it take to work out why?
  Find the effect, then walk back to the cause that was invisible at the time.
- **Forward.** Where do you make a call and never find out whether it was right?
  Missing feedback loops mark exactly where a downstream builder will be most
  confidently wrong, because no correction signal exists anywhere in the world to
  have taught anyone better.

Anything this surfaces and you do not chase becomes a thread — usually
`corrected-not-dug` or `next-probe`.

### 4. Stated Process Versus Real Behavior

People describe the process they believe they follow. It is tidier and more
principled than the one they actually run.

When an account of the current workaround sounds cleaner than the behavior probably
was, **push once** on the specific discrepancy. If they hold, drop it and move on.
Once, not twice — a second push buys nothing and costs the room.
```

- [ ] **Step 4: Run the assertions to verify they pass**

Run: `check3`
Expected: five `PASS` lines.

- [ ] **Step 5: Verify the §6 gate is stated exactly once**

Run: `grep -Fc 'gated on §6' signal/skills/interrogating-requirements/SKILL.md`
Expected: `1`. If higher, an earlier task duplicated it — remove the duplicate.

- [ ] **Step 6: Commit**

```bash
git add signal/skills/interrogating-requirements/SKILL.md
git commit -m "feat(signal): four probe families, systems probe gated on existing context"
```

---

### Task 4: Returning sessions and the honest gap list

**Files:**
- Modify: `signal/skills/interrogating-requirements/SKILL.md` (two new sections after `## The Probe Families`)

**Interfaces:**
- Consumes: `filled` / `thin` / `empty` from Task 1; `## The Probe Families` from Task 3.
- Produces: the headings `## Returning Sessions` and `## When They Ask Whether You Have Enough`, both named in Task 6's conductor resume table and Task 8's README.

- [ ] **Step 1: Write the assertions**

```bash
check4() {
  F=signal/skills/interrogating-requirements/SKILL.md
  grep -Fq '## Returning Sessions' "$F" && echo "PASS returning" || echo "FAIL returning"
  grep -Fq 'offering a choice, never by making one' "$F" && echo "PASS choice" || echo "FAIL choice"
  grep -Fq '## When They Ask Whether You Have Enough' "$F" && echo "PASS enough" || echo "FAIL enough"
  grep -Fq 'Not a readiness score' "$F" && echo "PASS no-score" || echo "FAIL no-score"
  grep -Fq 'failure mode here is agreeableness' "$F" && echo "PASS agreeableness" || echo "FAIL agreeableness"
}
check4
```

- [ ] **Step 2: Run it to verify it fails**

Run: `check4`
Expected: five `FAIL` lines.

- [ ] **Step 3: Insert both sections**

Insert immediately after the last line of `### 4. Stated Process Versus Real Behavior` and before the `## Escape Valve` heading:

```markdown
## Returning Sessions

A returning session opens by **offering a choice, never by making one**:

> "Do you want to start from your own spot, or pick up one of the open threads from
> last time?"

List the open threads underneath, short. They see what is dangling even if they go
somewhere else entirely.

- **Do not silently resume where you stopped.** The user's own spot is a legitimate
  answer and is frequently the better one.
- **Do not re-ask a dimension the coverage table records as `filled`.** Re-asking
  what is already banked is the exact thing continuity exists to prevent, and it
  reads as not having listened.
- **Do re-open a `thin` dimension.** Thin is a gap, not coverage.

## When They Ask Whether You Have Enough

They will ask some version of "do you have enough to write the brief?"

**Answer with a list of what still has to be tackled**, generated fresh against the
six coverage dimensions as they stand right now. Not a verdict. Not a readiness
score, not a percentage, not "we're about 80% there".

Say the thin parts are thin. Name which dimensions are still `empty`, which are
`thin` and what specifically is missing from each, and which open threads are
load-bearing on the answer.

**The failure mode here is agreeableness.** They ask, you say yes, and a confident
brief ships with a hole where a contested requirement should have been. The gate is
the gate; being asked nicely does not move it.
```

- [ ] **Step 4: Run the assertions to verify they pass**

Run: `check4`
Expected: five `PASS` lines.

- [ ] **Step 5: Confirm the gate was not weakened**

Run: `grep -Fq 'At least 3 rounds' signal/skills/interrogating-requirements/SKILL.md && echo PASS || echo FAIL`
Expected: `PASS`.

- [ ] **Step 6: Commit**

```bash
git add signal/skills/interrogating-requirements/SKILL.md
git commit -m "feat(signal): returning sessions offer threads, readiness answered as a gap list"
```

---

### Task 5: DEFER, the third disposition

**Files:**
- Modify: `signal/skills/interrogating-requirements/SKILL.md` (`## The Expansion Beat` steps 4 and 5; `## Output` §5 row and note; `## Red Flags`)
- Modify: `signal/skills/expanding-scope/SKILL.md` (`## Overview`)

**Interfaces:**
- Consumes: thread kind `next-probe` from Task 1.
- Produces: the §5 sub-list name `Deferred`, which Task 7's `sequencing-requirements` §7 open-risks guidance refers to.

- [ ] **Step 1: Write the assertions**

```bash
check5() {
  F=signal/skills/interrogating-requirements/SKILL.md
  G=signal/skills/expanding-scope/SKILL.md
  grep -Fq 'IN-SCOPE, NON-GOAL, or DEFER' "$F" && echo "PASS three" || echo "FAIL three"
  grep -Fq 'Two traces, not zero' "$F" && echo "PASS traces" || echo "FAIL traces"
  grep -Fq 'deferred' "$F" && echo "PASS output" || echo "FAIL output"
  grep -Fq 'Dispositions are three' "$G" && echo "PASS expanding" || echo "FAIL expanding"
}
check5
```

- [ ] **Step 2: Run it to verify it fails**

Run: `check5`
Expected: four `FAIL` lines.

- [ ] **Step 3: Replace expansion beat step 4**

Find this exact line in `## The Expansion Beat`:

```markdown
4. **Every candidate must resolve to IN-SCOPE or NON-GOAL, with the user's reason.** An unresolved candidate never reaches the brief.
```

Replace with:

```markdown
4. **Every candidate must resolve to IN-SCOPE, NON-GOAL, or DEFER, with the user's reason.** An unresolved candidate never reaches the brief. DEFER is for a candidate the user genuinely cannot decide on yet: it is written to `open-threads.md` as kind `next-probe` **and** named in §5's deferred list. Two traces, not zero. DEFER is not a way to dodge adjudicating — it is itself a disposition, and a candidate the user simply does not want is a NON-GOAL with a reason, exactly as before.
```

- [ ] **Step 4: Extend expansion beat step 5**

Find this exact sentence inside step 5:

```markdown
Rejected candidates go into §5's non-goals list *with the user's reason*, so the brief records what was considered and declined, not only what survived.
```

Insert immediately after it, in the same paragraph:

```markdown
Deferred candidates go into §5's deferred list with their thread handle from `open-threads.md`, so a reader can tell what is genuinely still open from what was settled.
```

- [ ] **Step 5: Update the §5 output row**

Find this exact table row in `## Output — \`brief.md\` §1–§6`:

```markdown
| 5 | **Scope** — what's in; and **non-goals**, each with the user's reason |
```

Replace with:

```markdown
| 5 | **Scope** — what's in; **non-goals**, each with the user's reason; and **deferred**, each with its `open-threads.md` thread handle |
```

- [ ] **Step 6: Update the §5 note**

Find this exact sentence in the §5 note:

```markdown
**Note for §5, and it is not optional:** **every** accepted expansion candidate appears in the in-scope list, and **every** rejected one appears in the non-goals list with the user's stated reason.
```

Replace with:

```markdown
**Note for §5, and it is not optional:** **every** accepted expansion candidate appears in the in-scope list, **every** rejected one appears in the non-goals list with the user's stated reason, and **every** deferred one appears in the deferred list with its thread handle.
```

- [ ] **Step 7: Update the red flag**

Find this exact red-flag line:

```markdown
- Writing `brief.md` with a candidate that appears in neither §5's in-scope list nor its non-goals list
```

Replace with:

```markdown
- Writing `brief.md` with a candidate that appears in none of §5's three lists — in-scope, non-goals, deferred
- Recording a candidate as deferred in §5 without opening the matching `next-probe` thread in `open-threads.md`. Deferred means two traces; one is a dropped requirement wearing a disposition.
```

- [ ] **Step 8: Add the line to `expanding-scope`**

In `signal/skills/expanding-scope/SKILL.md`, find this exact sentence in `## Overview`:

```markdown
Your only job is to surface what the requester never thought to say.
```

Insert immediately before it, as its own paragraph:

```markdown
**Dispositions are three — IN-SCOPE, NON-GOAL, DEFER — and none of them are yours.** You propose; stage 1 records what the user decides. Do not shape a candidate to make one disposition likelier.
```

- [ ] **Step 9: Run the assertions to verify they pass**

Run: `check5`
Expected: four `PASS` lines.

- [ ] **Step 10: Confirm the binary is gone**

Run: `grep -Fc 'IN-SCOPE or NON-GOAL' signal/skills/interrogating-requirements/SKILL.md`
Expected: `0`. Any remaining hit is a stale statement of the two-disposition rule — update it to the three.

- [ ] **Step 11: Commit**

```bash
git add signal/skills/interrogating-requirements/SKILL.md signal/skills/expanding-scope/SKILL.md
git commit -m "feat(signal): DEFER as a third expansion disposition, traced in two places"
```

---

### Task 6: Conductor — Iron Rule, run directory, resume, release

**Files:**
- Modify: `signal/skills/conducting-discovery/SKILL.md` (`## The Iron Rule` item 1; `## Run Directory` resume table and layout; pipeline `dot` graph label; `## Release`; `## Error Handling`; `## Red Flags`)

**Interfaces:**
- Consumes: `## Returning Sessions` from Task 4; `open-threads.md` from Task 1.
- Produces: the run-directory layout listing `open-threads.md`. Task 8's README block describes the same three files; the two blocks are not byte-identical — the README's carries extra explanatory comment lines — and must not be forced to match.

- [ ] **Step 1: Write the assertions**

```bash
check6() {
  F=signal/skills/conducting-discovery/SKILL.md
  grep -Fq 'open-threads.md' "$F" && echo "PASS ref" || echo "FAIL ref"
  grep -Fq 'written in the main thread are yours to read' "$F" && echo "PASS ironrule" || echo "FAIL ironrule"
  grep -Fq 'Stage 1, **warm**' "$F" && echo "PASS warm" || echo "FAIL warm"
  grep -Fq 'has any unchecked thread' "$F" && echo "PASS release" || echo "FAIL release"
}
check6
```

- [ ] **Step 2: Run it to verify it fails**

Run: `check6`
Expected: four `FAIL` lines.

- [ ] **Step 3: Clarify the Iron Rule**

Find this exact sentence in `## The Iron Rule` item 1:

```markdown
You route paths and act on RETURN blocks.
```

Insert immediately after it:

```markdown
Files **written in the main thread are yours to read** — `00-request.md`, and `open-threads.md`, which stage 1 writes in your own session. That is not an exception carved into this rule; it is what the rule has always said. The prohibition is on artifacts a *dispatched subagent* authored.
```

- [ ] **Step 4: Update the run directory layout**

Find this exact block in `## Run Directory`:

```
00-request.md            the raw request, verbatim (written by the conductor)
brief.md                 THE deliverable — §1–§6 by stage 1, §7–§8 by stage 2
```

Replace with:

```
00-request.md            the raw request, verbatim (written by the conductor)
open-threads.md          working state — coverage table and loose ends (stage 1, main thread)
brief.md                 THE deliverable — §1–§6 by stage 1, §7–§8 by stage 2
```

- [ ] **Step 5: Add the warm-resume row**

Find this exact row in the resume table:

```markdown
| No `brief.md` | Stage 1, from the top. The previous run did not get as far as meeting the advancement gate — stage 1 writes as soon as it does — so there was nothing to save and the questions start again. |
```

Replace with these two rows:

```markdown
| No `brief.md`, no `open-threads.md` | Stage 1, from the top. Nothing was learned before the run was abandoned, so the questions start again. |
| No `brief.md`, but `open-threads.md` exists | Stage 1, **warm**. The advancement gate was never met, but the work survived. Hand stage 1 the run directory as usual; its `## Returning Sessions` rules take over — it opens by offering the threads, honors the coverage table, and does not re-ask a dimension already recorded as `filled`. |
```

- [ ] **Step 6: Update the `brief.md exists` row**

Find this exact fragment in the third resume row:

```markdown
Starting over at stage 1 rewrites the file from line 1 and discards any §7–§8 a previous run left, because that body was ordered from requirements about to be replaced.
```

Insert immediately after it:

```markdown
Starting over is still warm: `open-threads.md` survives a stage 1 restart, so the coverage table and the open threads carry across rather than being re-earned.
```

- [ ] **Step 7: Update the pipeline graph label**

Find this exact line in the `dot` block:

```
    "brief.md on disk?" -> "Stage 1 · INTERROGATE (main thread)" [label="absent"];
```

Replace with:

```
    "brief.md on disk?" -> "Stage 1 · INTERROGATE (main thread)" [label="absent — warm if open-threads.md exists"];
```

- [ ] **Step 8: Update the release step**

Find this exact numbered item in `## Release`:

```markdown
2. Report the path to `brief.md`. The path, not its contents.
```

Replace with:

```markdown
2. Report the path to `brief.md`. The path, not its contents.
3. If `open-threads.md` has any unchecked thread, report its path too, with the count — "4 threads still open". You may read it to get that count; stage 1 wrote it in your own session. Do not summarise what the threads say; the count and the path are the handover.
```

Then renumber the two items that followed — the old items 3 and 4 become 4 and 5.

- [ ] **Step 9: Update the abandonment row in Error Handling**

Find this exact fragment in the `User abandons mid-run` row:

```markdown
Abandoned before the gate, only `00-request.md` survives and the questions start again.
```

Replace with:

```markdown
Abandoned before the gate, `open-threads.md` survives with whatever coverage and threads stage 1 had banked, so the next run resumes warm rather than cold. Only a run abandoned before the first answer leaves nothing but `00-request.md`.
```

- [ ] **Step 10: Add red flags**

Find this exact red-flag line:

```markdown
- Inferring a resumed run's stage from what is on disk instead of asking the user.
```

Insert immediately after it:

```markdown
- Treating `open-threads.md` as off-limits. Stage 1 wrote it in your session; it is a main-thread file like `00-request.md`, and refusing to read it breaks warm resume for no gain.
- Reading `open-threads.md` and then summarising the threads to the user at release. Report the path and the count.
- Telling the user a pre-gate run was lost when `open-threads.md` is on disk. It was not.
```

- [ ] **Step 10a: Update the conductor's two-disposition wording**

Task 5 made dispositions three; two statements of the old binary live in this file and must move with it.

Find this exact line in the `dot` block:

```
    "User adjudicates every candidate" -> "Rewrite brief.md §1–§6 — dispositions, or why there were none" [label="every candidate IN-SCOPE or NON-GOAL"];
```

Replace with:

```
    "User adjudicates every candidate" -> "Rewrite brief.md §1–§6 — dispositions, or why there were none" [label="every candidate IN-SCOPE, NON-GOAL or DEFER"];
```

Then find this exact red-flag line:

```markdown
- Advancing out of stage 1 with an unadjudicated expansion candidate, or writing §5 with a candidate missing from both the in-scope list and the non-goals list. Every candidate is IN-SCOPE or NON-GOAL, and every one leaves a trace in §5.
```

Replace with:

```markdown
- Advancing out of stage 1 with an unadjudicated expansion candidate, or writing §5 with a candidate missing from all three of its lists. Every candidate is IN-SCOPE, NON-GOAL or DEFER, and every one leaves a trace in §5 — a deferred one leaves a second trace in `open-threads.md`.
```

- [ ] **Step 11: Run the assertions to verify they pass**

Run: `check6`
Expected: four `PASS` lines.

Also run: `grep -Fc 'IN-SCOPE or NON-GOAL' signal/skills/conducting-discovery/SKILL.md`
Expected: `0`.

- [ ] **Step 12: Verify the release list renumbered cleanly**

Run: `sed -n '/^## Release/,/^## Error Handling/p' signal/skills/conducting-discovery/SKILL.md`
Expected: five numbered items, `1.` through `5.`, no repeats and no gaps.

- [ ] **Step 13: Commit**

```bash
git add signal/skills/conducting-discovery/SKILL.md
git commit -m "feat(signal): conductor resumes warm from open-threads.md and reports it at release"
```

---

### Task 7: Stage 2 reads the threads

**Files:**
- Modify: `signal/skills/sequencing-requirements/SKILL.md` (frontmatter `description`; `## Overview`; `## Section 7`; §8 note)
- Modify: `signal/skills/conducting-discovery/SKILL.md` (`### Stage 2 — Sequence (dispatched)` first paragraph)

**Interfaces:**
- Consumes: `open-threads.md` from Task 1; §5's deferred list from Task 5.
- Produces: the two-path stage 2 dispatch, which Task 8's README stages table describes.

- [ ] **Step 1: Write the assertions**

```bash
check7() {
  F=signal/skills/sequencing-requirements/SKILL.md
  G=signal/skills/conducting-discovery/SKILL.md
  grep -Fq 'open-threads.md' "$F" && echo "PASS seq-ref" || echo "FAIL seq-ref"
  grep -Fq 'two inputs' "$F" && echo "PASS two-inputs" || echo "FAIL two-inputs"
  grep -Fq 'thread handle' "$F" && echo "PASS handle" || echo "FAIL handle"
  grep -Fq 'and the path to `open-threads.md`' "$G" && echo "PASS dispatch" || echo "FAIL dispatch"
}
check7
```

- [ ] **Step 2: Run it to verify it fails**

Run: `check7`
Expected: four `FAIL` lines.

- [ ] **Step 3: Update the sequencing Overview**

Find this exact sentence:

```markdown
You are dispatched with one input: the path to `brief.md`. It already exists.
```

Replace with:

```markdown
You are dispatched with two inputs: the path to `brief.md`, and the path to `open-threads.md`. Both already exist.
```

Then find the end of that same paragraph and append this as a new paragraph immediately after it:

```markdown
`open-threads.md` is stage 1's working state: a coverage table and a list of unresolved threads, each with a bolded handle. **You read it and you never write it.** It is not a requirements section and it is not part of the brief — you use it for exactly two things, both specified below: citing a handle in a §7 component's open risks, and naming the file in §8.
```

- [ ] **Step 4: Extend the §7 open risks field**

Find this exact bullet in `## Section 7 — The Dependency-Ordered Body`:

```markdown
- **Open risks** — what is still uncertain about it.
```

Replace with:

```markdown
- **Open risks** — what is still uncertain about it. Where an uncertainty is already tracked as an open thread, cite it by its handle — "unresolved: `sso-vs-magic-link`" — rather than restating it. A §5 deferred candidate that bears on this component belongs here, cited the same way.
```

- [ ] **Step 5: Extend the §8 note**

Find this exact sentence in the §8 note:

```markdown
**Note for §8:** state plainly that signal's job is finished and that this brief is the input to whatever builds — `superpowers:brainstorming` per component, a human, or another pipeline — named as candidate consumers, not as a chosen one.
```

Insert immediately after it:

```markdown
Name `open-threads.md` alongside it as a live companion listing what the interrogation surfaced and never resolved, so a reader knows the brief is not the whole record. Naming an unresolved thread is not a recommendation about what to do with it, and the prohibition below stands unchanged.
```

- [ ] **Step 6: Update the sequencing frontmatter**

Find this exact fragment inside the `description:` line:

```
appends section 7, the body of the work ordered by dependency (what must be understood or built before what, and why), and section 8, the handoff pointer.
```

Replace with:

```
appends section 7, the body of the work ordered by dependency (what must be understood or built before what, and why), and section 8, the handoff pointer. It also reads open-threads.md so section 7 can cite unresolved threads by handle and section 8 can name the file.
```

- [ ] **Step 7: Update the conductor's stage 2 dispatch**

In `signal/skills/conducting-discovery/SKILL.md`, find this exact sentence:

```markdown
Dispatch `signal:sequencing-requirements` as a subagent with one input: **the path to `brief.md`**, the file stage 1 just wrote. There is no second path — it reads §1–§6 and appends to the same file.
```

Replace with:

```markdown
Dispatch `signal:sequencing-requirements` as a subagent with two inputs: **the path to `brief.md`**, the file stage 1 just wrote, and the path to `open-threads.md`. It reads §1–§6 and appends to `brief.md`; it reads `open-threads.md` and never writes it.
```

- [ ] **Step 8: Add the stage 2 red flag**

In `signal/skills/sequencing-requirements/SKILL.md`, find this exact red-flag line:

```markdown
- Writing anything into §8 about what should happen next.
```

Insert immediately after it:

```markdown
- Writing to `open-threads.md`, or closing a thread. You read it. Stage 1 owns it, with the user in the room.
- Copying a thread's full text into §7 or §8 instead of citing its handle. The reader has the file.
```

- [ ] **Step 9: Run the assertions to verify they pass**

Run: `check7`
Expected: four `PASS` lines.

- [ ] **Step 10: Confirm the two-writer boundary is untouched**

Run: `grep -Fq 'sections_1_6_lines' signal/skills/sequencing-requirements/SKILL.md && grep -Fq 'sections_1_6_lines' signal/skills/conducting-discovery/SKILL.md && echo PASS || echo FAIL`
Expected: `PASS`. The line-count tripwire on `brief.md` must be entirely unchanged by this task.

- [ ] **Step 11: Commit**

```bash
git add signal/skills/sequencing-requirements/SKILL.md signal/skills/conducting-discovery/SKILL.md
git commit -m "feat(signal): stage 2 cites open threads in section 7 and names the file in section 8"
```

---

### Task 8: README, command, and version

Last, because it describes the finished behavior of everything above.

**Files:**
- Modify: `signal/README.md`
- Modify: `signal/commands/signal.md`
- Modify: `signal/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

**Interfaces:**
- Consumes: every heading and file-layout decision from Tasks 1–7.
- Produces: nothing downstream.

- [ ] **Step 1: Write the assertions**

```bash
check8() {
  grep -Fq 'open-threads.md' signal/README.md && echo "PASS readme" || echo "FAIL readme"
  grep -Fq 'conventional answer' signal/README.md && echo "PASS method" || echo "FAIL method"
  grep -Fq 'open-threads.md' signal/commands/signal.md && echo "PASS cmd" || echo "FAIL cmd"
  grep -Fq '"version": "0.2.0"' signal/.claude-plugin/plugin.json && echo "PASS ver1" || echo "FAIL ver1"
  grep -Fq '"version": "0.2.0"' .claude-plugin/marketplace.json && echo "PASS ver2" || echo "FAIL ver2"
  grep -Fq 'so there was nothing to save' signal/README.md && echo "STALE claim present" || echo "PASS stale-removed"
}
check8
```

- [ ] **Step 2: Run it to verify it fails**

Run: `check8`
Expected: five `FAIL` lines and `STALE claim present`.

- [ ] **Step 3: Rewrite the first expectation bullet**

In `signal/README.md`, find this exact bullet and replace it in full:

```markdown
- **An interrogation you must actually answer.** signal will not hand off on a vague request. It asks one sharp question at a time, and it will not advance until it has asked at least 3 rounds of questions *and* filled all six coverage dimensions (problem, users, success criteria, constraints, scope boundaries, existing context). "Whatever makes sense" is not an answer it accepts. If your request is genuinely trivial — a rename, a config tweak — it says so in one sentence and exits without producing a brief; otherwise, budget for a real back-and-forth.
```

with:

```markdown
- **An interrogation you must actually answer.** signal will not hand off on a vague request. It asks one question at a time, and it asks by offering you the **conventional answer** — what most people in your position would do, with its reasoning visible — and inviting you to correct it. Agreeing is cheap and moves things along; correcting it is where the real requirements come from, and every correction gets mined for the reason behind it. It will not advance until it has run at least 3 rounds *and* filled all six coverage dimensions (problem, users, success criteria, constraints, scope boundaries, existing context). "Whatever makes sense" is not an answer it accepts. If your request is genuinely trivial — a rename, a config tweak — it says so in one sentence and exits without producing a brief; otherwise, budget for a real back-and-forth.
- **A session you can end whenever you like.** Signal writes `open-threads.md` as it goes: a coverage table of what is established, and a list of what it noticed and did not chase. Ending early does not lose the interrogation — the next run opens by offering you those threads, and never re-asks a dimension already banked. The gate is unchanged, so no brief ships until the six dimensions are genuinely filled; what changes is that getting there can take two sittings instead of one.
```

- [ ] **Step 4: Update the expansion bullet for DEFER**

Find this exact fragment in the expansion-checklist bullet:

```markdown
Nothing reaches the brief undecided: what you accept is written in as a requirement, what you reject is written into the non-goals list with your reason.
```

Replace with:

```markdown
Nothing reaches the brief undecided: what you accept is written in as a requirement, what you reject is written into the non-goals list with your reason, and what you genuinely cannot call yet is deferred — named in the brief and opened as a thread in `open-threads.md`, so it is tracked rather than fudged into a rejection.
```

- [ ] **Step 5: Update the run artifacts block**

Find this exact block under `## Run artifacts`:

```
00-request.md            the raw request, verbatim (written by the conductor)
brief.md                 THE deliverable — unnumbered so it is trivially findable
                         §1–§6 written by stage 1, §7–§8 appended by stage 2
```

Replace with:

```
00-request.md            the raw request, verbatim (written by the conductor)
open-threads.md          working state — the coverage table and what is still unresolved
                         written continuously during the interrogation, by stage 1
brief.md                 THE deliverable — unnumbered so it is trivially findable
                         §1–§6 written by stage 1, §7–§8 appended by stage 2
```

- [ ] **Step 6: Correct the stale abandonment claim**

Find this exact sentence under `**Re-running against an existing run.**`:

```markdown
If there is no `brief.md`, the earlier run never reached the advancement gate, so there was nothing to save.
```

Replace with:

```markdown
If there is no `brief.md`, the earlier run never reached the advancement gate — but `open-threads.md` will usually still be there, so resuming picks up the coverage table and the open threads instead of starting cold. Only a run abandoned before the first answer leaves nothing to resume from.
```

- [ ] **Step 7: Update the mermaid diagram**

Find this exact line in the mermaid block:

```
        S1["Interrogation rounds"] --> GATE{"Advancement gate:<br/>3+ rounds AND all six<br/>coverage dimensions filled"}
```

Replace with:

```
        S1["Interrogation rounds<br/>baseline offered, correction mined"] --> OT["open-threads.md updated<br/>coverage table + loose ends"]
        OT --> GATE{"Advancement gate:<br/>3+ rounds AND all six<br/>coverage dimensions filled"}
```

- [ ] **Step 8: Update the stages table**

Find this exact fragment in the stage 2 row of the `| Stage | Runs where | Produces |` table:

```markdown
It reads §1–§6 and never edits them;
```

Replace with:

```markdown
It reads §1–§6 and `open-threads.md`, and edits neither;
```

- [ ] **Step 8a: Update the mermaid adjudication node**

Find this exact line in the mermaid block:

```
        EXP --> ADJ["You adjudicate every candidate:<br/>IN-SCOPE or NON-GOAL, with a reason"]
```

Replace with:

```
        EXP --> ADJ["You adjudicate every candidate:<br/>IN-SCOPE, NON-GOAL or DEFER, with a reason"]
```

- [ ] **Step 9: Update the command file**

In `signal/commands/signal.md`, find this exact sentence:

```markdown
1. **Interrogate** — `signal:interrogating-requirements` in the main thread. Do not advance until the gate is met: at least 3 rounds AND all six coverage dimensions filled.
```

Replace with:

```markdown
1. **Interrogate** — `signal:interrogating-requirements` in the main thread. Probe by offering the conventional baseline and mining the correction, one question per turn, keeping `open-threads.md` current as you go. Do not advance until the gate is met: at least 3 rounds AND all six coverage dimensions filled.
```

Then find this exact sentence:

```markdown
2. **Sequence** — dispatch `signal:sequencing-requirements` with the path to `brief.md`.
```

Replace with:

```markdown
2. **Sequence** — dispatch `signal:sequencing-requirements` with the path to `brief.md` and the path to `open-threads.md`.
```

- [ ] **Step 10: Bump both versions**

In `signal/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, change signal's `"version": "0.1.0"` to `"version": "0.2.0"`. In `.claude-plugin/marketplace.json`, change only the entry whose `"name"` is `"signal"` — leave verity's version alone.

- [ ] **Step 11: Run the assertions to verify they pass**

Run: `check8`
Expected: five `PASS` lines and `PASS stale-removed`.

- [ ] **Step 12: Verify the JSON still parses**

Run: `python3 -c "import json;[json.load(open(p)) for p in ['signal/.claude-plugin/plugin.json','.claude-plugin/marketplace.json']];print('PASS')"`
Expected: `PASS`.

- [ ] **Step 13: Verify verity's version was not touched**

Run: `git diff .claude-plugin/marketplace.json`
Expected: exactly one changed line, inside the signal entry.

- [ ] **Step 14: Confirm the no-code claim still holds**

Run: `find signal -type f -not -name '*.md' -not -name '*.json'`
Expected: no output. If anything is listed, a previous task added code the README says does not exist — remove it.

- [ ] **Step 15: Commit**

```bash
git add signal/README.md signal/commands/signal.md signal/.claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "docs(signal): document hypothesis probing and session continuity, bump to 0.2.0"
```

---

## Final verification

- [ ] **Run every assertion together**

```bash
check1; check2; check3; check4; check5; check6; check7; check8
```

Expected: all `PASS`, plus `PASS stale-removed`.

- [ ] **Confirm no stale two-disposition wording survives anywhere**

Run: `grep -rF 'IN-SCOPE or NON-GOAL' signal/`
Expected: no output.

- [ ] **Confirm the gate survived all eight tasks**

Run: `grep -rF 'At least 3 rounds' signal/skills/interrogating-requirements/SKILL.md`
Expected: one hit.

- [ ] **Read the changed interrogation skill end to end**

Read `signal/skills/interrogating-requirements/SKILL.md` start to finish. It gained five sections and lost one; confirm it still reads as one document with a single voice, that no section contradicts another, and that the order runs: gate → capture → question form → probe families → returning sessions → readiness → escape valve → pushback → write-first → expansion beat → output → red flags → rationalizations.

- [ ] **Confirm nothing outside signal changed**

Run: `git diff --stat origin/master...HEAD -- . ':!signal' ':!docs' ':!.claude-plugin'`
Expected: no output.
