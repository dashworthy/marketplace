# Engineering plugin — design spec

**Date:** 2026-08-21
**Author:** Andrew Leach
**Status:** Approved design, ready for implementation plan
**Worktree/branch:** `.claude/worktrees/engineering-plugin` on `worktree-engineering-plugin`

## 1. Goal

Assemble a single `engineering` plugin in the `dashworthy` marketplace that is a full
software-development pipeline: discovery → design → build → test-hardening → documentation,
plus cross-cutting utilities. It is built by absorbing the three existing dashworthy plugins
(`signal`, `verity`, `vernacular`) and **reimplementing** a curated subset of the *techniques*
demonstrated in Matt Pocock's skills (https://github.com/mattpocock/skills) as original
dashworthy works — original text and structure, nothing copied (see §9).

The larger objective this serves: **eventually remove the `superpowers` plugin.** This spec
delivers a near-complete replacement — the skills that stand in for `superpowers`'
implementation skills (TDD, debugging, code review), its planning + execution pair, **and** its
connective tissue (worktrees, finishing-branch, verification, parallel dispatch, skill-writing,
skill-discovery — §6.5), plus net-new capability. The one `superpowers` process skill it does
**not** directly replace is `brainstorming` (left open, G8).

## 2. Context

### 2.1 The marketplace today

`dashworthy` (repo: `dashworthy/development-skills`, MIT) publishes three self-contained,
single-purpose plugins, each a *pipeline* of several skills, not a single tool:

- **signal** — discovery: interrogate a vague request into hard requirements, expand scope,
  sequence into a dependency-ordered brief. 4 skills + `/signal`. Produces a brief and stops.
- **verity** — diff-scoped test hardening. 4 skills + a session-start hook. Never touches
  application code.
- **vernacular** — diff-scoped documentation hardening. 3 skills + `/vernacular` +
  `reconcile.py` + a test suite. Proves code and annotations came out byte-identical.

House style, to be preserved: narrow guarantee per unit, an explicit account of what each
unit does **not** guarantee, conductor + dispatched-subagent architecture, file-based
artifacts (no external tracker), README with a process-flow diagram.

### 2.2 Matt Pocock's engineering skills

18 skills, split user-invoked / model-invoked. They are a flat toolbox bound by two shared
substrates:

1. **Knowledge substrate** — `CONTEXT.md` (domain glossary) + `docs/adr/` (decision records).
   Threads through `tdd`, `code-review`, `codebase-design`, `improve-codebase-architecture`,
   `domain-modeling`. Self-contained (just files in the repo). **We adopt this.**
2. **Workflow substrate** — an issue tracker + triage labels, seeded by
   `setup-matt-pocock-skills`. Threads through the planning chain
   (`to-spec`/`to-tickets`/`wayfinder`) and `code-review`'s spec lookup. Heavy external
   coupling, contrary to dashworthy's file-based philosophy. **We reject this**; where a skill
   depends on it, we either drop the skill (its value is already covered by `signal`) or
   rewire it to file-based sources.

## 3. Decisions (locked)

| # | Decision | Rationale |
|---|---|---|
| D1 | One `engineering` plugin holding the whole pipeline | User chose a single umbrella plugin; the SDLC phases make it coherent despite being large |
| D2 | Absorb `signal`, `vernacular`, **and** `verity` into it | They are the discovery / documentation / test-hardening phases of the same pipeline |
| D3 | Marketplace collapses to a single plugin | Consequence of D1+D2; `verity` folded in per explicit choice |
| D4 | Curate; build only what adds capability and fits the file-based philosophy | "Works well with existing skills" = curation, not bulk import |
| D5 | Adopt `CONTEXT.md` + `docs/adr/` as a dashworthy convention (via `domain-modeling`) | It is the connective tissue that makes the design/build skills cohere; self-contained |
| D6 | Reject tracker coupling; everything file-based | Matches dashworthy philosophy; `signal` already owns the discovery/spec front |
| D7 | User-invoked skills become `/commands` | User's explicit rule |
| D8 | Every skill is dashworthy's **own original** work; Matt's skills and `superpowers` are inspiration only. No copying, no attribution, no NOTICE (§9) | User directive: "make these entirely my own" |
| D9 | Plugin name: `engineering` | Clearest umbrella label; deliberately breaks the evocative-single-word pattern (signal/verity/vernacular) because this is the meta-plugin |
| D10 | Deprecate standalone `signal`/`vernacular`/`verity` marketplace entries with a README redirect | Clean documented break; existing installs keep working until reinstall |
| D11 | Author `superpowers`' connective tissue **in this spec** (worktrees, finishing-branch, verification, parallel-dispatch, skill-writing, skill-discovery — §6.5) | User directive: replace all of superpowers' connective tissue now, not later. Only `brainstorming` is left open (G8) |
| D12 | Planning + execution authored **in superpowers style**, in this spec (`writing-plans`, `executing-plans` → `/implement`); Matt's tracker planning chain dropped | User directive; closes the planning gap without tracker coupling |
| D13 | Two file tiers: Tier-1 specs/plans → `docs/dashworthy/engineering/{specs,plans}` (committed); Tier-2 build files → `.engineering/<run>/<name>/` (gitignored, run-first) | User directive; separates durable artifacts from runtime scratch |
| D14 | **Ship functional names this pass.** The signal/verity/vernacular artisanal theme (proposed map, §5.4) is deferred to a later cohesion pass. `to-signal` keeps its (explicitly chosen) name | User directive: keep functional for now |

