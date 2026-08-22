# Engineering Plugin — Plan 03: Planning, Execution, Brainstorming & the Triage Entrance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the planning/execution pair (`writing-plans`, `executing-plans` → `/implement`), the `brainstorming` design-dialogue gate, the remaining cross-cutting skills (`prototype`, `research`, `resolving-merge-conflicts`, `wizard` → `/wizard`), and the second entrance `triage` (→ `/triage`) — all original dashworthy works.

**Architecture:** `writing-plans` turns a Tier-1 spec into an ordered plan under `docs/dashworthy/engineering/plans/`, always ending in a test-hardening task. `executing-plans` runs a plan task-by-task through `engineering:tdd` and `engineering:code-review`, running the hardening task via `engineering:conducting-test-hardening`; it is surfaced as `/implement` and supports a subagent-driven mode. `brainstorming` sits between the entrances and `to-spec` as the approval gate. `triage` is a problem-first entrance that establishes a run, isolates with minimal effort, and routes to `diagnosing-bugs`, `signal`, or `brainstorming → to-spec` per a spec-decision table.

**Tech Stack:** Markdown skills/commands, POSIX `sh` for the wizard template. Depends on Plans 01 (skeleton, helpers, `to-spec`, absorbed signal/verity/vernacular) and 02 (`tdd`, `code-review`, `codebase-design`, `domain-modeling`, `diagnosing-bugs`).

## Global Constraints

Copied verbatim from `docs/dashworthy/engineering/specs/2026-08-21-engineering-plugin-design.md`.

- **Group tags this plan:** `[Planning]` (writing-plans, executing-plans), `[Design]` (brainstorming, prototype), `[Triage]` (triage). `research`, `resolving-merge-conflicts`, `wizard` carry **no tag** (cross-cutting, §5.6). (D18)
- **Every plan `writing-plans` produces ends with a Phase-3.5 test-hardening task** invoking `conducting-test-hardening`; `executing-plans` runs it. Verity is a **planned step**, not a session-start hook. (D15, §6.4)
- **`executing-plans` working state** under `.engineering/<run>/implement/` via the run-context helper. (§5.3, §6.4)
- **`brainstorming` holds a hard approval gate** — no `writing-plans`/build until the human approves; hands the approved design to `to-spec`. (D19, §6.6)
- **`triage` is minimal-effort and file-based** — logs to `.engineering/<run>/triage/`, **no tracker/labels/PR state-machine**; writes a spec only per the decision table. (D16, §6.2)
- **Namespacing** `engineering:` avoids collision with `superpowers:` during transition. (G5)
- **Originality:** authored fresh, nothing copied, **no attribution/NOTICE.** (§9)

---

### Task 1: `writing-plans` — spec → ordered plan (ends in a hardening task)

**Files:**
- Create: `engineering/skills/writing-plans/SKILL.md`

**Interfaces:**
- Consumes: a Tier-1 spec in `docs/dashworthy/engineering/specs/`; `CONTEXT.md`/ADRs when present.
- Produces: a plan at `docs/dashworthy/engineering/plans/<YYYY-MM-DD>-<topic>.md`, consumed by `executing-plans` (Task 2).

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: writing-plans
description: "[Planning] Turn an approved spec in docs/dashworthy/engineering/specs/ into an ordered, bite-sized implementation plan written to docs/dashworthy/engineering/plans/, with TDD integration points, review checkpoints, and a closing test-hardening task. Use after a spec is approved and before building. Reads CONTEXT.md/docs/adr when present."
---
```
Body (original, §9; superpowers-style, nothing copied) covers:
1. **Announce** — `Using the writing-plans skill to create the implementation plan.`
2. **Input** — read the spec from `docs/dashworthy/engineering/specs/`; if the spec spans independent subsystems, split into a plan set (each yields working software).
3. **Structure** — bite-sized `- [ ]` steps, exact file paths, TDD integration points (write-failing-test → run → implement → run → commit), review checkpoints, a Global Constraints block copied from the spec.
4. **Closing hardening task (D15)** — **every plan ends with a Phase-3.5 task that invokes `engineering:conducting-test-hardening`** so verity runs as a planned step.
5. **Output** — write to `docs/dashworthy/engineering/plans/<YYYY-MM-DD>-<topic>.md`; run a self-review pass (spec coverage, placeholder scan, type consistency).

- [ ] **Step 2: Validate frontmatter + `[Planning]` tag**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/writing-plans "[Planning]"`
Expected: `PASS frontmatter writing-plans`

