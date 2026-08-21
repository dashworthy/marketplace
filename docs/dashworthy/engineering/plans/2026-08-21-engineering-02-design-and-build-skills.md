# Engineering Plugin — Plan 02: Design & Build Skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the design-phase and build-phase skills of the `engineering` plugin — `codebase-design`, `domain-modeling` (with its `CONTEXT.md`/ADR templates), `tdd`, `diagnosing-bugs`, `code-review`, and the `/improve-codebase-architecture` command — all as original dashworthy works.

**Architecture:** Six model-invoked skills (one surfaced as a command) plus two format templates and one HTML-report companion. They share the knowledge substrate `CONTEXT.md` + `docs/adr/`, which `domain-modeling` owns and the others read when present (never require). `code-review` reads its Spec axis from the Tier-1 spec directory, not a tracker. Every file is authored fresh in dashworthy voice; nothing is copied and no NOTICE is produced.

**Tech Stack:** Markdown skills/commands, POSIX `sh` for the HITL loop template, self-contained HTML (Tailwind + Mermaid via CDN) for the architecture report. Python 3 only for the frontmatter validator. Depends on Plan 01 (skeleton, `frontmatter.sh`, run-context helper, `skills/README.md`).

## Global Constraints

Copied verbatim from `docs/dashworthy/engineering/specs/2026-08-21-engineering-plugin-design.md`.

- **Plugin name:** `engineering`. Skills addressed `engineering:<skill>`. (D9)
- **`[Group]` tag opens every process-tied `description`** — this plan uses `[Design]` (codebase-design, improve-codebase-architecture, prototype), `[Discovery]` (domain-modeling), `[Build]` (tdd, diagnosing-bugs, code-review). (D18, §5.6)
- **Knowledge substrate is optional:** design/build skills read `CONTEXT.md`/`docs/adr/` **when present, never demand them.** (§10, D5)
- **`code-review` spec source is file-based:** `docs/dashworthy/engineering/specs/` + user-supplied paths — **no tracker lookup, no `setup-matt-pocock-skills` prompt.** (§6.2, §5.1)
- **`improve-codebase-architecture` is a command** (`disable-model-invocation: true`) and **has no `grill-with-docs` dependency** — it leans on `codebase-design` + `domain-modeling`. (§6.2, G4)
- **Originality:** authored fresh, dashworthy voice, nothing copied, **no attribution/NOTICE anywhere.** (§9)
- **Skills stay flat** under `engineering/skills/`. (D18)

---

### Task 1: `codebase-design` — deep-module vocabulary (design-phase foundation)

**Files:**
- Create: `engineering/skills/codebase-design/SKILL.md`
- Create: `engineering/skills/codebase-design/DEEPENING.md`
- Create: `engineering/skills/codebase-design/DESIGN-IT-TWICE.md`

**Interfaces:**
- Produces: the design vocabulary (`engineering:codebase-design`) that `improve-codebase-architecture` (Task 6) and `brainstorming` (Plan 03) invoke for interface exploration.

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: codebase-design
description: "[Design] Shape module interfaces so complexity is hidden behind narrow, deep boundaries. Use when defining a new module's interface, judging whether a boundary earns its keep, or before a larger architecture pass. Reads CONTEXT.md/docs/adr when present; never requires them. Not a codebase-wide audit (that is improve-codebase-architecture) and not product/approach design (that is brainstorming)."
---
```
Body (author original prose, §9) must cover, in dashworthy voice:
1. **Announce** — `Using the codebase-design skill to shape this interface.`
2. **The depth principle** — deep modules (simple interface, substantial implementation) vs shallow (interface ≈ implementation cost); why depth is the goal. Reference `DEEPENING.md` for the moves.
3. **Information hiding & leakage** — what a module must not expose; how a leak shows up at the seam.
4. **Design-it-twice discipline** — reference `DESIGN-IT-TWICE.md`: sketch ≥2 interface shapes before committing.
5. **Reading the substrate** — consult `CONTEXT.md`/`docs/adr/` when present for existing names/decisions; never require them.
6. **Boundaries** — vs `improve-codebase-architecture` (whole-codebase, command) and `brainstorming` (product approach, pre-spec).

- [ ] **Step 2: Create `DEEPENING.md`** — original prose listing the concrete moves that deepen a shallow module (pull complexity down behind the interface, widen responsibility per call, collapse pass-through layers, default the common case), each with a before/after shape sketch in dashworthy voice.

- [ ] **Step 3: Create `DESIGN-IT-TWICE.md`** — original prose on generating two-plus genuinely different interface designs and the criteria to choose between them (call-site simplicity, hidden complexity, misuse resistance).

- [ ] **Step 4: Validate frontmatter + `[Design]` tag**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/codebase-design "[Design]"`
Expected: `PASS frontmatter codebase-design`