## 4. Curation ledger — every Matt skill, in or out

**Author** = build an original dashworthy skill for this capability, with Matt's skill as
inspiration only (§9). **Skip** = not building it. The "Matt skill" column names the inspiration,
not a source to copy.

| Matt skill | Verdict | Reason |
|---|---|---|
| `codebase-design` | **Author** (model) | Novel deep-module vocabulary; foundation for `improve-codebase-architecture` |
| `improve-codebase-architecture` | **Author** (command) | Novel; `disable-model-invocation: true` → `/improve-codebase-architecture` |
| `prototype` | **Author** (model) | Novel; neutralize tracker "issue" references |
| `tdd` | **Author** (model) | Direct replacement for `superpowers` test-driven-development |
| `diagnosing-bugs` | **Author** (model) | Direct replacement for `superpowers` systematic-debugging |
| `code-review` | **Author** (model) | Direct replacement for `superpowers` requesting/receiving-code-review; rewire spec-source to file-based |
| `domain-modeling` | **Author** (model) | Owns the CONTEXT.md/ADR substrate (D5) |
| `wizard` | **Author** (model + command) | Novel; add `/wizard` since users ask for one by name |
| `research` | **Author** (model) | Novel; background-agent fact-gathering |
| `resolving-merge-conflicts` | **Author** (model) | Novel; git-only, clean |
| `handoff` (productivity) | **Author** (command) | Compact a conversation into a handoff doc; `disable-model-invocation: true` → `/handoff` |
| `to-signal` (productivity) | **Author** (command) | `/to-signal` — turn a decision you can't answer into a questionnaire for someone else, whose answers feed back into discovery (hence the name); inspiration: Matt's `to-questionnaire` |
| `wait-what` (productivity) | **Author** (command) | Comms repair — "that last message didn't land, re-pitch it"; reads `CONTEXT.md`/`CONTEXT-MAP.md`; → `/wait-what` |
| `to-spec` | **Skip** | HEAVY tracker coupling; `signal` already does discovery→brief (a file) |
| `wayfinder` | **Skip** | HEAVY tracker coupling; a tracker methodology, not worth it file-based |
| `to-tickets` | **Skip** | HEAVY tracker coupling; planning value overlaps `signal`'s `sequencing-requirements` |
| `implement` | **Skip — superseded** | Replaced by an authored, superpowers-inspired `executing-plans` (+ `/implement`), paired with an authored `writing-plans`. See §4 note and §6.4 |
| `triage` | **Skip** | Needs Matt's tracker + label infra |
| `grill-with-docs` | **Skip** | Interactive grilling loop; its role inside `improve-codebase-architecture` is replaced by `codebase-design` + `domain-modeling` |
| `ask-matt` | **Skip** | Personal routing skill referencing Matt's own system |
| `setup-matt-pocock-skills` | **Skip** | Seeds the tracker substrate we reject |

> Note on `implement` (resolved): rather than adopt Matt's `implement`, this plugin **authors a
> planning + execution pair, inspired by superpowers** — a `writing-plans` skill (spec → ordered
> plan with review checkpoints) and an `executing-plans` skill (execute a plan against `/tdd` +
> `/code-review`, with review gates and optional subagent-driven mode), surfaced as
> `/implement`. This is the user's directed choice ("for planning and implement, follow more of
> the superpowers style"). It closes the planning gap (former G1) inside this spec and removes
> the stranding concern. Matt's tracker-coupled `to-spec`/`to-tickets`/`wayfinder`/`implement`
> are all skipped in favor of it. Both are **original works, nothing copied** — see §9.

## 5. Target architecture — the pipeline

| Phase | Skills | Command(s) |
|---|---|---|
| **1 · Discover** | `conducting-discovery`, `interrogating-requirements`, `expanding-scope`, `sequencing-requirements` (signal); `domain-modeling` | `/signal` |
| **2 · Design** | `codebase-design`, `improve-codebase-architecture`, `prototype` | `/improve-codebase-architecture` |
| **2.5 · Plan** | `writing-plans` (authored, superpowers-style) | — |
| **3 · Build & execute** | `tdd`, `diagnosing-bugs`, `code-review`, `executing-plans` (authored, superpowers-style) | `/implement` |
| **3.5 · Harden tests** | `conducting-test-hardening`, `auditing-test-gaps`, `verifying-test-integrity`, `writing-tests-from-brief` (verity) | — (session-start hook) |
| **4 · Document** | `clarifying-docblocks`, `rewriting-docblock-prose`, `verifying-docblock-claims` (vernacular) | `/vernacular` |
| **Cross-cutting** | `wizard`, `research`, `resolving-merge-conflicts`, `handoff`, `to-signal`, `wait-what` | `/wizard`, `/handoff`, `/to-signal`, `/wait-what` |
| **Foundations** (workflow discipline) | `using-git-worktrees`, `finishing-a-development-branch`, `verification-before-completion`, `dispatching-parallel-agents`, `writing-skills`, `using-skills` | — |

