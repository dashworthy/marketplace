---
description: Conduct a human through a multi-step interactive procedure, one prompt at a time.
argument-hint: [what procedure to run, optional — the skill asks if none is given]
---

Invoke the **`engineering:wizard`** skill and follow it exactly: announce each step, ask the
human exactly one question, wait for the answer, then move to the next step — backed by
`scripts/wizard-template.sh`, with the `gh` CLI available and authenticated for any
GitHub-backed step.

Procedure: $ARGUMENTS

If no procedure was named above, ask the human what they want to be walked through before
proceeding.