- [ ] **Step 5: Confirm companions referenced and substrate is optional**

Run:
```bash
grep -q "DEEPENING.md" engineering/skills/codebase-design/SKILL.md && \
grep -q "DESIGN-IT-TWICE.md" engineering/skills/codebase-design/SKILL.md && \
grep -qi "when present" engineering/skills/codebase-design/SKILL.md && echo ok
```
Expected: `ok`

- [ ] **Step 6: Commit**

```bash
git add engineering/skills/codebase-design/
git commit -m "feat(engineering): author codebase-design (deep-module vocabulary)"
```

---

### Task 2: `domain-modeling` — owns `CONTEXT.md` + `docs/adr/` (resolves G3)

**Files:**
- Create: `engineering/skills/domain-modeling/SKILL.md`
- Create: `engineering/skills/domain-modeling/CONTEXT-FORMAT.md`
- Create: `engineering/skills/domain-modeling/ADR-FORMAT.md`

**Interfaces:**
- Produces: `CONTEXT.md` (repo root) and `docs/adr/NNNN-*.md` records — the substrate every design/build skill reads. Templates define their shape.

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: domain-modeling
description: "[Discovery] Crystallize how the project names things: maintain CONTEXT.md (the domain glossary) and docs/adr/ (decision records). Use when a new domain term appears, a naming decision is made, or an architectural choice needs recording. Complements signal (which explores what to build) by owning how we name it. Writes CONTEXT.md at repo root and docs/adr/; does not design interfaces (codebase-design) or write specs (to-spec)."
---
```
Body (original, §9) covers:
1. **Announce** — `Using the domain-modeling skill to update the project's domain model.`
2. **What CONTEXT.md is** — a living glossary of domain terms, mapped to code; reference `CONTEXT-FORMAT.md`.
3. **When to write an ADR** — a decision with alternatives and consequences worth remembering; reference `ADR-FORMAT.md`; number sequentially under `docs/adr/`.
4. **Boundary vs `signal`** — signal = *what to build*; domain-modeling = *how we name it*.
5. **Optionality** — these are conveniences for later skills; the project is never blocked on them existing.

- [ ] **Step 2: Create `CONTEXT-FORMAT.md`** — original dashworthy template for `CONTEXT.md`: a title, a one-line purpose, and a glossary table (`Term | Meaning | Where in code`), plus a short "how to keep it current" note. No text copied from any source (§9); the glossary-file convention is well-known (G3).

- [ ] **Step 3: Create `ADR-FORMAT.md`** — original template for a lightweight ADR: `# NNNN. <title>`, `Status` (Proposed/Accepted/Superseded), `Context`, `Decision`, `Consequences`. Filename convention `docs/adr/NNNN-<kebab-title>.md`.

- [ ] **Step 4: Validate frontmatter + `[Discovery]` tag**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/domain-modeling "[Discovery]"`
Expected: `PASS frontmatter domain-modeling`

- [ ] **Step 5: Confirm both templates exist and are referenced**

Run:
```bash
test -f engineering/skills/domain-modeling/CONTEXT-FORMAT.md && \
test -f engineering/skills/domain-modeling/ADR-FORMAT.md && \
grep -q "CONTEXT-FORMAT.md" engineering/skills/domain-modeling/SKILL.md && \
grep -q "ADR-FORMAT.md" engineering/skills/domain-modeling/SKILL.md && \
grep -q "docs/adr" engineering/skills/domain-modeling/SKILL.md && echo ok
```
Expected: `ok`

- [ ] **Step 6: Commit**

```bash
git add engineering/skills/domain-modeling/
git commit -m "feat(engineering): author domain-modeling + CONTEXT/ADR templates (G3)"
```

---

### Task 3: `tdd` — the red-green build loop

**Files:**
- Create: `engineering/skills/tdd/SKILL.md`
- Create: `engineering/skills/tdd/tests.md`
- Create: `engineering/skills/tdd/mocking.md`

**Interfaces:**
- Produces: `engineering:tdd`, invoked per task by `executing-plans` (Plan 03).

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: tdd
description: "[Build] Drive implementation with a strict red-green-refactor loop: write a failing test, watch it fail, write the minimal code to pass, refactor. Use when building any behavior that can be tested first. Reads CONTEXT.md when present. Distinct from test-hardening (verity), which hardens existing tests after the fact — tdd builds them during implementation."
---
```
Body (original, §9) covers: announce line; the red→green→refactor cycle with the discipline of watching the test fail first; one behavior per cycle; reference `tests.md` for test design and `mocking.md` for when/what to mock; the boundary note vs verity (build-time vs after-the-fact hardening; they compose).