Shared knowledge layer across phases 2–4: `CONTEXT.md` + `docs/adr/`, seeded and maintained by
`domain-modeling`, read (never required) by `tdd`, `code-review`, `codebase-design`,
`improve-codebase-architecture`.

Unit count: ~29 skills (signal 4 + verity 4 + vernacular 3 + Matt-inspired engineering 10 +
2 planning/execution + 6 workflow foundations) + 3 productivity commands (handoff, to-signal,
wait-what — realized as pure commands, see §5.2). Commands total: 8 (`/signal`, `/vernacular`,
`/improve-codebase-architecture`, `/implement`, `/wizard`, `/handoff`, `/to-signal`,
`/wait-what`). Hook: 1 (verity session-start). This is a large plugin — the trade for it being
a near-complete `superpowers` replacement plus the design/discovery additions.

### 5.1 File-artifact conventions

Generated files fall in **two tiers**, by durability and audience:

**Tier 1 — durable spec & plan documents** (human-facing, committed). Mirrors `superpowers`'
spec/plan convention, namespaced under marketplace + plugin so it never collides with another
tool's artifacts:

| Artifact | Path | Produced by | Consumed by |
|---|---|---|---|
| Discovery brief / spec | `docs/dashworthy/engineering/specs/` | `signal` (brief), any spec-writing step | `writing-plans`, `code-review` (Spec axis), humans |
| Implementation plan | `docs/dashworthy/engineering/plans/` | `writing-plans` | `executing-plans` / `/implement`, humans |
| Domain glossary | `CONTEXT.md` (repo root) | `domain-modeling` | design/build skills |
| Decision records | `docs/adr/` | `domain-modeling` | design/build skills |

Naming within `specs/`/`plans/` follows `YYYY-MM-DD-<topic>.md` (this design doc itself lives
at `docs/dashworthy/engineering/specs/2026-08-21-engineering-plugin-design.md`).

**Tier 2 — build/working files** (per-phase scratch, run scaffolding, receipts, internal
briefs — everything that is not a spec/plan document). All generated under a single gitignored
root, **run-first** so every phase of one run is co-located (§5.3), replacing today's scattered
`.signal/`, `.verity/`, `.vernacular/`:

| Was | Becomes | Holds |
|---|---|---|
| `.signal/runs/<date>-<slug>/` | `.engineering/<run>/signal/` | `open-threads.md`, `00-request.md`, run scaffolding |
| `.verity/`, `.verity/briefs/` | `.engineering/<run>/verity/` (+ `briefs/`) | config, test-hardening working briefs |
| `.vernacular/` | `.engineering/<run>/vernacular/` | rewrite receipts, reconcile temp |

Consequences:

- **`.engineering/` is gitignored** (add to `.gitignore` during the build) — it is per-project
  runtime output, never committed, and never part of the plugin package.
- **The spec/plan seam.** `signal`'s `brief.md` is the discovery *deliverable* → Tier 1
  (`docs/dashworthy/engineering/specs/`); its run scaffolding stays Tier 2
  (`.engineering/<run>/signal/`). **Assumption to confirm at review:** the brief is spec-tier
  and lands in `docs/.../specs/`, while everything else signal writes is build-tier.
- **`code-review` rewiring** (§6.2) reads its Spec-axis source from
  `docs/dashworthy/engineering/specs/` (plus user-supplied paths), replacing the tracker lookup.
- Redirecting these working paths is part of each plugin's absorption (§6.1), and touches
  `vernacular`'s `tests/` (which reference `.vernacular`).

### 5.2 Command realization rule

Two ways a user-invoked (D7) capability is realized, chosen by shape:

- **Skill + thin `/command` wrapper** — when the capability has reference/subfiles, or another
  skill dispatches it. Applies to `signal`, `vernacular`, `improve-codebase-architecture`, and
  `executing-plans` (→ `/implement`). The `/command` is a few lines that invoke the skill.
- **Pure `commands/<name>.md`** — when the capability is a self-contained single-shot with no
  subfiles and nothing dispatches it. Applies to `handoff`, `to-signal`, `wait-what`.
  The whole workflow lives in the command file; no skill entry.

### 5.3 Run context (the `<run>` key)

Tier-2 is organized by *run* so one piece of work's artifacts sit together and a whole run's
scratch can be inspected or discarded at once. A run needs an id shared across phases that are
otherwise invoked independently:

