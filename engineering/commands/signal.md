---
description: Run the signal discovery pipeline (interrogate → sequence) on a request and produce a dependency-ordered brief.
argument-hint: what you want built (a feature / build / change request)
---

# signal

Run the full signal discovery pipeline for the request below by invoking the **`engineering:conducting-discovery`** skill and following it exactly. signal is opt-in: it runs here because the user asked for it, so run the whole pipeline rather than shortcutting to plain brainstorming.

The pipeline you are conducting:

There is **one artifact, `brief.md`, with two writers.** Stage 1 writes §1–§6 in the main thread; stage 2 appends §7 and §8 from a subagent. Neither rewrites the other's sections.

1. **Interrogate** — `engineering:interrogating-requirements` in the main thread. Probe by offering the conventional baseline and mining the correction, one question per turn, keeping `open-threads.md` current as you go. Do not advance until the gate is met: at least 3 rounds AND all six coverage dimensions filled. **The moment it is met, write `brief.md` §1–§6** — before any dispatch, so the interrogation is durable. Then run the expansion beat: dispatch `engineering:expanding-scope` with those requirements inline, relay its candidates as one accept/reject/defer checklist, and rewrite §1–§6 in full with every disposition in §5. Stop at §6.
2. **Sequence** — dispatch `engineering:sequencing-requirements` with the path to `brief.md` and the path to `open-threads.md`. It appends §7 (the work, in dependency order) and §8 (the handoff pointer), and never edits §1–§6. You receive a path; you do not read the file. On `OK`, dispatch `engineering:to-spec` with that same path — signal does not write the spec itself; `to-spec` renders the committed Tier-1 spec under `docs/dashworthy/engineering/specs/`.

**signal ends at the brief and the spec rendered from it.** Report both paths and stop. Do not design, plan, or build — hand off from there.

Invoke `engineering:conducting-discovery` now and begin.

Request: $ARGUMENTS

If no request was provided above, ask the user what they want built before proceeding.
