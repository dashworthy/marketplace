# Engineering Plugin — Plan 04: Foundations, Productivity Commands & Marketplace Cutover Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the six workflow-foundation skills, the three productivity commands, then cut the marketplace over to the single `engineering` plugin — rewriting `marketplace.json` and the root `README.md`, deleting the absorbed `signal/`/`verity/`/`vernacular/` directories, and running the final acceptance checklist.

**Architecture:** Six model-invoked foundation skills (`[Foundation]` tag) provide workflow discipline; `finishing-a-development-branch` carries the retired-hook's verity safety net. Three pure `commands/*.md` (`/handoff`, `/to-signal`, `/wait-what`) are self-contained single-shots with no skill entry. The cutover replaces three marketplace entries with one, rewrites the root README around the pipeline with a deprecation redirect, and deletes the old top-level plugin directories. A final acceptance suite proves the whole §16 checklist.

**Tech Stack:** Markdown skills/commands, JSON for the marketplace manifest, `git` for deletion and history. Depends on Plans 01–03 (all skills, commands, the `engineering` marketplace entry, and the test harness). This is the terminal plan — after it, `engineering` is the only plugin.

## Global Constraints

Copied verbatim from `docs/dashworthy/engineering/specs/2026-08-21-engineering-plugin-design.md`.

- **Group tag this plan:** `[Foundation]` on all six foundation skills. The three productivity capabilities are **pure commands — no skill entry, no tag.** (D18, §5.2, §6.3)
- **`finishing-a-development-branch` carries the verity finish-time safety net** — if implementation was never hardened, prompt `conducting-test-hardening` before finishing. (D15, §6.5)
- **`using-skills` is dashworthy's own** skill-discovery discipline, named `using-skills` (not `using-superpowers`). (§6.5)
- **Cutover:** single `engineering` marketplace entry; root README rewritten with a **Deprecation** section; old `signal/`/`verity/`/`vernacular/` dirs deleted only after their contents are absorbed and verified. (§8)
- **Final acceptance = §13.16:** 9 commands resolve; every skill frontmatter valid (process-tied ones tagged); `skills/README.md` lists all; entrance-bootstrap hook fires naming both entrances; `/triage` logs a run; `to-spec` writes specs from both entrances; verity is a planned step (no session-start hook); vernacular `tests/` pass; two phases share a `<run>` (G7); **no dangling `signal:`/`verity:`/`vernacular:` refs or `.signal`/`.verity`/`.vernacular` paths; `.engineering/` gitignored; no NOTICE/attribution anywhere.** (§13.16, §9)
- **Originality:** authored fresh, nothing copied, **no attribution/NOTICE.** (§9)

---

### Task 1: `using-git-worktrees` — isolated workspace discipline

**Files:**
- Create: `engineering/skills/using-git-worktrees/SKILL.md`

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: using-git-worktrees
description: "[Foundation] Ensure work happens in an isolated workspace before making changes: detect existing isolation, prefer the harness's native worktree tool, fall back to git worktree, and verify a clean baseline. Use at the start of any implementation task. Model-invoked; no command."
---
```
Body (original, §9; superpowers-style, nothing copied) covers: announce line; **detect existing isolation first** (already in a linked worktree → skip creation; guard against submodules); prefer a native worktree tool over raw `git worktree`; project setup + clean-baseline test; report readiness.

- [ ] **Step 2: Validate + confirm detect-first discipline**

Run:
```bash
sh engineering/tests/frontmatter.sh engineering/skills/using-git-worktrees "[Foundation]" && \
grep -qi "detect\|already" engineering/skills/using-git-worktrees/SKILL.md && echo ok
```
Expected: `PASS frontmatter using-git-worktrees` then `ok`

- [ ] **Step 3: Commit**

```bash
git add engineering/skills/using-git-worktrees/
git commit -m "feat(engineering): author using-git-worktrees foundation"
```

---

### Task 2: `finishing-a-development-branch` — integration + verity safety net (D15)

**Files:**
- Create: `engineering/skills/finishing-a-development-branch/SKILL.md`

**Interfaces:**
- Consumes: `engineering:conducting-test-hardening` (Plan 01) as the finish-time safety net.

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: finishing-a-development-branch
description: "[Foundation] When work is complete and green, present structured options for integrating the branch (merge / PR / cleanup) and carry out the choice. Use at the end of a piece of work. Safety net: if the branch was never test-hardened, prompt to run conducting-test-hardening before finishing. Model-invoked; no command."
---
```
Body (original, §9) covers: announce line; require green + verified before finishing (compose with `verification-before-completion`); **verity safety net (D15)** — if no plan hardened the branch (or the hardening task was skipped), prompt `engineering:conducting-test-hardening` before integrating; present merge/PR/cleanup options and execute the chosen one.

