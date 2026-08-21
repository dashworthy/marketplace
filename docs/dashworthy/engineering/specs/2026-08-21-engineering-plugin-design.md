# Engineering plugin — design spec

**Date:** 2026-08-21
**Author:** Andrew Leach
**Status:** Approved design, ready for implementation plan
**Worktree/branch:** `.claude/worktrees/engineering-plugin` on `worktree-engineering-plugin`

## 1. Goal

Assemble a single `engineering` plugin in the `dashworthy` marketplace that is a full
software-development pipeline: discovery → design → build → test-hardening → documentation,
plus cross-cutting utilities. It is built by absorbing the three existing dashworthy plugins
(`signal`, `verity`, `vernacular`) and porting a curated, adapted subset of Matt Pocock's
engineering skills (https://github.com/mattpocock/skills, MIT © Matt Pocock 2026).

The larger objective this serves: **eventually remove the `superpowers` plugin.** This spec
delivers the bulk of that replacement — the skills that stand in for `superpowers`'
implementation skills (TDD, debugging, code review) plus net-new capability — and explicitly
defers `superpowers`' connective-tissue skills to a follow-up spec (see §11).

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
| D4 | Curate Matt's set; port only what adds capability and fits file-based philosophy | "Works well with existing skills" = curation, not bulk copy |
| D5 | Adopt `CONTEXT.md` + `docs/adr/` as a dashworthy convention (via `domain-modeling`) | It is the connective tissue that makes the design/build skills cohere; self-contained |
| D6 | Reject tracker coupling; everything file-based | Matches dashworthy philosophy; `signal` already owns the discovery/spec front |
| D7 | User-invoked skills become `/commands` | User's explicit rule |
| D8 | Preserve MIT license + attribute Matt Pocock on every ported skill | License compliance + good citizenship |
| D9 | Plugin name: `engineering` | Clearest umbrella label; deliberately breaks the evocative-single-word pattern (signal/verity/vernacular) because this is the meta-plugin |
| D10 | Deprecate standalone `signal`/`vernacular`/`verity` marketplace entries with a README redirect | Clean documented break; existing installs keep working until reinstall |
| D11 | Defer `superpowers` connective tissue (worktrees, finishing-branch, verification, parallel-dispatch, skill-writing/discovery) to a follow-up spec | Keeps this spec to one coherent deliverable |
| D12 | Planning + execution authored **in superpowers style**, in this spec (`writing-plans`, `executing-plans` → `/implement`); Matt's tracker planning chain dropped | User directive; closes the planning gap without tracker coupling |
| D13 | Two file tiers: Tier-1 specs/plans → `docs/dashworthy/engineering/{specs,plans}` (committed); Tier-2 build files → `.engineering/<run>/<name>/` (gitignored, run-first) | User directive; separates durable artifacts from runtime scratch |

## 4. Curation ledger — every Matt skill, in or out

| Matt skill | Verdict | Reason |
|---|---|---|
| `codebase-design` | **Port** (model) | Novel deep-module vocabulary; foundation for `improve-codebase-architecture` |
| `improve-codebase-architecture` | **Port** (command) | Novel; `disable-model-invocation: true` → `/improve-codebase-architecture` |
| `prototype` | **Port** (model) | Novel; neutralize tracker "issue" references |
| `tdd` | **Port** (model) | Direct replacement for `superpowers` test-driven-development |
| `diagnosing-bugs` | **Port** (model) | Direct replacement for `superpowers` systematic-debugging |
| `code-review` | **Port** (model) | Direct replacement for `superpowers` requesting/receiving-code-review; rewire spec-source to file-based |
| `domain-modeling` | **Port** (model) | Owns the CONTEXT.md/ADR substrate (D5) |
| `wizard` | **Port** (model + command) | Novel; add `/wizard` since users ask for one by name |
| `research` | **Port** (model) | Novel; background-agent fact-gathering |
| `resolving-merge-conflicts` | **Port** (model) | Novel; git-only, clean |
| `handoff` (productivity) | **Port** (command) | Compact a conversation into a handoff doc; `disable-model-invocation: true` → `/handoff` |
| `to-questionnaire` (productivity) | **Port** (command) | Externalize an unanswerable decision as a questionnaire; `disable-model-invocation: true` → `/to-questionnaire`; complements `signal` |
| `wait-what` (productivity) | **Port** (command) | Comms repair — "that last message didn't land, re-pitch it"; reads `CONTEXT.md`/`CONTEXT-MAP.md`; → `/wait-what` |
| `to-spec` | **Drop** | HEAVY tracker coupling; `signal` already does discovery→brief (a file) |
| `wayfinder` | **Drop** | HEAVY tracker coupling; a tracker methodology, not worth it file-based |
| `to-tickets` | **Drop** | HEAVY tracker coupling; planning value overlaps `signal`'s `sequencing-requirements` |
| `implement` | **Drop — superseded** | Replaced by an authored superpowers-style `executing-plans` (+ `/implement`), paired with an authored `writing-plans`. See §4 note and §6.4 |
| `triage` | **Drop** | Needs Matt's tracker + label infra |
| `grill-with-docs` | **Drop** | Interactive grilling loop; its role inside `improve-codebase-architecture` is replaced by `codebase-design` + `domain-modeling` |
| `ask-matt` | **Drop** | Personal routing skill referencing Matt's own system |
| `setup-matt-pocock-skills` | **Drop** | Seeds the tracker substrate we reject |

> Note on `implement` (resolved): rather than port Matt's `implement`, this plugin **authors a
> superpowers-style planning + execution pair** — a `writing-plans` skill (spec → ordered plan
> with review checkpoints) and an `executing-plans` skill (execute a plan against `/tdd` +
> `/code-review`, with review gates and optional subagent-driven mode), surfaced as
> `/implement`. This is the user's directed choice ("for planning and implement, follow more of
> the superpowers style"). It closes the planning gap (former G1) inside this spec and removes
> the stranding concern. Matt's tracker-coupled `to-spec`/`to-tickets`/`wayfinder`/`implement`
> are all dropped in favor of it. These two skills are **authored in superpowers' style, not
> copied** — see the license note in §9.

## 5. Target architecture — the pipeline

| Phase | Skills | Command(s) |
|---|---|---|
| **1 · Discover** | `conducting-discovery`, `interrogating-requirements`, `expanding-scope`, `sequencing-requirements` (signal); `domain-modeling` | `/signal` |
| **2 · Design** | `codebase-design`, `improve-codebase-architecture`, `prototype` | `/improve-codebase-architecture` |
| **2.5 · Plan** | `writing-plans` (authored, superpowers-style) | — |
| **3 · Build & execute** | `tdd`, `diagnosing-bugs`, `code-review`, `executing-plans` (authored, superpowers-style) | `/implement` |
| **3.5 · Harden tests** | `conducting-test-hardening`, `auditing-test-gaps`, `verifying-test-integrity`, `writing-tests-from-brief` (verity) | — (session-start hook) |
| **4 · Document** | `clarifying-docblocks`, `rewriting-docblock-prose`, `verifying-docblock-claims` (vernacular) | `/vernacular` |
| **Cross-cutting** | `wizard`, `research`, `resolving-merge-conflicts`, `handoff`, `to-questionnaire`, `wait-what` | `/wizard`, `/handoff`, `/to-questionnaire`, `/wait-what` |

Shared knowledge layer across phases 2–4: `CONTEXT.md` + `docs/adr/`, seeded and maintained by
`domain-modeling`, read (never required) by `tdd`, `code-review`, `codebase-design`,
`improve-codebase-architecture`.

Unit count: ~23 skills (signal 4 + verity 4 + vernacular 3 + Matt engineering 10 + 2 authored
superpowers-style: `writing-plans`, `executing-plans`) + 3 productivity commands (handoff,
to-questionnaire, wait-what — realized as pure commands, see §5.2). Commands total: 8
(`/signal`, `/vernacular`, `/improve-codebase-architecture`, `/implement`, `/wizard`,
`/handoff`, `/to-questionnaire`, `/wait-what`). Hook: 1 (verity session-start).

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
  subfiles and nothing dispatches it. Applies to `handoff`, `to-questionnaire`, `wait-what`.
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

### 6.2 Ported Matt skills (adapt + attribute)

- **codebase-design** — copy `SKILL.md` + `DEEPENING.md` + `DESIGN-IT-TWICE.md`. Minimal edits.
  Add attribution header. Foundation vocabulary; port first.
- **domain-modeling** — copy `SKILL.md`. Locate and port the referenced `CONTEXT-FORMAT.md` and
  `ADR-FORMAT.md` templates (their source path is not yet confirmed — a fetch task for
  implementation, see §10 gap G3). Define the boundary vs `signal`: `signal` explores *what to
  build*; `domain-modeling` crystallizes *how we name it* and owns `CONTEXT.md`.
- **tdd** — copy `SKILL.md` + `tests.md` + `mocking.md`. Keep the optional `CONTEXT.md`
  reference. Document the boundary vs verity: `tdd` is the red-green build loop *during*
  implementation; verity is diff-scoped hardening *after*. They compose.
- **diagnosing-bugs** — copy `SKILL.md` + `scripts/hitl-loop.template.sh`. Clean; no tracker.
- **code-review** — copy `SKILL.md`. **Rewire the spec source**: replace the
  `docs/agents/issue-tracker.md` lookup + "run `/setup-matt-pocock-skills`" prompt with
  file-based spec discovery (a `signal` brief in `docs/dashworthy/engineering/specs/`, or a
  user-supplied path — see §5.1). Keep the
  two-axis (Standards + Spec) structure and parallel sub-agents. Note coexistence with the
  user's separately-installed review plugins (different marketplaces; no conflict, but the
  `code-review` name will appear twice in the skill list during the superpowers-removal
  transition — acceptable).