- [ ] **Step 2: Create `tests.md`** — original guidance on good test design (one behavior per test, arrange/act/assert, naming, avoiding test interdependence).

- [ ] **Step 3: Create `mocking.md`** — original guidance on when mocking helps vs harms (mock at boundaries you own, prefer real collaborators, never mock the thing under test).

- [ ] **Step 4: Validate frontmatter + `[Build]` tag**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/tdd "[Build]"`
Expected: `PASS frontmatter tdd`

- [ ] **Step 5: Confirm companions + verity boundary present**

Run:
```bash
grep -q "tests.md" engineering/skills/tdd/SKILL.md && \
grep -q "mocking.md" engineering/skills/tdd/SKILL.md && \
grep -qi "harden" engineering/skills/tdd/SKILL.md && echo ok
```
Expected: `ok`

- [ ] **Step 6: Commit**

```bash
git add engineering/skills/tdd/
git commit -m "feat(engineering): author tdd (red-green build loop)"
```

---

### Task 4: `diagnosing-bugs` — systematic debugging

**Files:**
- Create: `engineering/skills/diagnosing-bugs/SKILL.md`
- Create: `engineering/scripts/hitl-loop.template.sh`

**Interfaces:**
- Consumes: nothing required.
- Produces: `engineering:diagnosing-bugs`, the quick-fix target for `triage` (Plan 03).

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: diagnosing-bugs
description: "[Build] Find a defect's root cause before changing code: reproduce, form a hypothesis, isolate, and confirm with evidence. Use when a bug is reported or a test fails for a non-obvious reason. Pairs with an optional human-in-the-loop reproduction script (scripts/hitl-loop.template.sh). Does not isolate whether a report is even valid — that is triage."
---
```
Body (original, §9) covers: announce line; reproduce-first (never fix what you cannot reproduce); hypothesis → minimal isolation → evidence → confirmed cause; only then fix; how to use the HITL loop template for reproductions that need a human step; boundary vs `triage` (triage decides *whether/what*, diagnosing-bugs finds *why*).

- [ ] **Step 2: Create `scripts/hitl-loop.template.sh`** — an original, commented POSIX `sh` skeleton for a human-in-the-loop reproduce/observe cycle (prompt the human to perform a step, capture output, loop until the failure is pinned). Written from scratch (§9). Include a top comment: `# Template — copy into .engineering/<run>/... before editing; do not run in place.`

- [ ] **Step 3: Validate frontmatter + `[Build]` tag**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/diagnosing-bugs "[Build]"`
Expected: `PASS frontmatter diagnosing-bugs`

- [ ] **Step 4: Confirm template exists, is referenced, and is not tracker-coupled**

Run:
```bash
test -f engineering/scripts/hitl-loop.template.sh && \
grep -q "hitl-loop.template.sh" engineering/skills/diagnosing-bugs/SKILL.md && \
! grep -qi "issue tracker\|setup-matt" engineering/skills/diagnosing-bugs/SKILL.md && echo ok
```
Expected: `ok`

- [ ] **Step 5: Commit**

```bash
git add engineering/skills/diagnosing-bugs/ engineering/scripts/hitl-loop.template.sh
git commit -m "feat(engineering): author diagnosing-bugs + HITL loop template"
```

---

### Task 5: `code-review` — two-axis review, file-based spec source

**Files:**
- Create: `engineering/skills/code-review/SKILL.md`

**Interfaces:**
- Consumes: the Tier-1 spec directory `docs/dashworthy/engineering/specs/` (Spec axis) + user-supplied paths.
- Produces: `engineering:code-review`, the review gate `executing-plans` (Plan 03) invokes per task.

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: code-review
description: "[Build] Review a change on two axes — Standards (does the code meet engineering norms) and Spec (does it do what was asked) — dispatching parallel sub-reviewers. Use before merging or when asked to review a diff/branch/PR. Finds the Spec axis in docs/dashworthy/engineering/specs/ or a user-supplied path. Reads CONTEXT.md/docs/adr when present."
---
```
Body (original, §9) covers:
1. **Announce** — `Using the code-review skill to review this change.`
2. **Two axes** — Standards (correctness, clarity, tests, security, conventions) and Spec (matches the approved spec / user intent).
3. **File-based Spec source** — locate the relevant spec in `docs/dashworthy/engineering/specs/`, or accept a user-supplied path; **if no spec exists, review Standards-only and say so** — do NOT prompt to set up a tracker or run any setup skill.
4. **Parallel sub-reviewers** — dispatch independent reviewers per axis and synthesize (compose with `dispatching-parallel-agents`, Plan 04).
5. **Substrate** — read `CONTEXT.md`/ADRs when present.
6. **Transition note** — the `code-review` name may also appear from a separately-installed review plugin; that coexistence is fine (G5).