- [ ] **Step 2: Validate + confirm the safety-net invocation**

Run:
```bash
sh engineering/tests/frontmatter.sh engineering/skills/finishing-a-development-branch "[Foundation]" && \
grep -q "conducting-test-hardening" engineering/skills/finishing-a-development-branch/SKILL.md && echo ok
```
Expected: `PASS frontmatter finishing-a-development-branch` then `ok`

- [ ] **Step 3: Commit**

```bash
git add engineering/skills/finishing-a-development-branch/
git commit -m "feat(engineering): author finishing-a-development-branch (verity finish-time net, D15)"
```

---

### Task 3: `verification-before-completion`

**Files:**
- Create: `engineering/skills/verification-before-completion/SKILL.md`

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: verification-before-completion
description: "[Foundation] Before claiming done, fixed, or passing, run the verification commands and confirm their output — evidence before assertions. Use whenever you are about to report success. Complements test-hardening (which hardens the tests themselves). Model-invoked; no command."
---
```
Body (original, §9) covers: announce line; never assert success without running the check and reading its output; quote the decisive evidence; boundary vs verity (this verifies the run; verity hardens the tests).

- [ ] **Step 2: Validate**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/verification-before-completion "[Foundation]"`
Expected: `PASS frontmatter verification-before-completion`

- [ ] **Step 3: Commit**

```bash
git add engineering/skills/verification-before-completion/
git commit -m "feat(engineering): author verification-before-completion foundation"
```

---

### Task 4: `dispatching-parallel-agents`

**Files:**
- Create: `engineering/skills/dispatching-parallel-agents/SKILL.md`

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: dispatching-parallel-agents
description: "[Foundation] Fan out 2+ genuinely independent tasks with no shared state to parallel agents and synthesize their results. Use when subtasks do not depend on each other's output. Distinct from executing-plans' plan-scoped subagent mode; a general primitive. Model-invoked; no command."
---
```
Body (original, §9) covers: announce line; the independence precondition (no shared mutable state); how to split, dispatch, and synthesize; boundary vs `executing-plans`' plan-scoped mode.

- [ ] **Step 2: Validate**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/dispatching-parallel-agents "[Foundation]"`
Expected: `PASS frontmatter dispatching-parallel-agents`

- [ ] **Step 3: Commit**

```bash
git add engineering/skills/dispatching-parallel-agents/
git commit -m "feat(engineering): author dispatching-parallel-agents foundation"
```

---

### Task 5: `writing-skills` — the meta-skill