- **`<run>` format:** `<YYYY-MM-DD>-<slug>`, where the slug is a short kebab name for the work
  (derived from the request or branch). This reuses `signal`'s existing run-naming, hoisted to
  the top level so every phase shares it.
- **Establishing / reusing a run:** the first phase to write in a working session creates the
  run and records it in a gitignored pointer, `.engineering/.current-run` (holds the active
  `<run>`). Later phases read the pointer and write under the same `<run>`.
- **Standalone invocation** (e.g. `/vernacular` with no prior `signal` run): if the pointer is
  absent, the skill starts a fresh run — its own `<YYYY-MM-DD>-<slug>` — and sets the pointer,
  so any subsequent phase joins it.
- **Correspondence, not coupling:** a run's slug will usually match the Tier-1 spec topic
  (`docs/.../specs/<same-date>-<slug>.md`), but the tiers stay separate — Tier-1 is committed
  and human-facing, Tier-2 is gitignored runtime scratch.
- **New shared mechanism** — see gap G7. The run pointer is the one piece of cross-phase state
  this plugin introduces; every absorbed skill must read/create it the same way.

### 5.4 Naming (artisanal theme — DEFERRED)

**Deferred (D14): this pass ships functional names.** The map below is kept as a future cohesion
pass. The marketplace's existing skills — `signal`, `verity`, `vernacular` — are evocative,
mostly single, Latinate quality-nouns, and new skills could later adopt that register where it
makes sense, so the plugin reads as one handcrafted set. Guard: keep conventional names where a
themed one would hurt discoverability (`tdd`, `code-review`).

Proposed map (future — not applied this pass; `to-signal` is the one already-chosen exception):

| Capability | Proposed name | Why |
|---|---|---|
| domain-modeling | **lexicon** | owns `CONTEXT.md` — the project's vocabulary |
| codebase-design | **profundity** | deep-module vocabulary (depth, leverage, seams) |
| improve-codebase-architecture | **renovation** (`/renovate`) | finds shallow modules and deepens them |
| prototype | **maquette** | a small throwaway model |
| writing-plans | **prospectus** | a document laying out the planned work |
| executing-plans | **cadence** (`/implement`) | disciplined execution rhythm |
| diagnosing-bugs | **etiology** | the study of causes |
| research | **provenance** | primary-source discipline |
| resolving-merge-conflicts | **confluence** | reconciling streams into one |
| wizard | **cicerone** (`/cicerone`) | a guide who conducts a human through steps |
| handoff | **dossier** (`/dossier`) | a file handed to the next session |
| wait-what | **gloss** (`/gloss`) | a plain-language restatement |
| to-signal | `to-signal` | already themed (feeds `signal`) |
| tdd | `tdd` | strong convention — keep |
| code-review | `code-review` | strong convention — keep |

signal/verity/vernacular and their internal sub-skills keep their current names. Elsewhere in
this spec, capabilities are referred to by their functional names for clarity; §5.4 is the
authority on the shipped skill id.

## 6. Adaptation notes, per source

### 6.1 Absorbed dashworthy plugins (behavior-preserving move)

- **signal → engineering.** Move 4 skills + `commands/signal.md`. Re-namespace every internal
  reference from `signal:` to `engineering:` (the `/signal` command dispatches
  `signal:conducting-discovery`; the conductor dispatches the other three). **Tier-1:** write the
  `brief.md` deliverable to `docs/dashworthy/engineering/specs/`. **Tier-2:** move run
  scaffolding to `.engineering/<run>/signal/` (§5.1, §5.3); signal, as the usual first phase, is
  the natural place to establish `<run>` and write the `.engineering/.current-run` pointer.
  Updates the run-dir references in `conducting-discovery` and the README/command prose.
- **vernacular → engineering.** Move 3 skills + `commands/vernacular.md` + `scripts/reconcile.py`
  + `tests/` (`e2e.sh`, `reconcile.sh`, `validate.sh`). Re-namespace. **Tier-2:** redirect
  `.vernacular/` → `.engineering/<run>/vernacular/` in the skills, the receipt schema, and the
  test suite (`e2e.sh` and others reference `.vernacular`); read/create the run pointer (§5.3).
  Keep the reconcile test suite green — it is the plugin's proof harness.
- **verity → engineering.** Move 4 skills + `hooks/hooks.json` + `hooks/session-start.sh` +
  the `conducting-test-hardening/references/*`. Re-namespace. **Tier-2:** redirect `.verity/`
  and `.verity/briefs/` → `.engineering/<run>/verity/` (config + working briefs) across the
  skills and `brief-schema.md`; read/create the run pointer (§5.3). The session-start hook
  injects the "Verity applies once implementation work is finished… invoke
  `conducting-test-hardening`" reminder — update the skill reference to the new namespace and
  confirm the hook still fires.

### 6.2 Original skills, inspired by Matt's (§9)