- [ ] **Step 3: Confirm plan output path + mandatory hardening task**

Run:
```bash
grep -q "docs/dashworthy/engineering/plans/" engineering/skills/writing-plans/SKILL.md && \
grep -q "conducting-test-hardening" engineering/skills/writing-plans/SKILL.md && echo ok
```
Expected: `ok`

- [ ] **Step 4: Commit**

```bash
git add engineering/skills/writing-plans/
git commit -m "feat(engineering): author writing-plans (spec to plan, closing hardening task)"
```

---

### Task 2: `executing-plans` + `/implement`

**Files:**
- Create: `engineering/skills/executing-plans/SKILL.md`
- Create: `engineering/commands/implement.md`

**Interfaces:**
- Consumes: a plan from `docs/dashworthy/engineering/plans/`; `engineering:tdd`, `engineering:code-review`, `engineering:conducting-test-hardening`; run-context helper for `.engineering/<run>/implement/`.
- Produces: `/implement`.

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: executing-plans
description: "[Planning] Execute an implementation plan from docs/dashworthy/engineering/plans/ task by task — each task driven through tdd and gated by code-review — pausing at the plan's review checkpoints and running its closing test-hardening task via conducting-test-hardening. User-invoked via /implement. Supports an optional subagent-driven mode for independent tasks. Working state under .engineering/<run>/implement/."
---
```
Body (original, §9; superpowers-style) covers:
1. **Announce** — `Using the executing-plans skill to execute the plan.`
2. **Run context** — resolve the working dir via `sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" implement`.
3. **Per task** — drive through `engineering:tdd`, gate with `engineering:code-review`, check the box, commit; pause at each review checkpoint.
4. **Closing hardening (D15)** — when the plan's final Phase-3.5 task is reached, run `engineering:conducting-test-hardening`.
5. **Subagent-driven mode** — optional fan-out for independent tasks (compose with `dispatching-parallel-agents`, Plan 04).

- [ ] **Step 2: Create the command wrapper** `engineering/commands/implement.md` — thin wrapper (§5.2) invoking `engineering:executing-plans`, `argument-hint` for an optional plan path.

- [ ] **Step 3: Validate frontmatter + `[Planning]` tag**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/executing-plans "[Planning]"`
Expected: `PASS frontmatter executing-plans`

- [ ] **Step 4: Confirm wiring, run-context, hardening invocation**

Run:
```bash
grep -q "executing-plans" engineering/commands/implement.md && \
grep -q "run-context.sh" engineering/skills/executing-plans/SKILL.md && \
grep -q "conducting-test-hardening" engineering/skills/executing-plans/SKILL.md && \
grep -q "code-review" engineering/skills/executing-plans/SKILL.md && echo ok
```
Expected: `ok`

- [ ] **Step 5: Commit**

```bash
git add engineering/skills/executing-plans/ engineering/commands/implement.md
git commit -m "feat(engineering): author executing-plans + /implement"
```

---

### Task 3: `brainstorming` — design-dialogue approval gate (D19)

**Files:**
- Create: `engineering/skills/brainstorming/SKILL.md`

**Interfaces:**
- Consumes: a `signal` brief (`.engineering/<run>/signal/`) or a `triage` problem (`.engineering/<run>/triage/`).
- Produces: an approved design handed to `engineering:to-spec`.

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: brainstorming
description: "[Design] Shape a piece of work into an approved design through dialogue: explore context, propose 2-3 approaches with trade-offs, present the design section by section, and hold a hard approval gate before any spec or plan. Use after signal or triage has gathered material and before to-spec. Weighs how to build it (approach); does not interrogate requirements (signal) or design module internals (codebase-design)."
---
```
Body (original, §9; superpowers-style) covers:
1. **Announce** — `Using the brainstorming skill to shape the design.`
2. **Explore context** — files, docs, recent commits; read `CONTEXT.md`/ADRs when present.
3. **Approaches** — propose **2–3** with trade-offs and a recommendation; decompose if too large for one spec.
4. **Section-by-section design** — present and take incremental approval.
5. **HARD GATE** — do not invoke `writing-plans` or any build/implementation skill until the human approves the design.
6. **Handoff** — pass the approved design to `engineering:to-spec` (which serializes it).
7. **Boundaries** — vs `signal` (what), vs `codebase-design` (internals, post-spec), vs `to-spec` (writer). Skippable only for a triage quick fix that needs no spec.