**Files:**
- Create: `engineering/skills/writing-skills/SKILL.md`

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: writing-skills
description: "[Foundation] Author, edit, and verify plugin skills — frontmatter shape, narrow-guarantee house style, group tags, and companion files. Use when adding or revising a skill in this plugin. Keeps the plugin self-extending. Model-invoked; no command."
---
```
Body (original, §9) covers: announce line; the house style (narrow guarantee + explicit non-guarantees per skill); frontmatter rules (`name` matches dir, `description` opens with the `[Group]` tag for process-tied skills, none for cross-cutting); validate with `tests/frontmatter.sh`; how these skills are living works that diverge over time (§9).

- [ ] **Step 2: Validate + confirm it documents the tag convention**

Run:
```bash
sh engineering/tests/frontmatter.sh engineering/skills/writing-skills "[Foundation]" && \
grep -qi "group" engineering/skills/writing-skills/SKILL.md && echo ok
```
Expected: `PASS frontmatter writing-skills` then `ok`

- [ ] **Step 3: Commit**

```bash
git add engineering/skills/writing-skills/
git commit -m "feat(engineering): author writing-skills meta-skill"
```

---

### Task 6: `using-skills` — skill-discovery discipline

**Files:**
- Create: `engineering/skills/using-skills/SKILL.md`

**Interfaces:**
- Consumes: named by the entrance-bootstrap hook (Plan 01) — `hook.sh` asserts `using-skills` appears in the injected context.

- [ ] **Step 1: Create `SKILL.md` with tagged frontmatter**

Frontmatter (exact):
```markdown
---
name: using-skills
description: "[Foundation] Find and invoke the right skill before acting — including before clarifying questions or exploring code. Use at the start of any task. Dashworthy's own skill-discovery discipline (not superpowers). Model-invoked; no command."
---
```
Body (original, §9; NOT a copy of using-superpowers — dashworthy's own) covers: announce line; invoke the relevant skill before responding/acting; how to pick when several apply (process skills set the approach, then implementation skills); the red-flag rationalizations to reject; that this is dashworthy's own discipline.

- [ ] **Step 2: Validate + confirm it is not self-identifying as superpowers**

Run:
```bash
sh engineering/tests/frontmatter.sh engineering/skills/using-skills "[Foundation]" && \
! grep -qi "using-superpowers\|you have superpowers" engineering/skills/using-skills/SKILL.md && echo ok
```
Expected: `PASS frontmatter using-skills` then `ok`

- [ ] **Step 3: Commit**

```bash
git add engineering/skills/using-skills/
git commit -m "feat(engineering): author using-skills discovery discipline"
```

---

### Task 7: The three productivity commands (pure commands, no skill entry)

**Files:**
- Create: `engineering/commands/handoff.md`
- Create: `engineering/commands/to-signal.md`
- Create: `engineering/commands/wait-what.md`

**Interfaces:**
- Produces: `/handoff`, `/to-signal`, `/wait-what`. No skills — the whole workflow lives in each command (§5.2).

- [ ] **Step 1: Create `commands/handoff.md`** — original (§9). `argument-hint: "What will the next session be used for?"`. Workflow: compact the conversation into a handoff doc written to the OS temp dir (ephemeral, deliberately not a repo artifact); include a **suggested-skills** section referencing `engineering:` skills; **redact secrets**; reference existing artifacts under `docs/dashworthy/engineering/specs|plans/`, `CONTEXT.md`, `docs/adr/` rather than duplicating them.

- [ ] **Step 2: Create `commands/to-signal.md`** — original (§9). Turn a decision the user cannot answer into a questionnaire for someone else; write `to-signal-<slug>.md` in the current directory; the answers feed back into discovery (the pairing with `signal` that gives it its name).

- [ ] **Step 3: Create `commands/wait-what.md`** — original (§9). Comms repair: re-pitch a message that did not land; read `CONTEXT.md`/`CONTEXT-MAP.md` (D5); write nothing; keep the ASD-STE100 Simplified-Technical-English framing.

- [ ] **Step 4: Verify the three commands exist, reference `engineering:` (handoff), and are pure (no companion skills)**

Run:
```bash
for c in handoff to-signal wait-what; do test -f "engineering/commands/$c.md" || echo "MISSING $c"; done
grep -q "engineering:" engineering/commands/handoff.md || echo "handoff must reference engineering: skills"
test ! -d engineering/skills/handoff && test ! -d engineering/skills/to-signal && test ! -d engineering/skills/wait-what && echo "pure-ok"
grep -qi "redact" engineering/commands/handoff.md || echo "handoff must redact secrets"
echo done
```
Expected: `pure-ok` then `done`, with no `MISSING`/error lines.

- [ ] **Step 5: Commit**

```bash
git add engineering/commands/handoff.md engineering/commands/to-signal.md engineering/commands/wait-what.md
git commit -m "feat(engineering): author productivity commands (handoff, to-signal, wait-what)"
```

---

### Task 8: Marketplace cutover — single entry + root README deprecation

**Files:**
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md` (root)

**Interfaces:**
- Consumes: the `engineering` entry already added in Plan 01.
- Produces: a marketplace listing only `engineering`; a root README built around the pipeline.