Each bullet names the inspiration and the pieces to build. Every file is **authored fresh** in
dashworthy voice — original text and structure, nothing copied (§9). "author `SKILL.md` + `X.md`"
means write dashworthy's own SKILL and companion files covering the same technique.

- **codebase-design** — author `SKILL.md` + `DEEPENING.md` + `DESIGN-IT-TWICE.md` (deep-module
  vocabulary). Foundation for the design phase; build first.
- **domain-modeling** — author `SKILL.md` + dashworthy `CONTEXT-FORMAT.md` / `ADR-FORMAT.md`
  templates (original; see G3). Define the boundary vs `signal`: `signal` explores *what to
  build*; `domain-modeling` crystallizes *how we name it* and owns `CONTEXT.md`.
- **tdd** — author `SKILL.md` + `tests.md` + `mocking.md`. Keep the optional `CONTEXT.md`
  reference. Document the boundary vs verity: `tdd` is the red-green build loop *during*
  implementation; verity is diff-scoped hardening *after*. They compose.
- **diagnosing-bugs** — author `SKILL.md` + `scripts/hitl-loop.template.sh`. Clean; no tracker.
- **code-review** — author `SKILL.md`. **Rewire the spec source**: replace the
  `docs/agents/issue-tracker.md` lookup + "run `/setup-matt-pocock-skills`" prompt with
  file-based spec discovery (a `signal` brief in `docs/dashworthy/engineering/specs/`, or a
  user-supplied path — see §5.1). Keep the
  two-axis (Standards + Spec) structure and parallel sub-agents. Note coexistence with the
  user's separately-installed review plugins (different marketplaces; no conflict, but the
  `code-review` name will appear twice in the skill list during the superpowers-removal
  transition — acceptable).
- **improve-codebase-architecture** — author `SKILL.md` + `HTML-REPORT.md`. Convert to a
  `/improve-codebase-architecture` command (it is `disable-model-invocation: true`). **Sever the
  `grill-with-docs` dependency**: replace the grilling loop with invocations of `codebase-design`
  (interface exploration) and `domain-modeling` (CONTEXT.md/ADR updates). Keep the self-contained
  HTML report (Tailwind + Mermaid via CDN, written to a temp dir).
- **prototype** — author `SKILL.md` + `LOGIC.md` + `UI.md`. Neutralize tracker references:
  "document the validated decision in the issue" → "document it in the brief/spec" (file-based).
- **wizard** — author `SKILL.md` + `template.sh` (into `scripts/wizard-template.sh`). Add a
  `/wizard` command that invokes the skill. Note the `gh` CLI runtime dependency.
- **research** — author `SKILL.md`. Background-agent dispatch; writes a cited Markdown file
  following repo conventions. Clean.
- **resolving-merge-conflicts** — author `SKILL.md`. git-only; clean.

### 6.3 Productivity commands (original; realized as pure commands, §5.2)

Three original commands, inspired by Matt's `skills/productivity/` (§9). Each is user-invoked,
so a pure `commands/<name>.md` (§5.2).

- **handoff → `/handoff`** — compact the conversation into a handoff document for a successor
  session. Keep the `argument-hint` ("What will the next session be used for?"). Keep writing to
  the OS temp dir (ephemeral cross-session context; deliberately not a repo artifact), and keep
  the "suggested skills" section — but update those suggestions to reference `engineering:`
  skills. Keep secret redaction. Reference existing artifacts under
  `docs/dashworthy/engineering/specs|plans/`, `CONTEXT.md`, `docs/adr/` rather than duplicating.
- **to-signal → `/to-signal`** — turn a decision you can't answer into a questionnaire for
  someone else; writes `to-signal-<slug>.md` in the current directory. Named for its pairing with
  `signal`: when discovery surfaces a question the user cannot answer, `to-signal` externalizes
  it and the answers feed back into discovery.
- **wait-what → `/wait-what`** — comms repair. Reads `CONTEXT.md`/`CONTEXT-MAP.md` (our adopted
  substrate, D5), writes nothing. Keep the ASD-STE100 Simplified-Technical-English framing.

### 6.4 Authored planning + execution (superpowers as inspiration)

Per the user's directive ("for planning and implement, follow more of the superpowers style"),
these two are **authored fresh, inspired by superpowers** — original text and structure, nothing
copied (§9). They replace Matt's skipped `to-spec`/`to-tickets`/`wayfinder`/`implement`.

- **writing-plans** (Phase 2.5, model-invoked). Turns a spec/brief in
  `docs/dashworthy/engineering/specs/` into an ordered implementation plan written to
  `docs/dashworthy/engineering/plans/<YYYY-MM-DD>-<topic>.md` — steps sequenced so nothing
  precedes what it depends on, with review checkpoints and explicit TDD integration points.
  Reads `CONTEXT.md`/ADRs when present. Style model: `superpowers:writing-plans`.
