# Engineering Plugin — Plan 01: Foundation & Absorption Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the `engineering` plugin skeleton and absorb the three existing dashworthy plugins (`signal`, `vernacular`, `verity`) into it — re-namespaced, path-redirected, and green — plus the shared `to-spec` spec writer and the run-context mechanism.

**Architecture:** A single Claude Code plugin at `engineering/` in the `dashworthy` marketplace. This plan builds the package skeleton (manifest, README, one `SessionStart` entrance-bootstrap hook, a shared run-context helper, a grouped skills index), authors `to-spec` (the sole writer of Tier-1 specs), and **copies** each existing plugin's skills/commands/scripts/tests into `engineering/`, rewriting internal skill namespaces (`signal:`/`verity:`/`vernacular:` → `engineering:`) and Tier-2 scratch paths (`.signal/`,`.verity/`,`.vernacular/` → `.engineering/<run>/<name>/`). Originals stay in place and installable until the cutover (a later plan), so every intermediate state is coherent.

**Tech Stack:** Markdown skills/commands (Claude Code plugin format), POSIX `sh` hooks/scripts, Python 3 for `reconcile.py` and JSON validation, `git` for version control. No runtime dependencies added.

## Global Constraints

Project-wide requirements — every task's requirements implicitly include these. Values copied verbatim from `docs/dashworthy/engineering/specs/2026-08-21-engineering-plugin-design.md`.

- **Plugin name:** `engineering`. **Marketplace:** `dashworthy`. Skill IDs are addressed `engineering:<skill>` — never `dashworthy:*`. (D9, §6.1)
- **Tier-1 (committed):** specs → `docs/dashworthy/engineering/specs/`; plans → `docs/dashworthy/engineering/plans/`. Naming `YYYY-MM-DD-<topic>.md`. (D13, §5.1)
- **Tier-2 (gitignored scratch):** single root `.engineering/<run>/<name>/`, run-first. `<run>` = `<YYYY-MM-DD>-<slug>`. Shared pointer `.engineering/.current-run` holds the active `<run>`. (D13, §5.1, §5.3, G7)
- **`to-spec` is the ONLY writer of Tier-1 specs.** Entrances hand it their material; it renders the spec. (D17, §5.1)
- **Skills stay flat** under `skills/` (platform scans one level deep). Every process-tied skill's frontmatter `description` **opens with a `[Group]` tag** — `[Discovery]`, `[Triage]`, `[Design]`, `[Build]`, `[Planning]`, `[Test hardening]`, `[Docs]`, `[Foundation]`. Cross-cutting skills carry no tag. (D18, §5.6)
- **One hook, by choice:** a single `SessionStart` entrance bootstrap. Verity's session-start reminder is **retired** — do not port it. (D15, D16, §5.5)
- **Originality:** all text is dashworthy's own. **No attribution, no NOTICE, no credit lines anywhere.** (D8, §9)
- **Absorb by COPY, not move.** Leave `signal/`, `verity/`, `vernacular/` and their marketplace entries intact and functional; the cutover plan deletes them. (§8, §13 steps 13–14)

---

### Task 1: Plugin skeleton — manifest, READMEs, gitignore, marketplace entry

**Files:**
- Create: `engineering/.claude-plugin/plugin.json`
- Create: `engineering/README.md`
- Create: `engineering/skills/README.md`
- Modify: `.gitignore` (add `.engineering/`)
- Modify: `.claude-plugin/marketplace.json` (add the `engineering` entry alongside the existing three)
- Test: `engineering/tests/validate.sh` (created in Task 7; for now validate inline with the commands shown)

**Interfaces:**
- Produces: the `engineering` plugin root and marketplace registration every later task builds on.

- [ ] **Step 1: Create the plugin manifest**

Create `engineering/.claude-plugin/plugin.json`:

```json
{
  "name": "engineering",
  "description": "Full software-development pipeline: discover or triage, shape the design, spec, plan, build with TDD, harden tests, and harden docs — file-based, no tracker.",
  "version": "0.1.0",
  "author": {
    "name": "Andrew Leach",
    "email": "andrew@leachcreative.com"
  },
  "license": "MIT",
  "keywords": [
    "sdlc",
    "discovery",
    "triage",
    "design",
    "planning",
    "tdd",
    "code-review",
    "test-hardening",
    "documentation",
    "subagents"
  ]
}
```

- [ ] **Step 2: Verify the manifest is well-formed JSON**

Run: `python3 -c "import json;d=json.load(open('engineering/.claude-plugin/plugin.json'));assert d['name']=='engineering';print('ok')"`
Expected: `ok`

- [ ] **Step 3: Create the plugin README skeleton**

Create `engineering/README.md`:

```markdown
# engineering

A single-plugin software-development pipeline for the `dashworthy` marketplace.

Two entrances open the work — `/signal` (discovery, for a feature or vague ask) and
`/triage` (problem isolation, for a reported defect). Both pass through a design-dialogue
approval gate and produce one spec, then flow through planning, TDD build, test hardening,
and documentation hardening. All artifacts are files; there is no issue-tracker integration.

<!-- Pipeline diagram, phase table, and non-guarantees are filled in at the cutover plan,
     mirroring the spec's End-to-end flow section. -->

## Install

```
/plugin marketplace add https://github.com/dashworthy/development-skills
/plugin install engineering@dashworthy
```

## License

MIT. See [LICENSE](../LICENSE).
```