- [ ] **Step 1: Rewrite `marketplace.json` to a single entry**

Replace the `plugins` array so it contains only the `engineering` object (drop `signal`, `verity`, `vernacular`). Keep the marketplace `name`/`description`/`owner`. Final `plugins`:
```json
"plugins": [
  {
    "name": "engineering",
    "description": "Full software-development pipeline: discovery/triage, design dialogue, spec, plan, TDD build, test hardening, docs hardening. File-based, no tracker.",
    "version": "0.1.0",
    "source": "./engineering",
    "author": { "name": "Andrew Leach", "email": "andrew@leachcreative.com" }
  }
]
```

- [ ] **Step 2: Verify the manifest now lists only `engineering`**

Run:
```bash
python3 -c "import json;d=json.load(open('.claude-plugin/marketplace.json'));n=[p['name'] for p in d['plugins']];assert n==['engineering'],n;print('ok',n)"
```
Expected: `ok ['engineering']`

- [ ] **Step 3: Rewrite the root `README.md`**

Rewrite around the single pipeline plugin. Required content:
- Marketplace intro + `add` command.
- **One install line:** `/plugin install engineering@dashworthy`.
- A pipeline overview (entrances → brainstorming → to-spec → plan → build → harden → document) and the **non-guarantees** (mirroring spec §10: no tracker; CONTEXT/ADR optional; Tier-2 disposable; flat skills).
- A **Deprecation** section (verbatim intent from §8):
  > `signal`, `verity`, and `vernacular` are now phases of the `engineering` plugin. The old install commands (`/plugin install signal@dashworthy`, etc.) are deprecated; install `engineering@dashworthy` instead. Existing installs keep working until reinstall.
- A **transition note** (G5): during superpowers removal, some `engineering:` skill names coexist with `superpowers:` counterparts; namespacing keeps them distinct.

- [ ] **Step 4: Verify the README deprecation + single-install**

Run:
```bash
grep -qi "engineering@dashworthy" README.md && \
grep -qi "deprecat" README.md && \
grep -q "signal" README.md && grep -q "verity" README.md && grep -q "vernacular" README.md && echo ok
```
Expected: `ok`

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "chore(engineering): cut marketplace over to single engineering plugin"
```

---

### Task 9: Delete the absorbed top-level plugin directories

**Files:**
- Delete: `signal/`, `verity/`, `vernacular/`

- [ ] **Step 1: Pre-flight — confirm each old dir's content is present under `engineering/`**

Run:
```bash
for s in conducting-discovery interrogating-requirements expanding-scope sequencing-requirements; do test -d "engineering/skills/$s" || echo "MISSING signal skill $s"; done
for s in conducting-test-hardening auditing-test-gaps verifying-test-integrity writing-tests-from-brief; do test -d "engineering/skills/$s" || echo "MISSING verity skill $s"; done
for s in clarifying-docblocks rewriting-docblock-prose verifying-docblock-claims; do test -d "engineering/skills/$s" || echo "MISSING vernacular skill $s"; done
test -f engineering/commands/signal.md && test -f engineering/commands/vernacular.md && test -f engineering/scripts/reconcile.py && echo "content-present"
```
Expected: `content-present` with no `MISSING` lines. **Do not proceed if anything is missing.**

- [ ] **Step 2: Delete the old directories**

```bash
git rm -r signal verity vernacular
```

- [ ] **Step 3: Verify they are gone and no reference remains**

Run:
```bash
test ! -d signal && test ! -d verity && test ! -d vernacular && echo "removed"
grep -rn "\./signal\|\./verity\|\./vernacular" .claude-plugin/marketplace.json && echo "STALE SOURCE REF" || echo "no-stale-source"
```
Expected: `removed` then `no-stale-source`

- [ ] **Step 4: Commit**

```bash
git commit -m "chore(engineering): remove absorbed signal/verity/vernacular directories"
```

---

### Task 10: Final acceptance — the §13.16 checklist

**Files:**
- Create: `engineering/tests/acceptance.sh`

**Interfaces:**
- Consumes: every prior test (`suite.sh` from Plan 01, `plan02.sh`, `plan03.sh`) plus new whole-plugin assertions.

- [ ] **Step 1: Write the acceptance suite**

Create `engineering/tests/acceptance.sh`:
```sh
#!/bin/sh
# Final acceptance for the engineering plugin — the spec's §13.16 checklist.
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
eng=$(CDPATH= cd "$d/.." && pwd)
root=$(CDPATH= cd "$eng/.." && pwd)
fail=0