- **executing-plans** (Phase 3, skill + `/implement`). Executes a plan from
  `docs/dashworthy/engineering/plans/` task by task, each task driven through `engineering:tdd`
  and gated by `engineering:code-review`, pausing at the plan's review checkpoints. Supports an
  optional subagent-driven mode for independent tasks (style model:
  `superpowers:executing-plans` + `superpowers:subagent-driven-development`). Working state
  under `.engineering/<run>/implement/` (§5.3).
- **Namespacing avoids collision.** As `engineering:writing-plans` / `engineering:executing-plans`
  they coexist with the `superpowers:` originals during the transition (G5).

### 6.5 Authored workflow foundations (superpowers as inspiration)

The six cross-cutting workflow disciplines that make `superpowers` cohere. Authored original,
inspired by superpowers' approach (§9) — original text, nothing copied. Model-invoked (they fire
by discipline, not by command); no new commands.

- **using-git-worktrees** — ensure work happens in an isolated workspace; prefer the harness's
  native worktree tool (e.g. `EnterWorktree`), fall back to `git worktree`. Detect existing
  isolation first.
- **finishing-a-development-branch** — when work is complete and green, present structured
  options for integrating it (merge / PR / cleanup) and carry out the choice.
- **verification-before-completion** — before claiming done/fixed/passing, run the verification
  commands and confirm output; evidence before assertions. (Complements verity, which hardens
  the tests themselves.)
- **dispatching-parallel-agents** — a general primitive for fanning out 2+ independent tasks
  with no shared state; distinct from `executing-plans`' plan-scoped subagent mode.
- **writing-skills** — author, edit, and verify skills (the meta-skill for growing this plugin);
  makes the plugin self-extending as it diverges (§9).
- **using-skills** — the skill-discovery discipline: how to find and invoke the right skill
  before acting. This is dashworthy's own equivalent of `superpowers`' bootstrap meta-skill;
  named `using-skills` (not `using-superpowers`) precisely because it is not superpowers.

> Residual note: `superpowers`' `brainstorming` (approval-gated design dialogue) is **not** one
> of these six and is only partly covered by `signal` (discovery→brief). Whether to author a
> dashworthy `brainstorming` is left open — flagged in G8, not built here — as it is the one
> `superpowers` process skill this spec does not directly replace. `subagent-driven-development`
> is covered by `executing-plans`' subagent mode (§6.4).

## 7. Directory layout

```
engineering/
├── .claude-plugin/plugin.json
├── README.md                         pipeline overview + process diagram + non-guarantees
├── commands/
│   ├── signal.md
│   ├── vernacular.md
│   ├── improve-codebase-architecture.md
│   ├── implement.md                  wrapper → executing-plans
│   ├── wizard.md
│   ├── handoff.md                    productivity (pure command, §5.2)
│   ├── to-signal.md           productivity (pure command, §5.2)
│   └── wait-what.md                  productivity (pure command, §5.2)
├── hooks/
│   ├── hooks.json
│   └── session-start.sh              verity's, namespace-updated
├── scripts/
│   ├── reconcile.py                  vernacular
│   ├── hitl-loop.template.sh         diagnosing-bugs
│   └── wizard-template.sh            wizard
├── tests/                            vernacular's proof harness
│   ├── e2e.sh
│   ├── reconcile.sh
│   └── validate.sh
└── skills/
    ├── conducting-discovery/         ┐
    ├── interrogating-requirements/   │ signal
    ├── expanding-scope/              │
    ├── sequencing-requirements/      ┘
    ├── domain-modeling/
    ├── codebase-design/              (+ DEEPENING.md, DESIGN-IT-TWICE.md)
    ├── improve-codebase-architecture/(+ HTML-REPORT.md)
    ├── prototype/                    (+ LOGIC.md, UI.md)
    ├── tdd/                          (+ tests.md, mocking.md)
    ├── diagnosing-bugs/
    ├── code-review/
    ├── writing-plans/                (authored, superpowers-style)
    ├── executing-plans/              (authored, superpowers-style; → /implement)
    ├── conducting-test-hardening/    ┐
    ├── auditing-test-gaps/           │ verity (+ references/)
    ├── verifying-test-integrity/     │
    ├── writing-tests-from-brief/     ┘
    ├── clarifying-docblocks/         ┐
    ├── rewriting-docblock-prose/     │ vernacular (+ references/)
    ├── verifying-docblock-claims/    ┘
    ├── wizard/
    ├── research/
    ├── resolving-merge-conflicts/
    ├── using-git-worktrees/            ┐
    ├── finishing-a-development-branch/ │ workflow foundations
    ├── verification-before-completion/ │ (superpowers-inspired,
    ├── dispatching-parallel-agents/    │  authored original)
    ├── writing-skills/                 │
    └── using-skills/                   ┘
```

`docs/dashworthy/engineering/{specs,plans}/` (Tier-1) and `.engineering/<run>/…` (Tier-2) are
generated **in the user's project at runtime**, not shipped inside the plugin package — they do
not appear in the plugin directory above.