- [ ] **Step 2: Validate frontmatter + `[Design]` tag**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/brainstorming "[Design]"`
Expected: `PASS frontmatter brainstorming`

- [ ] **Step 3: Confirm the gate and the to-spec handoff are present**

Run:
```bash
grep -qi "approv" engineering/skills/brainstorming/SKILL.md && \
grep -q "to-spec" engineering/skills/brainstorming/SKILL.md && \
grep -qi "2.3 approaches\|2-3 approaches\|two to three\|2–3 approaches" engineering/skills/brainstorming/SKILL.md && echo ok
```
Expected: `ok` (the approaches grep matches any of the accepted spellings; ensure one appears)

- [ ] **Step 4: Commit**

```bash
git add engineering/skills/brainstorming/
git commit -m "feat(engineering): author brainstorming design-dialogue gate (D19)"
```

---

### Task 4: `prototype` — throwaway validation model

**Files:**
- Create: `engineering/skills/prototype/SKILL.md`
- Create: `engineering/skills/prototype/LOGIC.md`
- Create: `engineering/skills/prototype/UI.md`

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: prototype
description: "[Design] Build a small throwaway model to validate a risky assumption before committing to a design. Use when a decision hinges on something cheaper to test than to argue. Document the validated decision in the brief/spec (file-based), not a tracker. Covers logic prototypes (LOGIC.md) and UI prototypes (UI.md)."
---
```
Body (original, §9) covers: announce line; when to prototype (a risk cheaper to test than argue); keep it throwaway; **document the validated decision in the brief/spec — file-based, not an "issue"**; reference `LOGIC.md` and `UI.md`.

- [ ] **Step 2: Create `LOGIC.md`** — original guidance for logic/algorithm prototypes (smallest harness that proves the assumption; discard after).

- [ ] **Step 3: Create `UI.md`** — original guidance for UI prototypes (lowest-fidelity mock that answers the question).

- [ ] **Step 4: Validate frontmatter + `[Design]` tag; confirm no tracker reference**

Run:
```bash
sh engineering/tests/frontmatter.sh engineering/skills/prototype "[Design]" && \
! grep -qi "issue tracker\|in the issue" engineering/skills/prototype/SKILL.md && \
grep -q "LOGIC.md" engineering/skills/prototype/SKILL.md && grep -q "UI.md" engineering/skills/prototype/SKILL.md && echo ok
```
Expected: `PASS frontmatter prototype` then `ok`

- [ ] **Step 5: Commit**

```bash
git add engineering/skills/prototype/
git commit -m "feat(engineering): author prototype (file-based, throwaway)"
```

---

### Task 5: `research` — background fact-gathering (cross-cutting, no tag)

**Files:**
- Create: `engineering/skills/research/SKILL.md`

- [ ] **Step 1: Create `SKILL.md` (NO group tag — cross-cutting)**

Frontmatter (exact):
```markdown
---
name: research
description: "Gather facts on a question by dispatching background agents and synthesize a cited Markdown findings file that follows the repo's conventions. Use when a decision needs external or codebase-wide information before proceeding. Cross-cutting; invoke from any phase."
---
```
Body (original, §9) covers: announce line; frame the question; dispatch background/parallel agents (compose with `dispatching-parallel-agents`); synthesize a **cited** Markdown file placed per repo conventions; never assert uncited claims.