# 1. Prior gates all green (non-live).
sh "$d/suite.sh"
sh "$d/plan02.sh"
sh "$d/plan03.sh"

# 2. Nine commands resolve.
for c in signal triage vernacular improve-codebase-architecture implement wizard handoff to-signal wait-what; do
  test -f "$eng/commands/$c.md" || { echo "FAIL: missing command /$c"; fail=1; }
done

# 3. Every skill frontmatter valid; process-tied ones carry a [Group] tag, cross-cutting ones do not.
tagged="conducting-discovery:[Discovery] interrogating-requirements:[Discovery] expanding-scope:[Discovery] sequencing-requirements:[Discovery] to-spec:[Discovery] domain-modeling:[Discovery] triage:[Triage] brainstorming:[Design] codebase-design:[Design] improve-codebase-architecture:[Design] prototype:[Design] writing-plans:[Planning] executing-plans:[Planning] tdd:[Build] diagnosing-bugs:[Build] code-review:[Build] conducting-test-hardening:[Test hardening] auditing-test-gaps:[Test hardening] verifying-test-integrity:[Test hardening] writing-tests-from-brief:[Test hardening] clarifying-docblocks:[Docs] rewriting-docblock-prose:[Docs] verifying-docblock-claims:[Docs] using-git-worktrees:[Foundation] finishing-a-development-branch:[Foundation] verification-before-completion:[Foundation] dispatching-parallel-agents:[Foundation] writing-skills:[Foundation] using-skills:[Foundation]"
for pair in $tagged; do
  name=${pair%%:*}; tag=${pair#*:}
  sh "$d/frontmatter.sh" "$eng/skills/$name" "$tag" >/dev/null || { echo "FAIL: $name frontmatter/tag"; fail=1; }
done
for name in wizard research resolving-merge-conflicts; do
  sh "$d/frontmatter.sh" "$eng/skills/$name" >/dev/null || { echo "FAIL: $name frontmatter"; fail=1; }
  python3 -c "import re,sys;t=open(sys.argv[1]).read();m=re.search(r'^description:\s*\"?(.)',t,re.M);assert m and m.group(1)!='[',sys.argv[1]" "$eng/skills/$name/SKILL.md" || { echo "FAIL: $name must not be tagged"; fail=1; }
done

# 4. skills/README.md lists every skill dir.
for skdir in "$eng"/skills/*/; do
  n=$(basename "$skdir")
  grep -q "\`$n\`" "$eng/skills/README.md" || { echo "FAIL: skills/README.md missing $n"; fail=1; }
done

# 5. Entrance-bootstrap hook fires and names both entrances (and no verity reminder).
sh "$d/hook.sh" >/dev/null || { echo "FAIL: hook"; fail=1; }
if grep -rq "Verity applies once implementation work is finished" "$eng/hooks" 2>/dev/null; then echo "FAIL: retired verity reminder present"; fail=1; fi

# 6. to-spec is the sole Tier-1 writer; both entrances reach it.
grep -q "docs/dashworthy/engineering/specs/" "$eng/skills/to-spec/SKILL.md" || { echo "FAIL: to-spec spec path"; fail=1; }
grep -rq "to-spec" "$eng/skills/conducting-discovery" "$eng/skills/sequencing-requirements" || { echo "FAIL: signal must reach to-spec"; fail=1; }
grep -rq "to-spec" "$eng/skills/triage" || { echo "FAIL: triage must reach to-spec"; fail=1; }

# 7. verity is a planned step, not a session-start hook.
grep -q "conducting-test-hardening" "$eng/skills/writing-plans/SKILL.md" || { echo "FAIL: writing-plans must bake hardening"; fail=1; }
grep -q "conducting-test-hardening" "$eng/skills/finishing-a-development-branch/SKILL.md" || { echo "FAIL: finish-time hardening net missing"; fail=1; }

# 8. No dangling cross-plugin namespaces or Tier-2 paths anywhere in engineering/.
if grep -rn "signal:\|verity:\|vernacular:\|\.signal/\|\.verity\|\.vernacular" "$eng/skills" "$eng/commands"; then echo "FAIL: dangling refs"; fail=1; fi

# 9. .engineering/ gitignored.
grep -qxF '.engineering/' "$root/.gitignore" || { echo "FAIL: .engineering not gitignored"; fail=1; }

# 10. No NOTICE / attribution anywhere in the plugin.
test ! -f "$eng/NOTICE" || { echo "FAIL: NOTICE file exists"; fail=1; }
if grep -rIn "Matt Pocock\|mattpocock\|reproduced from\|copied from superpowers" "$eng" 2>/dev/null; then echo "FAIL: attribution leak"; fail=1; fi

# 11. Old directories are gone.
for old in signal verity vernacular; do test ! -d "$root/$old" || { echo "FAIL: $old/ still present"; fail=1; }; done

[ "$fail" = 0 ] && echo "ENGINEERING ACCEPTANCE: ALL CHECKS PASS" || { echo "ACCEPTANCE FAILED"; exit 1; }
```

- [ ] **Step 2: Run it**

Run: `sh engineering/tests/acceptance.sh`
Expected: ends with `ENGINEERING ACCEPTANCE: ALL CHECKS PASS`

- [ ] **Step 3: Run the run-context sharing proof (G7) explicitly**

Run: `sh engineering/tests/run-context.sh`
Expected: `PASS run-context.sh (run=...)` — two phases in one session share a `<run>`.

- [ ] **Step 4: Run the live vernacular/e2e harness (CI/manual)**

Run (manual/CI): `sh engineering/tests/validate.sh && sh engineering/tests/e2e.sh`
Expected: `validate.sh` fully PASS now that the root README lists `engineering` (the Plan-01 expected-fail is resolved by Task 8); `e2e.sh` PASS or INCONCLUSIVE per environment. Do not gate the commit on the live e2e.

- [ ] **Step 5: Commit**

```bash
git add engineering/tests/acceptance.sh
git commit -m "test(engineering): final acceptance suite (§13.16 checklist)"
```

---

## Self-Review

**Spec coverage (build-sequence steps 12–16):**
- §13.12 six foundations, `finishing-a-development-branch` carries the verity finish-time net → Tasks 1–6. ✓
- §13.13 three productivity pure commands → Task 7. ✓
- §13.14 marketplace single entry + root README deprecation → Task 8. ✓
- §13.15 delete absorbed dirs → Task 9 (with pre-flight guard). ✓
- §13.16 full acceptance checklist → Task 10 (`acceptance.sh` maps 1:1 to the checklist items). ✓
- D15 verity planned-step + finish-time net (no session-start hook) → Tasks 2, 10 checks 5 & 7. ✓
- §6.5 `using-skills` is dashworthy's own, not using-superpowers → Task 6 assertion. ✓
- §9 no NOTICE/attribution → Task 10 check 10. ✓

**Placeholder scan:** none — each foundation gives exact frontmatter + a spec-driven body contract + verification; the cutover tasks show exact JSON/README content requirements and grep checks; the acceptance suite is fully written, not sketched.

**Type/interface consistency:** the acceptance `tagged` list matches the group tags assigned across Plans 01–04 and the `skills/README.md` index. `finishing-a-development-branch` and `writing-plans`/`executing-plans` all invoke `engineering:conducting-test-hardening` (absorbed in Plan 01). `using-skills` is the name the Plan-01 `hook.sh` asserts. The marketplace `engineering` entry rewritten here matches the one added in Plan 01 (name/source/version). Task 9's pre-flight guards deletion on the absorbed content actually existing.

**Plan-set completeness:** Plans 01–04 cover build-sequence steps 1–16 with no gap. After Task 10 passes, the `engineering` plugin is the marketplace's sole plugin and every §13.16 acceptance item is proven green.