- [ ] **Step 2: Validate frontmatter + `[Build]` tag**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/code-review "[Build]"`
Expected: `PASS frontmatter code-review`

- [ ] **Step 3: Confirm file-based spec source and NO tracker prompt**

Run:
```bash
grep -q "docs/dashworthy/engineering/specs/" engineering/skills/code-review/SKILL.md && \
! grep -qi "issue-tracker\|setup-matt-pocock" engineering/skills/code-review/SKILL.md && echo ok
```
Expected: `ok`

- [ ] **Step 4: Commit**

```bash
git add engineering/skills/code-review/
git commit -m "feat(engineering): author code-review (file-based spec source, two axes)"
```

---

### Task 6: `improve-codebase-architecture` — command, no grill dependency (G4)

**Files:**
- Create: `engineering/skills/improve-codebase-architecture/SKILL.md`
- Create: `engineering/skills/improve-codebase-architecture/HTML-REPORT.md`
- Create: `engineering/commands/improve-codebase-architecture.md`

**Interfaces:**
- Consumes: `engineering:codebase-design` (interface exploration) + `engineering:domain-modeling` (CONTEXT/ADR updates) — replacing the severed `grill-with-docs`.
- Produces: `/improve-codebase-architecture` and a self-contained HTML report in a temp dir.

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter + `disable-model-invocation`**

Frontmatter (exact):
```markdown
---
name: improve-codebase-architecture
description: "[Design] Audit a codebase for shallow modules and tangled boundaries, then propose and stage deepening changes, emitting a self-contained HTML report. User-invoked via /improve-codebase-architecture. Leans on codebase-design (interface moves) and domain-modeling (naming/decisions); reads CONTEXT.md/docs/adr when present."
disable-model-invocation: true
---
```
Body (original, §9) covers:
1. **Announce** — `Using the improve-codebase-architecture skill.`
2. **Scan** — map modules, flag shallow ones and boundary leaks.
3. **Deepen** — for each finding, invoke `engineering:codebase-design` for the interface move and `engineering:domain-modeling` to record naming/decisions — **this replaces the old grilling loop (G4); ensure the pass terminates** (bounded finding list, no interactive doc-grill).
4. **Report** — reference `HTML-REPORT.md`; write a self-contained HTML file to a temp dir.

- [ ] **Step 2: Create `HTML-REPORT.md`** — original spec for the report: a single self-contained `.html` (Tailwind + Mermaid via CDN) written to the OS temp dir, sections for findings/before-after/mermaid module map. Author fresh (§9).

- [ ] **Step 3: Create the command wrapper** `engineering/commands/improve-codebase-architecture.md` — a few lines that invoke `engineering:improve-codebase-architecture` (thin wrapper per §5.2). Include an `argument-hint` for an optional target path.

- [ ] **Step 4: Validate frontmatter + `[Design]` tag**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/improve-codebase-architecture "[Design]"`
Expected: `PASS frontmatter improve-codebase-architecture`

- [ ] **Step 5: Confirm command wiring, no grill dependency, disable-model-invocation set**

Run:
```bash
grep -q "improve-codebase-architecture" engineering/commands/improve-codebase-architecture.md && \
grep -q "disable-model-invocation: true" engineering/skills/improve-codebase-architecture/SKILL.md && \
grep -q "codebase-design" engineering/skills/improve-codebase-architecture/SKILL.md && \
grep -q "domain-modeling" engineering/skills/improve-codebase-architecture/SKILL.md && \
! grep -qi "grill-with-docs\|grill" engineering/skills/improve-codebase-architecture/SKILL.md && echo ok
```
Expected: `ok`

