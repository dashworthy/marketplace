#!/bin/sh
# SessionStart hook for the engineering plugin: the entrance bootstrap.
#
# Puts the two front doors in front of the model at the start of every conversation,
# the way superpowers surfaces its process skills. Injects guidance only; it never
# blocks, never touches git, never reads or writes a file, and does not depend on jq.

message='Engineering pipeline is available. Before building from a request, pick the entrance:\n- A feature or a vague ask: run `/signal` (discovery to a brief).\n- A reported bug or defect: run `/triage` (isolate with minimal effort).\nEither way, invoke the right skill before acting (see the `using-skills` foundation). Do not jump straight to code on non-trivial work.'

printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$message"

exit 0