## 8. Marketplace changes + migration

- Rewrite `.claude-plugin/marketplace.json`: replace the three entries with a single
  `engineering` entry (name, description, version `0.1.0`, `source: ./engineering`, author).
- Root `README.md`: rewrite around the one pipeline plugin. Add a **Deprecation** section:
  > `signal`, `verity`, and `vernacular` are now phases of the `engineering` plugin. The old
  > install commands (`/plugin install signal@dashworthy`, etc.) are deprecated; install
  > `engineering@dashworthy` instead. Existing installs keep working until reinstall.
- Delete the old top-level `signal/`, `verity/`, `vernacular/` directories once their contents
  are absorbed and verified.

## 9. Originality (this is entirely dashworthy's own work)

**The goal is that every skill here is dashworthy's own.** Matt Pocock's skills and
`superpowers` are **inspiration** — reference points for how others solved the same problem —
not sources to be copied. What is protectable by copyright is *expression*, not the underlying
idea, method, or workflow; so dashworthy re-derives the method and writes it fresh.

- Repo stays MIT.
- **No attribution, no NOTICE, no credit lines.** Because nothing is copied, no MIT notice is
  owed and none is carried. There is no `engineering/NOTICE`.
- **Originality bar (what makes that sound):** each skill is a genuine independent expression —
  original text, original section structure, dashworthy voice and conventions. Not a paraphrase
  of Matt's wording, not a near-copy of his layout, not a reskinned superpowers skill. Any draft
  that would read as derivative of a source's text is rewritten until it does not. Code and
  templates (wizard/HITL scripts, HTML report, etc.) are written from scratch, not lifted.
- This applies uniformly: the design/build skills (Matt as inspiration), `writing-plans` /
  `executing-plans` (superpowers as inspiration), and the productivity commands.
- signal/verity/vernacular are already dashworthy-original; they simply move in.
- **These diverge over time.** The first cut captures the technique in dashworthy's voice; from
  there the skills are progressively modified and maintained to match the author's specific
  needs, drifting further from any inspiration with each revision. They are owned, living works,
  not a snapshot of someone else's.
- The references to Matt's and superpowers' skills in *this design doc* are provenance notes for
  the reader — they name what inspired each capability. They are internal to the spec and are
  **not** carried into the shipped plugin.

## 10. Non-guarantees (house style)

This plugin explicitly does **not**:

- Directly replace `superpowers`' `brainstorming` (approval-gated design dialogue). `signal`
  covers discovery→brief; the design-dialogue element is only partly covered. Left open (G8).
  (Every *other* `superpowers` process skill — planning, execution, worktrees, finishing-branch,
  verification, parallel dispatch, skill-writing, skill-discovery — **is** authored here, §6.4/§6.5.)
- Integrate with any issue tracker. All artifacts are files.
- Require `CONTEXT.md`/ADRs — the design/build skills read them when present, never demand them.
- Persist Tier-2 output — `.engineering/<run>/…` is gitignored runtime scratch, safe to delete.

## 11. Gaps surfaced (per the "identify gaps" instruction)

| # | Gap | Disposition |
|---|---|---|
| G1 | ~~Planning gap.~~ **Resolved in this spec.** Authored superpowers-style `writing-plans` + `executing-plans` (§6.4) close the brief→plan→execute path; plans land in `docs/dashworthy/engineering/plans/`. | Build here, not deferred. |
| G2 | ~~**Connective tissue.**~~ **Resolved in this spec.** worktrees, finishing-a-branch, verification-before-completion, dispatching-parallel-agents, writing-skills, using-skills — the six workflow disciplines that had no equivalent in Matt's set or dashworthy. | Build here (§6.5). Authored original, inspired by superpowers' approach (§9) — no copying. |
| G3 | **CONTEXT/ADR templates.** `domain-modeling` needs `CONTEXT-FORMAT.md`/`ADR-FORMAT.md` format templates. | Author original dashworthy templates; the CONTEXT.md-glossary + lightweight-ADR pattern is a well-known convention, so no source needed. |
| G4 | **`grill-with-docs` removal.** `improve-codebase-architecture` leans on it. | Rewire to `codebase-design` + `domain-modeling` (§6.2). Verify the loop still terminates sensibly. |
| G5 | **Transition-period name overlap.** While `superpowers` is still installed, some authored skills (`engineering:tdd`, `engineering:code-review`, `engineering:writing-plans`/`executing-plans`) sit alongside their `superpowers` counterparts (test-driven-development, requesting-code-review, writing-plans/executing-plans). | Namespacing keeps them distinct; the duplication resolves when `superpowers` is removed. Note in README. |
| G6 | ~~`implement` stranding.~~ **Resolved.** Superseded by authored `writing-plans` + `executing-plans` (§4 note, §6.4). | Build here, not deferred. |
| G7 | **Run-context mechanism (new).** Run-first Tier-2 (§5.3) introduces the shared `.engineering/.current-run` pointer — the one piece of cross-phase state. Risk: phases must read/create it identically, or a run fragments across ids. | Implementation must give every absorbed skill the same read-or-create-pointer step; add a test that two phases in one session share a `<run>`. |
| G8 | **Brainstorming residual.** `superpowers`' `brainstorming` (approval-gated design dialogue → spec) is the one process skill this spec does not directly replace. `signal` covers discovery→brief, but its interrogation register differs from brainstorming's collaborative design dialogue (§6.5 residual note). | **Left open — not built here.** Decide later whether to author a dashworthy `brainstorming`, extend `signal` with a design-dialogue mode, or leave it to `signal` + `writing-plans`. Does not block `superpowers` removal on its own. |