- [ ] **Step 2: Validate frontmatter WITHOUT a required tag (cross-cutting)**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/research`
Expected: `PASS frontmatter research`

- [ ] **Step 3: Assert the description does NOT open with a `[Group]` tag**

Run: `python3 -c "import re;d=open('engineering/skills/research/SKILL.md').read();m=re.search(r'^description:\s*\"?(.)',d,re.M);assert m and m.group(1)!='[','research must not carry a group tag';print('ok')"`
Expected: `ok`

- [ ] **Step 4: Commit**

```bash
git add engineering/skills/research/
git commit -m "feat(engineering): author research (cross-cutting)"
```

---

### Task 6: `resolving-merge-conflicts` — git-only (cross-cutting, no tag)

**Files:**
- Create: `engineering/skills/resolving-merge-conflicts/SKILL.md`

- [ ] **Step 1: Create `SKILL.md` (NO group tag)**

Frontmatter (exact):
```markdown
---
name: resolving-merge-conflicts
description: "Reconcile a git merge or rebase conflict deliberately: understand both sides' intent, resolve to preserve both behaviors, and verify with tests before continuing. Use when git reports conflicts. Git-only; cross-cutting."
---
```
Body (original, §9) covers: announce line; read both sides' intent before editing; resolve to keep both behaviors (never blind-accept a side); run tests before `--continue`; git-only, no tracker.

- [ ] **Step 2: Validate frontmatter (no tag) + assert no `[Group]` opener**

Run:
```bash
sh engineering/tests/frontmatter.sh engineering/skills/resolving-merge-conflicts && \
python3 -c "import re;d=open('engineering/skills/resolving-merge-conflicts/SKILL.md').read();m=re.search(r'^description:\s*\"?(.)',d,re.M);assert m and m.group(1)!='[';print('ok')"
```
Expected: `PASS frontmatter resolving-merge-conflicts` then `ok`

- [ ] **Step 3: Commit**

```bash
git add engineering/skills/resolving-merge-conflicts/
git commit -m "feat(engineering): author resolving-merge-conflicts (git-only)"
```

---

### Task 7: `wizard` + `/wizard` (cross-cutting, no tag)

**Files:**
- Create: `engineering/skills/wizard/SKILL.md`
- Create: `engineering/scripts/wizard-template.sh`
- Create: `engineering/commands/wizard.md`

**Interfaces:**
- Produces: `/wizard`. Runtime dependency: the `gh` CLI (note it).

- [ ] **Step 1: Create `SKILL.md` (NO group tag)**

Frontmatter (exact):
```markdown
---
name: wizard
description: "Conduct a human through a multi-step interactive procedure one prompt at a time, driven by a shell template. User-invoked via /wizard. Requires the gh CLI at runtime for GitHub-backed steps. Cross-cutting."
---
```
Body (original, §9) covers: announce line; drive the human through steps one at a time using `scripts/wizard-template.sh`; note the `gh` CLI runtime dependency; keep state in the current working context, not a tracker.

- [ ] **Step 2: Create `scripts/wizard-template.sh`** — an original, commented POSIX `sh` skeleton for a one-prompt-at-a-time wizard (copy-before-edit header like the HITL template). Written from scratch (§9).

- [ ] **Step 3: Create the command wrapper** `engineering/commands/wizard.md` — thin wrapper invoking `engineering:wizard`.

- [ ] **Step 4: Validate frontmatter (no tag) + confirm wiring + no `[Group]` opener**

Run:
```bash
sh engineering/tests/frontmatter.sh engineering/skills/wizard && \
test -f engineering/scripts/wizard-template.sh && \
grep -q "wizard" engineering/commands/wizard.md && \
grep -qi "gh CLI\|gh cli\|\`gh\`" engineering/skills/wizard/SKILL.md && \
python3 -c "import re;d=open('engineering/skills/wizard/SKILL.md').read();m=re.search(r'^description:\s*\"?(.)',d,re.M);assert m and m.group(1)!='[';print('ok')"
```
Expected: `PASS frontmatter wizard` then `ok`

- [ ] **Step 5: Commit**

```bash
git add engineering/skills/wizard/ engineering/scripts/wizard-template.sh engineering/commands/wizard.md
git commit -m "feat(engineering): author wizard + /wizard"
```

---

### Task 8: `triage` + `/triage` — the problem-isolation entrance (D16)

**Files:**
- Create: `engineering/skills/triage/SKILL.md`
- Create: `engineering/skills/triage/references/isolation-checklist.md`
- Create: `engineering/skills/triage/references/spec-decision.md`
- Create: `engineering/commands/triage.md`
- Test: `engineering/tests/triage.sh`

**Interfaces:**
- Consumes: run-context helper for `.engineering/<run>/triage/`; dispatch targets `engineering:diagnosing-bugs`, `engineering:signal` (conducting-discovery), `engineering:brainstorming`, `engineering:to-spec` (all exist by now: Plans 01–02 + Tasks 1–3 here).
- Produces: `/triage` and a per-run disposition log.

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: triage
description: "[Triage] Problem-isolation entrance: given a reported defect, establish or join a run, verify/reproduce the claim, isolate the cause with minimal effort, then take the smallest next step — quick fix (diagnosing-bugs), grill (signal), or spec it (brainstorming then to-spec). User-invoked via /triage. Logs disposition to .engineering/<run>/triage/; file-based, no tracker."
---
```
Body (original, §9) covers:
1. **Announce** — `Using the triage skill to isolate the problem.`
2. **Establish/join a run** — `sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" triage <slug>`; log to `.engineering/<run>/triage/`.
3. **Verify/reproduce** — confirmed (with failing path), not-reproducible, or under-specified — before doing anything.
4. **Isolate** — by domain concept (read `CONTEXT.md`/ADRs when present); run a **redundancy check** (already implemented? → record and stop) and a lightweight **prior-rejection** check.
5. **Route (minimal effort)** — reference `references/spec-decision.md`: quick fix → `diagnosing-bugs`; under-specified/feature → `signal` → `brainstorming`; spec-worthy fix → `brainstorming` → `to-spec` → `writing-plans`; wontfix/already-done → record + close.
6. **No tracker** — everything file-based.

