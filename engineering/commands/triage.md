---
description: Triage a reported defect — verify it reproduces, isolate it to a domain concept, and route to the smallest next step.
argument-hint: the problem or defect being reported
---

Invoke the **`engineering:triage`** skill and follow it exactly: establish or join a run,
verify the report reproduces before isolating anything, isolate only as far as routing
needs, then hand off per `references/spec-decision.md` — a quick fix, a grill through
`signal`, a design conversation, or a closed file with the reason on record.

Report: $ARGUMENTS

If no report was provided above, ask the user what's going wrong before proceeding.