### After this spec (documented, not built here)

With planning/execution (§6.4) and the six connective-tissue foundations (§6.5) both authored
here, only two threads remain before `superpowers` can be removed:

- **`brainstorming` (G8)** — decide whether to author a dashworthy equivalent, extend `signal`,
  or accept `signal` + `writing-plans` as sufficient. A scoping question, not a committed build.
- **The `guardrails` plugin (§12)** — `git-guardrails-claude-code` + `setup-pre-commit`, a
  separate small plugin with its own spec. Repo-hygiene tooling, not an SDLC phase; unrelated to
  the `superpowers` removal.

## 12. Out of scope

- Removing the `superpowers` plugin itself (that happens once this replacement is proven in daily
  use, and the `brainstorming` question, G8, is settled).
- Any change to `verity`'s or `vernacular`'s internal proof mechanics beyond re-namespacing.
- **`git-guardrails-claude-code` and `setup-pre-commit`** (Matt's `skills/misc/`). These are
  repo-guardrail / hygiene tooling, not SDLC-pipeline phases: git-guardrails is a Claude-Code
  PreToolUse hook + `settings.json` entry that blocks destructive git ops; setup-pre-commit
  bootstraps Husky + lint-staged + Prettier. They belong in the marketplace but **not in the
  engineering plugin** — candidate for a separate small `guardrails` (or similar) plugin, its
  own spec. Recorded here so they are not lost.

## 13. Build sequence (input to writing-plans)

1. Scaffold `engineering/` — `plugin.json`, `README.md` skeleton. Add `.engineering/`
   to `.gitignore` (Tier-2 root). Establish the run-context convention doc (§5.3).
2. Absorb `signal` — move + re-namespace; write `brief.md` to `docs/dashworthy/engineering/specs/`
   (Tier-1); move run scaffolding to `.engineering/<run>/signal/` and have signal create the
   `.engineering/.current-run` pointer (§5.3); verify `/signal` resolves.
3. Absorb `vernacular` — move skills/command/`reconcile.py`/tests + re-namespace; redirect
   `.vernacular/` → `.engineering/<run>/vernacular/` (skills, receipt schema, and `tests/`);
   read/create the run pointer; run `tests/` green.
4. Absorb `verity` — move skills/hooks/references + re-namespace; redirect `.verity/*` →
   `.engineering/<run>/verity/`; read/create the run pointer; verify the session-start hook fires
   and points at the new `conducting-test-hardening`.
5. Author `codebase-design` (deep-module vocabulary) — the design-phase foundation.
6. Author `domain-modeling` + dashworthy `CONTEXT`/`ADR` format templates (resolve G3).
7. Author `tdd`, `diagnosing-bugs`, `code-review` — `code-review` reads its spec source from
   `docs/dashworthy/engineering/specs/` (§6.2).
8. Author `improve-codebase-architecture` as a command — no grilling dependency; it leans on
   `codebase-design` + `domain-modeling` (G4).
9. Author `writing-plans` (→ `docs/.../plans/`) and `executing-plans` (+ `/implement`,
   working state under `.engineering/<run>/implement/`), inspired by superpowers (§6.4).
10. Author `prototype`, `research`, `resolving-merge-conflicts`, `wizard` (+ `/wizard`).
11. Author the six workflow foundations (§6.5), inspired by superpowers: `using-git-worktrees`,
    `finishing-a-development-branch`, `verification-before-completion`,
    `dispatching-parallel-agents`, `writing-skills`, `using-skills`. Model-invoked; no commands.
12. Author the three productivity commands as pure `commands/*.md` (§5.2, §6.3): `/handoff`,
    `/to-signal`, `/wait-what`.
13. Rewrite `marketplace.json` (single entry) + root `README.md` (deprecation redirect +
    pipeline overview + non-guarantees).
14. Delete absorbed top-level `signal/`, `verity/`, `vernacular/` dirs.
15. Verify: every command (8) resolves; every skill frontmatter valid; hook fires; vernacular
    `tests/` pass; a run-context test shows two phases in one session share a `<run>` (G7); no
    dangling `signal:`/`verity:`/`vernacular:` refs or `.signal`/`.verity`/`.vernacular` paths;
    `.engineering/` gitignored; no NOTICE / attribution anywhere (originality, §9).