- [ ] **Step 6: Commit**

```bash
git add engineering/skills/improve-codebase-architecture/ engineering/commands/improve-codebase-architecture.md
git commit -m "feat(engineering): author improve-codebase-architecture command (no grill dep, G4)"
```

---

### Task 7: Update the skills index + design/build group gate

**Files:**
- Modify: `engineering/skills/README.md` (rows already present from Plan 01 — verify they match the shipped skills)
- Create: `engineering/tests/plan02.sh`

- [ ] **Step 1: Confirm the index already lists every Plan-02 skill under the right group**

The Plan 01 `skills/README.md` table already names `codebase-design`, `improve-codebase-architecture`, `prototype` under Design; `domain-modeling` under Discovery; `tdd`, `diagnosing-bugs`, `code-review` under Build. Verify no drift:

Run:
```bash
for s in codebase-design improve-codebase-architecture domain-modeling tdd diagnosing-bugs code-review; do grep -q "\`$s\`" engineering/skills/README.md || echo "MISSING $s"; done; echo done
```
Expected: `done` with no `MISSING` lines. (If any print, add that skill to the correct group row.)

- [ ] **Step 2: Write the aggregate gate for this plan**

Create `engineering/tests/plan02.sh`:
```sh
#!/bin/sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/frontmatter.sh" "$d/../skills/codebase-design" "[Design]"
sh "$d/frontmatter.sh" "$d/../skills/domain-modeling" "[Discovery]"
sh "$d/frontmatter.sh" "$d/../skills/tdd" "[Build]"
sh "$d/frontmatter.sh" "$d/../skills/diagnosing-bugs" "[Build]"
sh "$d/frontmatter.sh" "$d/../skills/code-review" "[Build]"
sh "$d/frontmatter.sh" "$d/../skills/improve-codebase-architecture" "[Design]"
# No NOTICE / attribution introduced by this plan.
if grep -rIl "NOTICE\|Matt Pocock\|superpowers by" "$d/../skills/codebase-design" "$d/../skills/domain-modeling" "$d/../skills/tdd" "$d/../skills/diagnosing-bugs" "$d/../skills/code-review" "$d/../skills/improve-codebase-architecture" 2>/dev/null; then
  echo "FAIL: attribution/NOTICE leak"; exit 1; fi
echo "ALL PLAN-02 CHECKS PASS"
```

- [ ] **Step 3: Run it**

Run: `sh engineering/tests/plan02.sh`
Expected: ends with `ALL PLAN-02 CHECKS PASS`

- [ ] **Step 4: Commit**

```bash
git add engineering/skills/README.md engineering/tests/plan02.sh
git commit -m "test(engineering): design/build group gate + index verification"
```

---

## Self-Review

**Spec coverage (build-sequence steps 5–8):**
- §13.5 `codebase-design` foundation → Task 1. ✓
- §13.6 `domain-modeling` + CONTEXT/ADR templates (G3) → Task 2. ✓
- §13.7 `tdd`, `diagnosing-bugs`, `code-review` (file-based spec source) → Tasks 3, 4, 5. ✓
- §13.8 `improve-codebase-architecture` command, no grill dependency (G4) → Task 6. ✓
- D18 `[Group]` tags + index → every task's frontmatter + Task 7. ✓
- §10 substrate optional ("when present") → asserted in Tasks 1, 5. ✓
- §9 no NOTICE/attribution → Task 7 leak scan. ✓

**Deferred (not gaps):** `prototype` (a Design-group skill) is authored in Plan 03 alongside the other step-11 skills, not here, because the build sequence groups it with research/wizard/triage; the index row is pre-listed. `brainstorming` (also Design group) is Plan 03. Foundations, planning/execution, cutover: Plans 03–04.

**Placeholder scan:** none — each task gives exact frontmatter, an explicit body-section contract driven by the spec, named companion files with their required content, and grep-based verification. Skill *prose* is intentionally authored by the executor (per §9 it must be original), but every structural and factual requirement is pinned and checked.

**Type/interface consistency:** group tags match the Plan 01 `skills/README.md` index exactly (`[Design]`/`[Discovery]`/`[Build]`). `improve-codebase-architecture` consumes `codebase-design` + `domain-modeling`, both authored earlier in this same plan (Tasks 1, 2) before Task 6. `frontmatter.sh` and the run-context helper come from Plan 01.