- [ ] **Step 4: Create the grouped skills index skeleton**

Create `engineering/skills/README.md`:

```markdown
# Skills, by process group

Skills live flat in this directory (the plugin loader scans one level deep). This index is the
human map of which skill belongs to which process. Each process-tied skill's `description` also
opens with the matching `[Group]` tag.

| Group | Skills |
|---|---|
| Discovery | `conducting-discovery`, `interrogating-requirements`, `expanding-scope`, `sequencing-requirements`, `to-spec`, `domain-modeling` |
| Triage | `triage` |
| Design | `brainstorming`, `codebase-design`, `improve-codebase-architecture`, `prototype` |
| Planning | `writing-plans`, `executing-plans` |
| Build | `tdd`, `diagnosing-bugs`, `code-review` |
| Test hardening | `conducting-test-hardening`, `auditing-test-gaps`, `verifying-test-integrity`, `writing-tests-from-brief` |
| Docs | `clarifying-docblocks`, `rewriting-docblock-prose`, `verifying-docblock-claims` |
| Foundation | `using-git-worktrees`, `finishing-a-development-branch`, `verification-before-completion`, `dispatching-parallel-agents`, `writing-skills`, `using-skills` |
| Cross-cutting (no tag) | `wizard`, `research`, `resolving-merge-conflicts` |

Skills authored in later plans are added to this table as they land.
```

- [ ] **Step 5: Gitignore the Tier-2 scratch root**

Add the line `.engineering/` to `.gitignore` (create the file if absent). Verify:

Run: `grep -qxF '.engineering/' .gitignore && echo ok`
Expected: `ok`

- [ ] **Step 6: Register `engineering` in the marketplace (alongside the existing three)**

Add this object to the `plugins` array in `.claude-plugin/marketplace.json` (do NOT remove `signal`/`verity`/`vernacular` — the cutover plan does that):

```json
{
  "name": "engineering",
  "description": "Full software-development pipeline: discovery/triage, design dialogue, spec, plan, TDD build, test hardening, docs hardening. File-based, no tracker.",
  "version": "0.1.0",
  "source": "./engineering",
  "author": {
    "name": "Andrew Leach",
    "email": "andrew@leachcreative.com"
  }
}
```

- [ ] **Step 7: Verify the marketplace still parses and now lists four plugins**

Run:
```bash
python3 -c "import json;d=json.load(open('.claude-plugin/marketplace.json'));n=[p['name'] for p in d['plugins']];assert 'engineering' in n and 'signal' in n and 'verity' in n and 'vernacular' in n, n;e=[p for p in d['plugins'] if p['name']=='engineering'][0];assert e['source']=='./engineering';print('ok',n)"
```
Expected: `ok ['signal', 'verity', 'vernacular', 'engineering']`

- [ ] **Step 8: Commit**

```bash
git add engineering/.claude-plugin/plugin.json engineering/README.md engineering/skills/README.md .gitignore .claude-plugin/marketplace.json
git commit -m "feat(engineering): scaffold plugin skeleton and register in marketplace"
```

---

### Task 2: The `SessionStart` entrance-bootstrap hook

**Files:**
- Create: `engineering/hooks/hooks.json`
- Create: `engineering/hooks/session-start.sh`

**Interfaces:**
- Produces: a hook that injects `SessionStart` `additionalContext` naming both entrances. No file writes, no git, no `jq`.

- [ ] **Step 1: Write the failing test**

Create `engineering/tests/hook.sh`:

```sh
#!/bin/sh
# Verifies the entrance-bootstrap hook emits valid JSON that names both entrances
# and points at using-skills. No install required.
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
OUT=$(CLAUDE_PLUGIN_ROOT="$ROOT/engineering" sh "$ROOT/engineering/hooks/session-start.sh") || { echo "FAIL: hook exited non-zero"; exit 1; }
printf '%s' "$OUT" | python3 -c '
import json,sys
d=json.load(sys.stdin)
c=d["hookSpecificOutput"]["additionalContext"]
assert d["hookSpecificOutput"]["hookEventName"]=="SessionStart", d
assert "/signal" in c and "/triage" in c, "must name both entrances"
assert "using-skills" in c, "must point at using-skills"
print("ok")
' || { echo "FAIL: hook output invalid"; exit 1; }
echo "PASS hook.sh"
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `sh engineering/tests/hook.sh`
Expected: FAIL (`session-start.sh` does not exist yet)

- [ ] **Step 3: Write the hook config**

Create `engineering/hooks/hooks.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "sh \"${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh\""
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 4: Write the hook script**

Create `engineering/hooks/session-start.sh`:

```sh
#!/bin/sh
# SessionStart hook for the engineering plugin: the entrance bootstrap.
#
# Puts the two front doors in front of the model at the start of every conversation,
# the way superpowers surfaces its process skills. Injects guidance only; it never
# blocks, never touches git, never reads or writes a file, and does not depend on jq.

message='Engineering pipeline is available. Before building from a request, pick the entrance:\n- A feature or a vague ask: run `/signal` (discovery to a brief).\n- A reported bug or defect: run `/triage` (isolate with minimal effort).\nEither way, invoke the right skill before acting (see the `using-skills` foundation). Do not jump straight to code on non-trivial work.'

printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$message"

exit 0
```