- [ ] **Step 2: Create `references/isolation-checklist.md`** — original reproduction/isolation checklist (reproduce first; bisect by domain concept; redundancy + prior-rejection checks).

- [ ] **Step 3: Create `references/spec-decision.md`** — the spec-decision table, authored from §6.2 verbatim in intent (original wording):

| Case | Route | Spec? |
|---|---|---|
| Cause obvious, fix small and localized, low risk | quick fix → `diagnosing-bugs` | **No** |
| Not reproducible, already implemented, or out of scope | record disposition + close | **No** |
| Under-specified, or really a feature request in disguise | grill → `signal` → `brainstorming` → `to-spec` | **Yes** (feature path) |
| Real fix but non-trivial — several sites, a design choice, risky/cross-cutting, needs sequencing, or handed to an AFK agent | `brainstorming` → `to-spec` → `writing-plans` | **Yes** |

Plus the rule of thumb: *spec when the fix needs a plan or another party will execute it; skip the spec when a single obvious change closes it.*

- [ ] **Step 4: Create the command wrapper** `engineering/commands/triage.md` — thin wrapper (§5.2) invoking `engineering:triage`, `argument-hint` for the problem description.

- [ ] **Step 5: Write the entrance test**

Create `engineering/tests/triage.sh`:
```sh
#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
grep -q "run-context.sh\" triage" skills/triage/SKILL.md || { echo "FAIL: triage must establish/join a run"; fail=1; }
grep -q "\.engineering/" skills/triage/SKILL.md || { echo "FAIL: triage must log to .engineering/<run>/triage"; fail=1; }
for t in diagnosing-bugs signal brainstorming to-spec; do
  grep -rq "$t" skills/triage/SKILL.md skills/triage/references || { echo "FAIL: triage missing route to $t"; fail=1; }
done
if grep -rqi "issue tracker\|label\|PR state" skills/triage; then echo "FAIL: triage carries tracker coupling"; fail=1; fi
grep -q "triage" commands/triage.md || { echo "FAIL: /triage wrapper missing"; fail=1; }
[ "$fail" = 0 ] && echo "PASS triage.sh" || exit 1
```

- [ ] **Step 6: Run frontmatter + entrance tests**

Run:
```bash
sh engineering/tests/frontmatter.sh engineering/skills/triage "[Triage]" && sh engineering/tests/triage.sh
```
Expected: `PASS frontmatter triage` then `PASS triage.sh`

