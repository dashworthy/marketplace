---
name: to-spec
description: "[Discovery] The single writer of Tier-1 specs. Given an entrance's accumulated material — a signal discovery brief or a triage isolation record, by path or inline — render the standard spec document to docs/dashworthy/engineering/specs/. Invoked by conducting-discovery at the end of signal, and by triage when a fix is spec-worthy; not a general-purpose writer and does not self-trigger on arbitrary requests."
---

# To Spec

Say this first, plainly: `Using the to-spec skill to write the spec.`

## What this guarantees

One thing: given an entrance's finished material, this skill writes exactly one Tier-1
spec, in exactly one format, at exactly one path. It is the only skill in this plugin
permitted to write to `docs/dashworthy/engineering/specs/`. A spec found anywhere else
was not written by this skill and is not a Tier-1 spec.

Nothing else is guaranteed. Read the non-guarantees below before assuming this skill
does more than that.

## Inputs

Accept either:
- a **path** to Tier-2 material — `.engineering/<run>/signal/brief.md`, or
  `.engineering/<run>/triage/…` — or
- the material **inline**, already sitting in context.

One of the two must be present. If neither is — no path resolves, and nothing has been
supplied inline — refuse and say so. Do not proceed on a guess about what was meant, and
do not go looking for material elsewhere. This skill starts only from what it is handed.

## Where it writes

Tier-1, and only Tier-1: `docs/dashworthy/engineering/specs/<YYYY-MM-DD>-<topic>.md`.

`<topic>` is the active run's slug when a run is available. The pointer
`.engineering/.current-run` holds the full run id in the form `<YYYY-MM-DD>-<slug>`; use only
the `<slug>` portion — everything after the leading `YYYY-MM-DD-` date prefix — not the whole
pointer value, or the date is duplicated in the filename. When no run is active, fall back to a
slug derived from the spec's own title. `<YYYY-MM-DD>` in the filename is today's date, not the
run's start date, if the two differ.

This skill never writes into `.engineering/`. That tree belongs to the entrances — it is
their Tier-2 scratch space. A spec landing there instead of under
`docs/dashworthy/engineering/specs/` is not a partial version of this skill's job; it is
a different job this skill does not do.

## How it renders

Follow `SPEC-FORMAT.md`, in this same directory — do not restate its shape here or
reinvent it inline. Every section in that file gets filled; a section with nothing to
say gets a line explaining why, not silence.

Two source shapes map onto the one format:
- a **signal** brief's §1–§8 map onto the spec's §1–§8 directly, section for section.
- a **triage** isolation record maps onto the same eight sections with two repurposed:
  §1 becomes the reproduced problem, and §6 becomes the chosen fix approach — including
  why the smaller fixes on the table were rejected, not only the one that won.

## What this does not do

- It does not **design**. An approach worth writing into §6 was already argued out in
  `brainstorming` before this skill ever runs; this skill transcribes that outcome, it
  does not weigh alternatives itself.
- It does not **plan**. Breaking the approved approach into steps is `writing-plans`,
  downstream of the spec this skill produces.
- It does not **interrogate**. If the material handed to it is missing something a
  section needs, this skill does not go ask questions to fill the gap — that already
  happened, or should have, upstream in `signal` or `triage`.
- It does not invent. Where the source material is thin, the corresponding section says
  so, and the gap goes into §8 as an open question. A confident-sounding sentence with no
  source behind it is worse than an honest blank.

## Handoff

Once the spec is written, print its path and stop. The caller — `conducting-discovery`
at the end of signal, or `triage` when a fix is spec-worthy — takes it from there,
ordinarily into `writing-plans`. This skill does not chain into planning itself, and does
not summarize the spec it just wrote beyond that one path.