- [ ] **Step 5: Run the test to confirm it passes**

Run: `sh engineering/tests/hook.sh`
Expected: `PASS hook.sh`

- [ ] **Step 6: Commit**

```bash
git add engineering/hooks/hooks.json engineering/hooks/session-start.sh engineering/tests/hook.sh
git commit -m "feat(engineering): add SessionStart entrance-bootstrap hook"
```

---

### Task 3: The run-context helper (shared read-or-create pointer)

**Files:**
- Create: `engineering/scripts/run-context.sh`
- Create: `engineering/tests/run-context.sh`

**Interfaces:**
- Produces: `run-context.sh` — echoes the absolute path of the current run's `<name>` scratch dir, creating the run and the `.engineering/.current-run` pointer if absent. Signature: `run-context.sh <name> [slug]` → prints `.engineering/<run>/<name>/`. Every absorbed and authored skill calls this so a session shares one `<run>` (G7).

- [ ] **Step 1: Write the failing test**

Create `engineering/tests/run-context.sh`:

```sh
#!/bin/sh
# Two invocations in one session must resolve to the SAME <run> (G7).
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
SCRIPT="$ROOT/engineering/scripts/run-context.sh"
TMP=$(mktemp -d)
cd "$TMP"
A=$(sh "$SCRIPT" signal my-feature)
B=$(sh "$SCRIPT" vernacular)          # no slug: must join the run A created
runA=$(basename "$(dirname "$A")")
runB=$(basename "$(dirname "$B")")
[ "$runA" = "$runB" ] || { echo "FAIL: runs differ ($runA vs $runB)"; exit 1; }
[ -f "$TMP/.engineering/.current-run" ] || { echo "FAIL: pointer not written"; exit 1; }
[ -d "$A" ] && [ -d "$B" ] || { echo "FAIL: scratch dirs not created"; exit 1; }
case "$runA" in [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*) : ;; *) echo "FAIL: run id malformed: $runA"; exit 1;; esac
echo "PASS run-context.sh (run=$runA)"
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `sh engineering/tests/run-context.sh`
Expected: FAIL (`run-context.sh` does not exist)

- [ ] **Step 3: Write the helper**

Create `engineering/scripts/run-context.sh`:

```sh
#!/bin/sh
# Resolve (creating if needed) the Tier-2 scratch dir for one phase of the current run.
#
# Usage: run-context.sh <name> [slug]
#   <name>  phase subdir, e.g. signal | triage | verity | vernacular | implement
#   [slug]  short kebab name for a NEW run; ignored if a run is already active.
#
# The active run id lives in .engineering/.current-run as "<YYYY-MM-DD>-<slug>".
# The first caller in a session creates it; later callers join it. Prints the
# absolute path of .engineering/<run>/<name>/ and ensures it exists.
set -e

name=$1
slug=$2
[ -n "$name" ] || { echo "run-context.sh: missing <name>" >&2; exit 2; }

root=".engineering"
pointer="$root/.current-run"
mkdir -p "$root"

if [ -f "$pointer" ]; then
  run=$(cat "$pointer")
