#!/bin/sh
# Template — copy into .engineering/<run>/... before editing; do not run in place.
#
# One-prompt-at-a-time wizard skeleton: each pass through the loop announces a single
# step, asks the human exactly one question, and only moves on once that question has an
# answer. No step's question is drafted, let alone shown, until the step before it is
# answered.
#
# Some procedures have steps that are GitHub-backed — creating a branch that tracks a PR,
# reading an issue, checking review status — and those need the `gh` CLI on PATH and
# authenticated. This template does not check that once at the top; `require_gh` below is
# called immediately before the specific step that needs it, so a session that expires
# partway through fails at the step that actually needed `gh`, not silently or at the end.
#
# This file is a skeleton, not a finished wizard. The numbered steps below are
# placeholders — replace them with the actual steps of the procedure you're conducting,
# and the actual questions each one asks, once you've copied this somewhere safe to edit.
# Nothing here writes a log or a tracker file: this template's only state is which step
# the loop is currently on and the answers held in shell variables for the run in
# progress, the same way the wizard skill itself keeps state in the working context
# conducting it, not in a separate record.
#
# Usage (after copying):
#   sh wizard-template.sh

set -e

STEP=0
TOTAL=0 # placeholder — set to the real number of steps once they're filled in

# Print one line the human sees before being asked anything, so they always know where
# in the procedure they are before the question itself arrives.
announce() {
  echo "--- step $STEP of $TOTAL: $1 ---" >&2
}

# Ask exactly one question, wait for exactly one reply. Runs on stderr/stdin so a step's
# own command output (for example, output from `gh`) can still use stdout cleanly.
ask() {
  printf '%s ' "$1" >&2
  read -r reply
  printf '%s' "$reply"
}

# Confirm `gh` is on PATH and authenticated before a GitHub-backed step runs. Call this
# immediately before that step, not once at the top of the script — see the header
# comment above for why.
require_gh() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "This step needs the gh CLI, and it isn't on PATH. Install it, then re-run this step." >&2
    exit 1
  fi
  if ! gh auth status >/dev/null 2>&1; then
    echo "This step needs gh to be authenticated. Run 'gh auth login', then re-run this step." >&2
    exit 1
  fi
}

# --- Steps: replace this placeholder list with the procedure's real steps ---

TOTAL=3

STEP=1
announce "placeholder step one"
answer=$(ask "Replace with the real question for step 1:")
# ... act on "$answer" here before moving on ...

STEP=2
announce "placeholder step two (GitHub-backed)"
require_gh
answer=$(ask "Replace with the real question for step 2:")
# e.g.: gh issue view "$answer"

STEP=3
announce "placeholder step three"
answer=$(ask "Replace with the real question for step 3:")
# ... act on "$answer" here before moving on ...

echo "Wizard done. $TOTAL step(s) walked." >&2