- [ ] **Step 7: Commit**

```bash
git add engineering/skills/triage/ engineering/commands/triage.md engineering/tests/triage.sh
git commit -m "feat(engineering): author triage entrance + /triage (D16)"
```

---

### Task 9: Update the skills index + plan-03 group gate

**Files:**
- Modify: `engineering/skills/README.md` (verify rows)
- Create: `engineering/tests/plan03.sh`

- [ ] **Step 1: Verify the index lists every Plan-03 skill**

Run:
```bash
for s in writing-plans executing-plans brainstorming prototype research resolving-merge-conflicts wizard triage; do grep -q "\`$s\`" engineering/skills/README.md || echo "MISSING $s"; done; echo done
```
Expected: `done` with no `MISSING` lines. (All were pre-listed in Plan 01's index.)

- [ ] **Step 2: Write the gate**

Create `engineering/tests/plan03.sh`:
```sh
#!/bin/sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/frontmatter.sh" "$d/../skills/writing-plans" "[Planning]"
sh "$d/frontmatter.sh" "$d/../skills/executing-plans" "[Planning]"
sh "$d/frontmatter.sh" "$d/../skills/brainstorming" "[Design]"
sh "$d/frontmatter.sh" "$d/../skills/prototype" "[Design]"
sh "$d/frontmatter.sh" "$d/../skills/research"
sh "$d/frontmatter.sh" "$d/../skills/resolving-merge-conflicts"
sh "$d/frontmatter.sh" "$d/../skills/wizard"
sh "$d/frontmatter.sh" "$d/../skills/triage" "[Triage]"
sh "$d/triage.sh"
# cross-cutting skills must NOT open with a [Group] tag
for s in research resolving-merge-conflicts wizard; do
  python3 -c "import re,sys;d=open(sys.argv[1]).read();m=re.search(r'^description:\s*\"?(.)',d,re.M);assert m and m.group(1)!='[', sys.argv[1]" "$d/../skills/$s/SKILL.md"
done
echo "ALL PLAN-03 CHECKS PASS"
```

- [ ] **Step 3: Run it**

Run: `sh engineering/tests/plan03.sh`
Expected: ends with `ALL PLAN-03 CHECKS PASS`

- [ ] **Step 4: Commit**

```bash
git add engineering/skills/README.md engineering/tests/plan03.sh
git commit -m "test(engineering): planning/execution + entrances group gate"
```

---

## Self-Review

**Spec coverage (build-sequence steps 9–11):**
- §13.9 `writing-plans` (→ plans/, closing hardening task) + `executing-plans` (+ `/implement`, `.engineering/<run>/implement/`) → Tasks 1, 2. ✓
- §13.10 `brainstorming` design-dialogue gate (D19) → Task 3. ✓
- §13.11 `prototype`, `research`, `resolving-merge-conflicts`, `wizard` (+`/wizard`), `triage` (+`/triage`) → Tasks 4–8. ✓
- D15 verity as planned step (writing-plans bakes it, executing-plans runs it) → Tasks 1, 2 asserts. ✓
- D16 triage file-based, run-logged, routed by decision table, no tracker → Task 8 + `triage.sh`. ✓
- D18 group tags: `[Planning]`/`[Design]`/`[Triage]` tagged, `research`/`resolving-merge-conflicts`/`wizard` untagged → every task + Task 9 gate. ✓

**Placeholder scan:** none — exact frontmatter, spec-driven body contracts, named companion/reference files, thin command wrappers, and grep/entrance-test verification for every task.

**Type/interface consistency:** `executing-plans` invokes `engineering:tdd`, `engineering:code-review`, `engineering:conducting-test-hardening` — `tdd`/`code-review` from Plan 02, `conducting-test-hardening` from Plan 01 (absorbed verity). `triage` dispatches `diagnosing-bugs` (Plan 02), `signal`/`to-spec` (Plan 01), `brainstorming` (Task 3 here, authored before Task 8). `brainstorming` hands to `to-spec` (Plan 01). Group tags match the Plan 01 index. All dispatch targets exist by the time each task runs.