- **improve-codebase-architecture** — copy `SKILL.md` + `HTML-REPORT.md`. Convert to a
  `/improve-codebase-architecture` command (it is `disable-model-invocation: true`). **Sever the
  `grill-with-docs` dependency**: replace the grilling loop with invocations of `codebase-design`
  (interface exploration) and `domain-modeling` (CONTEXT.md/ADR updates). Keep the self-contained
  HTML report (Tailwind + Mermaid via CDN, written to a temp dir).
- **prototype** — copy `SKILL.md` + `LOGIC.md` + `UI.md`. Neutralize tracker references:
  "document the validated decision in the issue" → "document it in the brief/spec" (file-based).
- **wizard** — copy `SKILL.md` + `template.sh` (into `scripts/wizard-template.sh`). Add a
  `/wizard` command that invokes the skill. Note the `gh` CLI runtime dependency.
- **research** — copy `SKILL.md`. Background-agent dispatch; writes a cited Markdown file
  following repo conventions. Clean.
- **resolving-merge-conflicts** — copy `SKILL.md`. git-only; clean.

### 6.3 Ported Matt productivity skills (realize as pure commands, §5.2)

Source category is `skills/productivity/` (not `engineering/`); attribute the same way (§9).
Each is `disable-model-invocation: true` upstream → a `commands/<name>.md` here.