else
  date_part=$(date +%Y-%m-%d)
  if [ -z "$slug" ]; then slug="run"; fi
  # sanitise slug to kebab: lowercase, non-alnum -> '-', squeeze, trim.
  slug=$(printf '%s' "$slug" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\{1,\}/-/g; s/^-//; s/-$//')
  [ -n "$slug" ] || slug="run"
  run="$date_part-$slug"
  printf '%s' "$run" > "$pointer"
fi

dir="$root/$run/$name"
mkdir -p "$dir"
# Print absolute path.
CDPATH= cd "$dir" && pwd
```

- [ ] **Step 4: Run the test to confirm it passes**

Run: `sh engineering/tests/run-context.sh`
Expected: `PASS run-context.sh (run=YYYY-MM-DD-my-feature)`

- [ ] **Step 5: Commit**

```bash
git add engineering/scripts/run-context.sh engineering/tests/run-context.sh
git commit -m "feat(engineering): add shared run-context pointer helper (G7)"
```

---

### Task 4: Author `to-spec` — the shared spec writer

**Files:**
- Create: `engineering/skills/to-spec/SKILL.md`
- Create: `engineering/skills/to-spec/SPEC-FORMAT.md`
- Test: `engineering/tests/frontmatter.sh` (created here; reused by later tasks)

**Interfaces:**
- Consumes: an entrance's accumulated material — a `signal` discovery brief (Tier-2) or a `triage` isolation record (Tier-2) — supplied as a path or inline.
- Produces: one Tier-1 spec at `docs/dashworthy/engineering/specs/<YYYY-MM-DD>-<topic>.md`, in the format defined by `SPEC-FORMAT.md`. This is the only skill that writes Tier-1 specs.

- [ ] **Step 1: Write the frontmatter validator (the reusable test)**

Create `engineering/tests/frontmatter.sh`:

```sh
#!/bin/sh
# Validate a skill's YAML frontmatter: `name` present and matches its dir; `description`
# present; and, if a [Group] tag is required, the description opens with one.
# Usage: frontmatter.sh <skill-dir> [required-group-tag]
set -e
dir=$1; want_tag=$2
skill=$(basename "$dir")
f="$dir/SKILL.md"
[ -f "$f" ] || { echo "FAIL: no SKILL.md in $dir"; exit 1; }
python3 - "$f" "$skill" "$want_tag" <<'PY'
import sys,re
f,skill,want=sys.argv[1],sys.argv[2],sys.argv[3]
t=open(f,encoding="utf-8").read()
m=re.match(r'^---\n(.*?)\n---\n', t, re.S)
assert m, "no frontmatter block"
fm=m.group(1)
name=re.search(r'^name:\s*(.+)$', fm, re.M)
desc=re.search(r'^description:\s*(.+)$', fm, re.M)
def unquote(s):
    s = s.strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in "\"'":
        s = s[1:-1]
    return s
name_v = unquote(name.group(1)) if name else None
desc_v = unquote(desc.group(1)) if desc else None
assert name and name_v == skill, f"name must equal dir '{skill}'"
assert desc and desc_v, "description required"
if want:
    assert desc_v.startswith(want), f"description must open with {want}"
print("ok",skill)
PY
echo "PASS frontmatter $skill"
```

- [ ] **Step 2: Run it against `to-spec` to confirm it fails**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/to-spec "[Discovery]"`
Expected: FAIL (`no SKILL.md in engineering/skills/to-spec`)

- [ ] **Step 3: Write `SPEC-FORMAT.md` (the spec template `to-spec` fills)**

Create `engineering/skills/to-spec/SPEC-FORMAT.md`:

```markdown
# Spec format

`to-spec` renders every spec to this shape, at
`docs/dashworthy/engineering/specs/<YYYY-MM-DD>-<topic>.md`. One format for both entrances.

    # <Title> — spec

    **Date:** <YYYY-MM-DD>
    **Author:** <name>
    **Status:** Draft | Approved
    **Origin:** signal (discovery) | triage (<issue ref or one-line problem>)

    ## 1. Problem
    What we are solving and why now. From a signal brief §1, or a triage problem statement.

    ## 2. Users & stakeholders
    Who is affected; who decides.

    ## 3. Goals & success criteria
    Observable outcomes. Each criterion is checkable.

    ## 4. Constraints
    Hard limits: platforms, versions, dependencies, deadlines, must-not-break.

    ## 5. Scope
    **In:** the committed work. **Out (non-goals):** each with a one-line reason.
    **Deferred:** parked, with the trigger that would revive it.

    ## 6. Approach (from the design dialogue)
    The approved approach and the alternatives weighed against it (from `brainstorming`).
    For a triage-origin fix, the chosen fix strategy and why the smaller options were rejected.

    ## 7. Existing context
    Relevant modules, `CONTEXT.md` terms, ADRs. What the work touches.

    ## 8. Open questions
    Anything unresolved that does not block starting. Empty is fine.

Rules:
- Never invent content the source material does not support; mark unknowns in §8.
- A triage-origin spec still fills every section; §1 is the reproduced problem, §6 the fix approach.
- The topic slug matches the run slug where possible (correspondence, not coupling).
```

- [ ] **Step 4: Write `to-spec/SKILL.md`**

Create `engineering/skills/to-spec/SKILL.md` with this exact frontmatter, then a body covering the sections listed below (write dashworthy-original prose — no text copied from any source, §9):

```markdown
---
name: to-spec
description: "[Discovery] The single writer of Tier-1 specs. Given an entrance's accumulated material — a signal discovery brief or a triage isolation record, by path or inline — render the standard spec document to docs/dashworthy/engineering/specs/. Invoked by conducting-discovery at the end of signal, and by triage when a fix is spec-worthy; not a general-purpose writer and does not self-trigger on arbitrary requests."
---
```

Body must contain these sections (announce the skill at start, per house style):

1. **Announce** — `Using the to-spec skill to write the spec.`
2. **Inputs** — accept either a path to Tier-2 material (`.engineering/<run>/signal/brief.md` or `.engineering/<run>/triage/…`) or inline material; refuse if neither is present.
3. **Where it writes** — Tier-1 only: `docs/dashworthy/engineering/specs/<YYYY-MM-DD>-<topic>.md`. Derive `<topic>` from the run slug when available (`.engineering/.current-run`), else from the title. Never write to `.engineering/` (that is the entrances' Tier-2).
4. **How it renders** — follow `SPEC-FORMAT.md` (reference it, do not restate it). Map a signal brief §1–§8 onto the format; map a triage record onto it with §1 = reproduced problem and §6 = fix approach.
5. **What it must not do** — not design (that is `brainstorming`), not plan (that is `writing-plans`), not interrogate (that is `signal`). It serializes an already-shaped design; if the material is thin, it names the gaps in §8 rather than inventing.
6. **Handoff** — on write, print the spec path and hand back to the caller (which proceeds to `writing-plans`).

- [ ] **Step 5: Validate `to-spec` frontmatter and the `[Discovery]` tag**

Run: `sh engineering/tests/frontmatter.sh engineering/skills/to-spec "[Discovery]"`
Expected: `PASS frontmatter to-spec`

- [ ] **Step 6: Confirm `to-spec` references `SPEC-FORMAT.md` and writes only Tier-1**

Run:
```bash
grep -q "SPEC-FORMAT.md" engineering/skills/to-spec/SKILL.md && \
grep -q "docs/dashworthy/engineering/specs/" engineering/skills/to-spec/SKILL.md && echo ok
```
Expected: `ok`

- [ ] **Step 7: Commit**

```bash
git add engineering/skills/to-spec/ engineering/tests/frontmatter.sh
git commit -m "feat(engineering): author to-spec, the shared Tier-1 spec writer"
```

---

### Task 5: Absorb `signal` (copy, re-namespace, delegate to `to-spec`)

**Files:**
- Create (copy from `signal/`, then edit): `engineering/skills/{conducting-discovery,interrogating-requirements,expanding-scope,sequencing-requirements}/SKILL.md`, `engineering/commands/signal.md`
- Test: `engineering/tests/absorb-signal.sh`

**Interfaces:**
- Consumes: the run-context helper (Task 3) for its Tier-2 scratch; `to-spec` (Task 4) for the Tier-1 spec.
- Produces: `/signal` under `engineering`, writing its brief to `.engineering/<run>/signal/brief.md` (Tier-2) and delegating the committed spec to `to-spec`.

- [ ] **Step 1: Copy the source files into `engineering/`**

```bash
mkdir -p engineering/commands
for s in conducting-discovery interrogating-requirements expanding-scope sequencing-requirements; do
  mkdir -p "engineering/skills/$s"
  cp "signal/skills/$s/SKILL.md" "engineering/skills/$s/SKILL.md"
done
cp signal/commands/signal.md engineering/commands/signal.md
```

- [ ] **Step 2: Write the failing absorption test**

Create `engineering/tests/absorb-signal.sh`:

```sh
#!/bin/sh
# No stale signal: namespaces or .signal/ paths survive absorption; brief is Tier-2;
# spec-writing is delegated to to-spec.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
if grep -rn "signal:" skills/conducting-discovery skills/interrogating-requirements skills/expanding-scope skills/sequencing-requirements commands/signal.md; then
  echo "FAIL: stale 'signal:' namespace refs"; fail=1; fi
if grep -rn "\.signal/" skills commands/signal.md; then
  echo "FAIL: stale '.signal/' paths"; fail=1; fi
grep -q "engineering:conducting-discovery" commands/signal.md || { echo "FAIL: command must dispatch engineering:conducting-discovery"; fail=1; }
grep -rq "\.engineering/" skills/conducting-discovery/SKILL.md || { echo "FAIL: run dir not redirected to .engineering/"; fail=1; }
grep -rq "to-spec" skills/sequencing-requirements/SKILL.md skills/conducting-discovery/SKILL.md || { echo "FAIL: spec-writing not delegated to to-spec"; fail=1; }
[ "$fail" = 0 ] && echo "PASS absorb-signal.sh" || exit 1
```

- [ ] **Step 3: Run it to confirm it fails**

Run: `sh engineering/tests/absorb-signal.sh`
Expected: FAIL (copied files still carry `signal:` and `.signal/`)

- [ ] **Step 4: Re-namespace every skill and command**

In all four `engineering/skills/*/SKILL.md` and `engineering/commands/signal.md`, replace every `signal:` skill reference with `engineering:` (e.g. `signal:conducting-discovery` → `engineering:conducting-discovery`). Do not change the prose word "signal" where it names the pipeline/product — only the `skill-id:` prefixes.

Run to find every occurrence to edit:
```bash
grep -rn "signal:" engineering/skills engineering/commands/signal.md
```

- [ ] **Step 5: Redirect Tier-2 paths and add the run-context step**

In `engineering/skills/conducting-discovery/SKILL.md`, replace the run-dir convention `.signal/runs/<YYYY-MM-DD>-<slug>/` with `.engineering/<run>/signal/`, and state that the run dir is obtained via `sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" signal <slug>` (Task 3), so signal — the usual first phase — creates `.engineering/.current-run`. Update the same reference in `signal/README`-derived prose inside the skill if present. The brief is now Tier-2 at `.engineering/<run>/signal/brief.md`.

- [ ] **Step 6: Delegate spec-writing to `to-spec`**

In `engineering/skills/sequencing-requirements/SKILL.md` (and the conductor `conducting-discovery/SKILL.md` where it releases the brief), add the final hand-off: once §1–§8 are written to the Tier-2 `brief.md`, invoke `engineering:to-spec` with that brief path to render the committed Tier-1 spec at `docs/dashworthy/engineering/specs/`. Signal no longer writes a spec file itself.

- [ ] **Step 7: Add the `[Discovery]` tag to each description**

Prefix each of the four skills' `description:` value with `[Discovery] ` (keep the existing text after the tag).

- [ ] **Step 8: Validate frontmatter for all four skills**

Run:
```bash
for s in conducting-discovery interrogating-requirements expanding-scope sequencing-requirements; do sh engineering/tests/frontmatter.sh "engineering/skills/$s" "[Discovery]"; done
```
Expected: four `PASS frontmatter <skill>` lines

- [ ] **Step 9: Run the absorption test**

Run: `sh engineering/tests/absorb-signal.sh`
Expected: `PASS absorb-signal.sh`

- [ ] **Step 10: Commit**

```bash
git add engineering/skills/conducting-discovery engineering/skills/interrogating-requirements engineering/skills/expanding-scope engineering/skills/sequencing-requirements engineering/commands/signal.md engineering/tests/absorb-signal.sh
git commit -m "feat(engineering): absorb signal — re-namespace, Tier-2 brief, delegate spec to to-spec"
```

---

### Task 6: Absorb `vernacular` (copy, re-namespace, redirect paths) + keep `reconcile.sh` green

**Files:**
- Create (copy from `vernacular/`, then edit): `engineering/skills/{clarifying-docblocks,rewriting-docblock-prose,verifying-docblock-claims}/` (with `references/`), `engineering/commands/vernacular.md`, `engineering/scripts/reconcile.py`, `engineering/tests/{reconcile.sh,validate.sh,e2e.sh}`
- Test: `engineering/tests/reconcile.sh` (moves with the code; must stay green)

**Interfaces:**
- Consumes: run-context helper for `.engineering/<run>/vernacular/`.
- Produces: `/vernacular` under `engineering`; `reconcile.py` unchanged in behavior.

- [ ] **Step 1: Copy the source tree into `engineering/`**

```bash
cp -R vernacular/skills/clarifying-docblocks engineering/skills/clarifying-docblocks
cp -R vernacular/skills/rewriting-docblock-prose engineering/skills/rewriting-docblock-prose
cp -R vernacular/skills/verifying-docblock-claims engineering/skills/verifying-docblock-claims
cp vernacular/commands/vernacular.md engineering/commands/vernacular.md
mkdir -p engineering/scripts && cp vernacular/scripts/reconcile.py engineering/scripts/reconcile.py
mkdir -p engineering/tests && cp vernacular/tests/reconcile.sh engineering/tests/reconcile.sh
```

- [ ] **Step 2: Point `reconcile.sh` at the new script path and run it (should already pass — it is behavior-only)**

In `engineering/tests/reconcile.sh`, set `SCRIPT="$ROOT/engineering/scripts/reconcile.py"` (was `$ROOT/vernacular/scripts/reconcile.py`), and set `ROOT` to resolve two levels up from the test file.

Run: `sh engineering/tests/reconcile.sh`
Expected: all reconcile unit cases PASS (behavior is identity-independent)

- [ ] **Step 3: Write the failing docblock-path test**

Create `engineering/tests/absorb-vernacular.sh`:

```sh
#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
if grep -rn "\.vernacular" skills commands/vernacular.md; then echo "FAIL: stale .vernacular path"; fail=1; fi
grep -rq "\.engineering/" skills/clarifying-docblocks/SKILL.md || { echo "FAIL: run dir not redirected"; fail=1; }
[ "$fail" = 0 ] && echo "PASS absorb-vernacular.sh" || exit 1
```

- [ ] **Step 4: Run it to confirm it fails**

Run: `sh engineering/tests/absorb-vernacular.sh`
Expected: FAIL (copied files still carry `.vernacular`)

- [ ] **Step 5: Redirect `.vernacular` → `.engineering/<run>/vernacular` everywhere**

In the three skills and their `references/`, and in `commands/vernacular.md`, replace `.vernacular/<YYYY-MM-DD>-<ref>-<suffix>/` and every `.vernacular/<run>/...` with `.engineering/<run>/vernacular/...`, obtaining the run dir via `sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" vernacular` (standalone runs create the pointer; §5.3). Update `clarifying-docblocks/references/receipt-schema.md` example paths the same way.

Run to find every occurrence:
```bash
grep -rn "\.vernacular" engineering/skills engineering/commands/vernacular.md
```

- [ ] **Step 6: Add the `[Docs]` tag to each description**

Prefix each of the three skills' `description:` with `[Docs] `.

- [ ] **Step 7: Validate frontmatter**

Run:
```bash
for s in clarifying-docblocks rewriting-docblock-prose verifying-docblock-claims; do sh engineering/tests/frontmatter.sh "engineering/skills/$s" "[Docs]"; done
```
Expected: three `PASS` lines

- [ ] **Step 8: Run the docblock-path test and reconcile suite together**

Run: `sh engineering/tests/absorb-vernacular.sh && sh engineering/tests/reconcile.sh`
Expected: `PASS absorb-vernacular.sh` then reconcile cases all PASS

- [ ] **Step 9: Commit**

```bash
git add engineering/skills/clarifying-docblocks engineering/skills/rewriting-docblock-prose engineering/skills/verifying-docblock-claims engineering/commands/vernacular.md engineering/scripts/reconcile.py engineering/tests/reconcile.sh engineering/tests/absorb-vernacular.sh
git commit -m "feat(engineering): absorb vernacular — re-namespace paths, keep reconcile green"
```

---

### Task 7: Re-identify vernacular's `validate.sh` + `e2e.sh` for `engineering`

**Files:**
- Modify (the copies under `engineering/tests/`): `engineering/tests/validate.sh`, `engineering/tests/e2e.sh`

**Interfaces:**
- Produces: a structural validation suite that asserts the **engineering** identity, and an e2e that installs `engineering@dashworthy` and exercises `/vernacular`.

- [ ] **Step 1: Copy the two harness files**

```bash
cp vernacular/tests/validate.sh engineering/tests/validate.sh
cp vernacular/tests/e2e.sh engineering/tests/e2e.sh
```

- [ ] **Step 2: Re-identify `validate.sh`**

Edit `engineering/tests/validate.sh` so it validates the engineering package:
- `PLUGIN="$ROOT/engineering"` (was `$ROOT/vernacular`); `ROOT` resolves two levels up from the test file.
- `plugin.json` assertions: `name == "engineering"`.
- marketplace assertion: `engineering` is registered with `source == "./engineering"`.
- command existence: `commands/vernacular.md` exists (the command name stays `vernacular`).
- README existence: `engineering/README.md` exists.
- root README: assert it lists `engineering` (the cutover plan adds this line; until then, this single check is expected to fail — see Step 5 note).
- Extend the "no stack-detection artefact" scan to the engineering skills tree.

- [ ] **Step 3: Re-identify `e2e.sh`**

Edit `engineering/tests/e2e.sh`:
- Every `vernacular@dashworthy` → `engineering@dashworthy`; `detect_state 'vernacular@dashworthy' …` → `engineering@dashworthy`.
- The discovery prompt keeps asking about installed-plugin commands generally (do not put the plugin name in the prompt).
- The invocation `claude -p "/vernacular:vernacular"` → `claude -p "/vernacular"` (bare command; it now resolves within engineering).
- The scratch assertion `[ ! -d "$TMP/proj/.vernacular" ]` → assert the run scratch appears under `.engineering/` instead: `find "$TMP/proj/.engineering" -type d -name vernacular | grep -q . || fail`.
- Keep the timeout escalation, classifier, ownership snapshot, and cleanup/trap verbatim in behavior (only names adapted).

- [ ] **Step 4: Run `validate.sh`**

Run: `sh engineering/tests/validate.sh`
Expected: all checks PASS **except** the root-README-lists-engineering check, which fails until the cutover plan updates the root README. Note that one expected-fail in the run output.

- [ ] **Step 5: Note the e2e prerequisite**

`e2e.sh` needs a live `claude` CLI and network install; run it in CI or manually:
Run (manual/CI): `sh engineering/tests/e2e.sh`
Expected: `PASS` (or `INCONCLUSIVE` if the environment cannot install). Do not gate this task's commit on the live e2e.

- [ ] **Step 6: Commit**

```bash
git add engineering/tests/validate.sh engineering/tests/e2e.sh
git commit -m "test(engineering): re-identify vernacular validate/e2e harness for engineering"
```

---

### Task 8: Absorb `verity` (copy, re-namespace, redirect) — retire its session-start hook

**Files:**
- Create (copy from `verity/`, then edit): `engineering/skills/{conducting-test-hardening,auditing-test-gaps,verifying-test-integrity,writing-tests-from-brief}/` (with `conducting-test-hardening/references/`)
- Test: `engineering/tests/absorb-verity.sh`

**Interfaces:**
- Consumes: run-context helper for `.engineering/<run>/verity/` (config + `briefs/`).
- Produces: the four test-hardening skills under `engineering`. **No hook** — verity's `SessionStart` reminder is not ported (D15); the plugin's only hook is the entrance bootstrap (Task 2).

- [ ] **Step 1: Copy the four skills (NOT `verity/hooks/`)**

```bash
for s in conducting-test-hardening auditing-test-gaps verifying-test-integrity writing-tests-from-brief; do
  cp -R "verity/skills/$s" "engineering/skills/$s"
done
```

- [ ] **Step 2: Write the failing absorption test**

Create `engineering/tests/absorb-verity.sh`:

```sh
#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
if grep -rn "\.verity" skills; then echo "FAIL: stale .verity path"; fail=1; fi
if grep -rn "verity:" skills; then echo "FAIL: stale verity: namespace"; fail=1; fi
# Verity's session-start reminder must NOT be ported: the only hook is the entrance bootstrap.
if grep -rq "Verity applies once implementation work is finished" hooks/ 2>/dev/null; then
  echo "FAIL: verity session-start reminder was ported"; fail=1; fi
[ -f hooks/session-start.sh ] && grep -q "/triage" hooks/session-start.sh || { echo "FAIL: entrance bootstrap missing"; fail=1; }
[ "$fail" = 0 ] && echo "PASS absorb-verity.sh" || exit 1
```

- [ ] **Step 3: Run it to confirm it fails**

Run: `sh engineering/tests/absorb-verity.sh`
Expected: FAIL (copied files still carry `.verity`)

- [ ] **Step 4: Redirect `.verity` and re-namespace**

In the four skills and `conducting-test-hardening/references/brief-schema.md`, replace `.verity/config.json` → `.engineering/<run>/verity/config.json`, `.verity/briefs/<n>.md` → `.engineering/<run>/verity/briefs/<n>.md`, and any other `.verity/…` → `.engineering/<run>/verity/…`, obtaining the run dir via `sh "${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" verity`. Replace any `verity:` skill-id prefixes with `engineering:`. The gitignore-exclusion note that excluded `.verity/` now excludes `.engineering/`.

Run to find occurrences:
```bash
grep -rn "\.verity\|verity:" engineering/skills
```

- [ ] **Step 5: Add the `[Test hardening]` tag to each description**

Prefix each of the four skills' `description:` with `[Test hardening] `.

- [ ] **Step 6: Validate frontmatter**

Run:
```bash
for s in conducting-test-hardening auditing-test-gaps verifying-test-integrity writing-tests-from-brief; do sh engineering/tests/frontmatter.sh "engineering/skills/$s" "[Test hardening]"; done
```
Expected: four `PASS` lines

- [ ] **Step 7: Run the absorption test**

Run: `sh engineering/tests/absorb-verity.sh`
Expected: `PASS absorb-verity.sh`

- [ ] **Step 8: Commit**

```bash
git add engineering/skills/conducting-test-hardening engineering/skills/auditing-test-gaps engineering/skills/verifying-test-integrity engineering/skills/writing-tests-from-brief engineering/tests/absorb-verity.sh
git commit -m "feat(engineering): absorb verity — re-namespace paths, retire its session-start hook"
```

---

### Task 9: Foundation gate — full suite green + no stale references

**Files:**
- Create: `engineering/tests/suite.sh` (runs every non-live check in this plan)

**Interfaces:**
- Produces: one command that proves the foundation is coherent. This is the gate a reviewer runs before Plan 02 starts.

- [ ] **Step 1: Write the aggregate suite**

Create `engineering/tests/suite.sh`:

```sh
#!/bin/sh
# Foundation suite: every non-live check. (e2e.sh is live/CI-only and excluded here.)
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/hook.sh"
sh "$d/run-context.sh"
sh "$d/reconcile.sh"
sh "$d/absorb-signal.sh"
sh "$d/absorb-vernacular.sh"
sh "$d/absorb-verity.sh"
for s in to-spec:'[Discovery]' conducting-discovery:'[Discovery]' interrogating-requirements:'[Discovery]' expanding-scope:'[Discovery]' sequencing-requirements:'[Discovery]' clarifying-docblocks:'[Docs]' rewriting-docblock-prose:'[Docs]' verifying-docblock-claims:'[Docs]' conducting-test-hardening:'[Test hardening]' auditing-test-gaps:'[Test hardening]' verifying-test-integrity:'[Test hardening]' writing-tests-from-brief:'[Test hardening]'; do
  name=${s%%:*}; tag=${s#*:}
  sh "$d/frontmatter.sh" "$d/../skills/$name" "$tag"
done
echo "ALL FOUNDATION CHECKS PASS"
```

- [ ] **Step 2: Run the suite**

Run: `sh engineering/tests/suite.sh`
Expected: ends with `ALL FOUNDATION CHECKS PASS`

- [ ] **Step 3: Global stale-reference sweep (no cross-plugin leakage in engineering/)**

Run:
```bash
grep -rn "signal:\|verity:\|vernacular:\|\.signal/\|\.verity\|\.vernacular" engineering/skills engineering/commands || echo "CLEAN"
```
Expected: `CLEAN`

- [ ] **Step 4: Commit**

```bash
git add engineering/tests/suite.sh
git commit -m "test(engineering): add foundation aggregate suite"
```

---

## Self-Review

**Spec coverage (against §13 steps 1–4 and the sections they touch):**
- §13.1 scaffold + `.gitignore` + run-context doc + entrance hook → Tasks 1, 2, 3. ✓
- §5.5 one hook, routes to both entrances → Task 2. ✓
- §5.3 / G7 run pointer, shared read-or-create → Task 3 (+ verified across two phases). ✓
- D17 `to-spec` shared spec writer + `SPEC-FORMAT.md` → Task 4. ✓
- §13.2 absorb signal, brief Tier-2, delegate to `to-spec` → Task 5. ✓
- §13.3 absorb vernacular, redirect paths, tests green → Tasks 6, 7. ✓
- §13.4 absorb verity, redirect paths, **retire hook** → Task 8. ✓
- D18 flat skills + `[Group]` tags + `skills/README.md` index → Tasks 1, 4–8 (tags), Task 9 (gate). ✓
- §9 originality / no NOTICE → authored prose in Task 4; nothing copied from external sources; **no NOTICE file created anywhere in this plan.** ✓

**Deferred to later plans (not gaps):** design/build skills (Plan 02), planning/execution + brainstorming + triage + remaining engineering skills (Plan 03), foundations + productivity commands + marketplace cutover + old-dir deletion + final README/diagram (Plan 04). The `engineering` marketplace entry is added here (Task 1) so absorbed tests can install; the old three entries and dirs are removed only at cutover.

**Placeholder scan:** none — every step shows the file content, the exact command, and expected output. Copy-then-rewrite tasks name the source path and list each transformation with a `grep` to locate every occurrence.

**Type/interface consistency:** `run-context.sh <name> [slug]` is produced in Task 3 and consumed with that exact signature in Tasks 5, 6, 8. `frontmatter.sh <skill-dir> [tag]` is produced in Task 4 and reused in Tasks 5, 6, 8, 9. `to-spec` (Task 4) is the consumer named by signal's delegation (Task 5) and by `SPEC-FORMAT.md`.

**Known expected-fail:** `validate.sh`'s "root README lists engineering" check (Task 7, Step 4) fails until the cutover plan updates the root README — called out at the step so it is not mistaken for a regression.
