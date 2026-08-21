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
| D11 | Defer `superpowers` connective tissue + the planning gap to a follow-up spec | Keeps this spec to one coherent deliverable |

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
| `to-spec` | **Drop** | HEAVY tracker coupling; `signal` already does discovery→brief (a file) |
| `wayfinder` | **Drop** | HEAVY tracker coupling; a tracker methodology, not worth it file-based |
| `to-tickets` | **Drop** | HEAVY tracker coupling; planning value overlaps `signal`'s `sequencing-requirements` |
| `implement` | **Drop from this spec / revisit in follow-up** | Light coupling but its value is the planning→build bridge, which is the deferred planning gap; wiring it now without a planner is premature |
| `triage` | **Drop** | Needs Matt's tracker + label infra |
| `grill-with-docs` | **Drop** | Interactive grilling loop; its role inside `improve-codebase-architecture` is replaced by `codebase-design` + `domain-modeling` |
| `ask-matt` | **Drop** | Personal routing skill referencing Matt's own system |
| `setup-matt-pocock-skills` | **Drop** | Seeds the tracker substrate we reject |

> Note on `implement`: an earlier draft kept it as a `/implement` command. On closer read its
> job is to run work *from a spec or tickets* through `/tdd` + `/code-review` — i.e. it is the
> execute half of the planning→execute bridge that `superpowers` `executing-plans` owns. With
> the *planning* half deferred (§11), shipping `implement` alone would strand it. It moves to
> the follow-up spec alongside the planner. **This is a change from the approved roster; flag
> for user confirmation during spec review.**

## 5. Target architecture — the pipeline

| Phase | Skills | Command(s) |
|---|---|---|
| **1 · Discover** | `conducting-discovery`, `interrogating-requirements`, `expanding-scope`, `sequencing-requirements` (signal); `domain-modeling` | `/signal` |
| **2 · Design** | `codebase-design`, `improve-codebase-architecture`, `prototype` | `/improve-codebase-architecture` |
| **3 · Build & review** | `tdd`, `diagnosing-bugs`, `code-review` | — |
| **3.5 · Harden tests** | `conducting-test-hardening`, `auditing-test-gaps`, `verifying-test-integrity`, `writing-tests-from-brief` (verity) | — (session-start hook) |
| **4 · Document** | `clarifying-docblocks`, `rewriting-docblock-prose`, `verifying-docblock-claims` (vernacular) | `/vernacular` |
| **Cross-cutting** | `wizard`, `research`, `resolving-merge-conflicts` | `/wizard` |

Shared knowledge layer across phases 2–4: `CONTEXT.md` + `docs/adr/`, seeded and maintained by
`domain-modeling`, read (never required) by `tdd`, `code-review`, `codebase-design`,
`improve-codebase-architecture`.

Skill count: ~21 (signal 4 + verity 4 + vernacular 3 + Matt 10). Commands: 4
(`/signal`, `/vernacular`, `/improve-codebase-architecture`, `/wizard`). Hook: 1 (verity
session-start). If `implement` is reinstated during review, +1 skill and +1 command.

### 5.1 File-artifact conventions

The pipeline's file outputs mirror `superpowers`' spec/plan convention, namespaced under the
marketplace and plugin so they never collide with another tool's artifacts:

| Artifact | Path | Produced by | Consumed by |
|---|---|---|---|
| Discovery brief / spec | `docs/dashworthy/engineering/specs/` | `signal` (brief), any spec-writing step | `code-review` (Spec axis), `implement` (follow-up), humans |
| Implementation plan | `docs/dashworthy/engineering/plans/` | the deferred planner (G1, follow-up spec) | `implement` (follow-up), humans |
| Domain glossary | `CONTEXT.md` (repo root) | `domain-modeling` | design/build skills |
| Decision records | `docs/adr/` | `domain-modeling` | design/build skills |

Naming within `specs/`/`plans/` follows `YYYY-MM-DD-<topic>.md` (this design doc itself lives
at `docs/dashworthy/engineering/specs/2026-08-21-engineering-plugin-design.md`). Consequences:

- **`signal` absorption** must point its brief output at `docs/dashworthy/engineering/specs/`
  (confirm signal's current output path during the move and redirect it there).
- **`code-review` rewiring** (§6.2) reads its Spec-axis source from
  `docs/dashworthy/engineering/specs/` (plus user-supplied paths), replacing the tracker lookup.
- The `plans/` directory is **reserved now** even though the planner that writes to it is
  deferred to the follow-up spec (G1) — so the convention is stable before the tool exists.

## 6. Adaptation notes, per source

### 6.1 Absorbed dashworthy plugins (behavior-preserving move)

- **signal → engineering.** Move 4 skills + `commands/signal.md`. Re-namespace every internal
  reference from `signal:` to `engineering:` (the `/signal` command dispatches
  `signal:conducting-discovery`; the conductor dispatches the other three). Redirect the brief
  output to `docs/dashworthy/engineering/specs/` (§5.1). No other behavior change.
- **vernacular → engineering.** Move 3 skills + `commands/vernacular.md` + `scripts/reconcile.py`
  + `tests/` (`e2e.sh`, `reconcile.sh`, `validate.sh`). Re-namespace. Keep the reconcile
  test suite green — it is the plugin's proof harness.
- **verity → engineering.** Move 4 skills + `hooks/hooks.json` + `hooks/session-start.sh` +
  the `conducting-test-hardening/references/*`. Re-namespace. The session-start hook injects
  the "Verity applies once implementation work is finished… invoke `conducting-test-hardening`"
  reminder — update the skill reference to the new namespace and confirm the hook still fires.

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
│   └── wizard.md
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
  listing which skills were derived from his repo.
- Each ported skill carries a short attribution line (frontmatter comment or a note near the
  top) pointing to the upstream source.
- The dashworthy-original skills (signal/verity/vernacular) need no such line.

## 10. Non-guarantees (house style)

This plugin explicitly does **not**:

- Replace `superpowers`' connective tissue yet — worktrees, finishing-a-branch, the
  verification-before-completion discipline, parallel-agent dispatch, skill-writing,
  skill-discovery. See §11.
- Provide a planning step between `signal`'s brief and implementation. `signal` stops at the
  brief; nothing here turns a brief into an ordered plan. See §11 / gap G1.
- Integrate with any issue tracker. All artifacts are files.
- Require `CONTEXT.md`/ADRs — the design/build skills read them when present, never demand them.

## 11. Gaps surfaced (per the "identify gaps" instruction)

| # | Gap | Disposition |
|---|---|---|
| G1 | **Planning gap.** `signal` brief → implementation has no planner (what `superpowers` `writing-plans` does today). | **Follow-up spec.** Candidate: port `to-tickets`' local-file mode as a file-based planner, or author a dashworthy planner. Writes to `docs/dashworthy/engineering/plans/` (path reserved now, §5.1). |
| G2 | **Connective tissue.** worktrees, finishing-a-branch, verification-before-completion, dispatching-parallel-agents, writing-skills, using-superpowers have no equivalent in Matt's set or dashworthy. | **Follow-up spec.** Some may be portable from `superpowers` itself — needs a license check on the `superpowers` source before copying. |
| G3 | **CONTEXT/ADR templates.** `domain-modeling` references `CONTEXT-FORMAT.md`/`ADR-FORMAT.md`; their upstream source path is unconfirmed. | Implementation task: locate in Matt's repo (likely under `setup-matt-pocock-skills/`) and port, or author dashworthy versions. |
| G4 | **`grill-with-docs` removal.** `improve-codebase-architecture` leans on it. | Rewire to `codebase-design` + `domain-modeling` (§6.2). Verify the loop still terminates sensibly. |
| G5 | **Transition-period name collisions.** While `superpowers` is still installed, some ported skills (tdd↔test-driven-development, code-review↔requesting-code-review) will appear alongside their `superpowers` counterparts. | Acceptable during migration; resolves when `superpowers` is removed. Document in README. |
| G6 | **`implement` stranding.** (§4 note) Shipping the execute half without the plan half is premature. | Moved to follow-up spec with G1; **confirm with user during spec review.** |

### Follow-up spec (documented, not built here)

A second plugin/spec — working title `scaffold` or an addition to `engineering` — covering
G1 (planner) + G2 (connective tissue) + G6 (`implement`), which together finish the
`superpowers` removal.

## 12. Out of scope

- Removing the `superpowers` plugin itself (that happens once the follow-up spec lands and the
  replacement is proven in daily use).
- Any change to `verity`'s or `vernacular`'s internal proof mechanics beyond re-namespacing.
- Rewriting Matt's skill *prose* into dashworthy voice — port faithfully first; voice
  alignment is a later, optional pass.

## 13. Build sequence (input to writing-plans)

1. Scaffold `engineering/` — `plugin.json`, `README.md` skeleton, `NOTICE`.
2. Absorb `signal` (move + re-namespace + verify `/signal` resolves).
3. Absorb `vernacular` (move skills/command/`reconcile.py`/tests + re-namespace + run
   `tests/` green).
4. Absorb `verity` (move skills/hooks/references + re-namespace + verify session-start hook
   fires and points at the new `conducting-test-hardening`).
5. Port `codebase-design` (foundation vocabulary) with attribution.
6. Port `domain-modeling` + CONTEXT/ADR templates (resolve G3).
7. Port `tdd`, `diagnosing-bugs`, `code-review` — rewire `code-review` spec source to
   file-based (§6.2).
8. Port `improve-codebase-architecture` as a command — sever `grill-with-docs` (G4).
9. Port `prototype` (neutralize tracker), `research`, `resolving-merge-conflicts`, `wizard`
   (+ `/wizard`).
10. Rewrite `marketplace.json` (single entry) + root `README.md` (deprecation redirect +
    pipeline overview + non-guarantees).
11. Delete absorbed top-level `signal/`, `verity/`, `vernacular/` dirs.
12. Verify: every command resolves; every skill frontmatter valid; hook fires; vernacular
    `tests/` pass; no dangling `signal:`/`verity:`/`vernacular:` namespace references; NOTICE
    + per-skill attribution present.