- **handoff → `/handoff`** — compact the conversation into a handoff document for a successor
  session. Keep the `argument-hint` ("What will the next session be used for?"). Keep writing to
  the OS temp dir (ephemeral cross-session context; deliberately not a repo artifact), and keep
  the "suggested skills" section — but update those suggestions to reference `engineering:`
  skills. Keep secret redaction. Reference existing artifacts under
  `docs/dashworthy/engineering/specs|plans/`, `CONTEXT.md`, `docs/adr/` rather than duplicating.
- **to-questionnaire → `/to-questionnaire`** — turn an unanswerable decision into a questionnaire
  for someone else. Keep writing `to-questionnaire-<slug>.md` to the current directory. Note the
  natural pairing with `signal`: when discovery surfaces a question the user cannot answer, this
  externalizes it.
- **wait-what → `/wait-what`** — comms repair. Reads `CONTEXT.md`/`CONTEXT-MAP.md` (our adopted
  substrate, D5), writes nothing. Keep the ASD-STE100 Simplified-Technical-English framing.

### 6.4 Authored superpowers-style planning + execution (not ported)

Per the user's directive ("for planning and implement, follow more of the superpowers style"),
these two are **authored fresh in superpowers' style**, not copied from any repo (license note,
§9). They replace Matt's dropped `to-spec`/`to-tickets`/`wayfinder`/`implement`.

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

## 7. Directory layout

```
engineering/
├── .claude-plugin/plugin.json
├── README.md                         pipeline overview + process diagram + non-guarantees
├── NOTICE                            MIT attribution to Matt Pocock for ported skills
├── commands/
│   ├── signal.md
│   ├── vernacular.md
│   ├── improve-codebase-architecture.md
│   ├── implement.md                  wrapper → executing-plans
│   ├── wizard.md
│   ├── handoff.md                    productivity (pure command, §5.2)
│   ├── to-questionnaire.md           productivity (pure command, §5.2)
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
    └── resolving-merge-conflicts/
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

## 9. Licensing & attribution

- Repo stays MIT (compatible with Matt's MIT).
- Add a top-level `engineering/NOTICE` crediting Matt Pocock (MIT © 2026) for the ported skills,
  listing which skills were derived from his repo — from both `skills/engineering/` and
  `skills/productivity/`.
- Each ported skill carries a short attribution line (frontmatter comment or a note near the
  top) pointing to the upstream source.
- The dashworthy-original skills (signal/verity/vernacular) need no such line.
- **`writing-plans` / `executing-plans` are authored fresh in superpowers' *style*, not copied.**
  If any `superpowers` text is reused verbatim, check its license first and attribute
  accordingly; the intent is an independent implementation of the same approach, which needs no
  attribution. Note this provenance in the `NOTICE` for clarity.

## 10. Non-guarantees (house style)

This plugin explicitly does **not**:

- Replace all of `superpowers`' connective tissue yet — worktrees, finishing-a-branch, the
  verification-before-completion discipline, a general parallel-agent dispatch primitive,
  skill-writing, and skill-discovery remain deferred (§11). (Planning and execution **are**
  provided, via authored `writing-plans` / `executing-plans` — §6.4.)
- Integrate with any issue tracker. All artifacts are files.
- Require `CONTEXT.md`/ADRs — the design/build skills read them when present, never demand them.
- Persist Tier-2 output — `.engineering/<run>/…` is gitignored runtime scratch, safe to delete.

## 11. Gaps surfaced (per the "identify gaps" instruction)

| # | Gap | Disposition |
|---|---|---|
| G1 | ~~Planning gap.~~ **Resolved in this spec.** Authored superpowers-style `writing-plans` + `executing-plans` (§6.4) close the brief→plan→execute path; plans land in `docs/dashworthy/engineering/plans/`. | Build here, not deferred. |
| G2 | **Connective tissue.** worktrees, finishing-a-branch, verification-before-completion, dispatching-parallel-agents, writing-skills, using-superpowers have no equivalent in Matt's set or dashworthy. | **Follow-up spec.** Some may be portable from `superpowers` itself — needs a license check on the `superpowers` source before copying. |
| G3 | **CONTEXT/ADR templates.** `domain-modeling` references `CONTEXT-FORMAT.md`/`ADR-FORMAT.md`; their upstream source path is unconfirmed. | Implementation task: locate in Matt's repo (likely under `setup-matt-pocock-skills/`) and port, or author dashworthy versions. |
| G4 | **`grill-with-docs` removal.** `improve-codebase-architecture` leans on it. | Rewire to `codebase-design` + `domain-modeling` (§6.2). Verify the loop still terminates sensibly. |
| G5 | **Transition-period name collisions.** While `superpowers` is still installed, some ported skills (tdd↔test-driven-development, code-review↔requesting-code-review) will appear alongside their `superpowers` counterparts. | Acceptable during migration; resolves when `superpowers` is removed. Document in README. |
| G6 | ~~`implement` stranding.~~ **Resolved.** Superseded by authored `writing-plans` + `executing-plans` (§4 note, §6.4). | Build here, not deferred. |
| G7 | **Run-context mechanism (new).** Run-first Tier-2 (§5.3) introduces the shared `.engineering/.current-run` pointer — the one piece of cross-phase state. Risk: phases must read/create it identically, or a run fragments across ids. | Implementation must give every absorbed skill the same read-or-create-pointer step; add a test that two phases in one session share a `<run>`. |

### Follow-up spec (documented, not built here)

A second plugin/spec — working title `scaffold` or an addition to `engineering` — covering the
remaining **G2 connective tissue**: worktrees, finishing-a-branch, verification-before-completion,
a general parallel-agent dispatch primitive, skill-writing, and skill-discovery — which together
finish the `superpowers` removal. (Planning/execution are no longer part of the follow-up; they
ship here per §6.4.)

## 12. Out of scope

- Removing the `superpowers` plugin itself (that happens once the follow-up spec lands and the
  replacement is proven in daily use).
- Any change to `verity`'s or `vernacular`'s internal proof mechanics beyond re-namespacing.
- Rewriting Matt's skill *prose* into dashworthy voice — port faithfully first; voice
  alignment is a later, optional pass.
- **`git-guardrails-claude-code` and `setup-pre-commit`** (Matt's `skills/misc/`). These are
  repo-guardrail / hygiene tooling, not SDLC-pipeline phases: git-guardrails is a Claude-Code
  PreToolUse hook + `settings.json` entry that blocks destructive git ops; setup-pre-commit
  bootstraps Husky + lint-staged + Prettier. They belong in the marketplace but **not in the
  engineering plugin** — candidate for a separate small `guardrails` (or similar) plugin, its
  own spec. Recorded here so they are not lost.

## 13. Build sequence (input to writing-plans)

1. Scaffold `engineering/` — `plugin.json`, `README.md` skeleton, `NOTICE`. Add `.engineering/`
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
5. Port `codebase-design` (foundation vocabulary) with attribution.
6. Port `domain-modeling` + CONTEXT/ADR templates (resolve G3).
7. Port `tdd`, `diagnosing-bugs`, `code-review` — rewire `code-review` spec source to
   `docs/dashworthy/engineering/specs/` (§6.2).
8. Port `improve-codebase-architecture` as a command — sever `grill-with-docs` (G4).
9. **Author** `writing-plans` (→ `docs/.../plans/`) and `executing-plans` (+ `/implement`,
   working state under `.engineering/<run>/implement/`) in superpowers style (§6.4).
10. Port `prototype` (neutralize tracker), `research`, `resolving-merge-conflicts`, `wizard`
    (+ `/wizard`).
11. Port the three productivity commands as pure `commands/*.md` (§5.2, §6.3): `/handoff`,
    `/to-questionnaire`, `/wait-what`.
12. Rewrite `marketplace.json` (single entry) + root `README.md` (deprecation redirect +
    pipeline overview + non-guarantees).
13. Delete absorbed top-level `signal/`, `verity/`, `vernacular/` dirs.
14. Verify: every command (8) resolves; every skill frontmatter valid; hook fires; vernacular
    `tests/` pass; a run-context test shows two phases in one session share a `<run>` (G7); no
    dangling `signal:`/`verity:`/`vernacular:` refs or `.signal`/`.verity`/`.vernacular` paths;
    `.engineering/` gitignored; NOTICE + per-skill attribution present.
