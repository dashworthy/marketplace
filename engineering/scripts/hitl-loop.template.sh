#!/bin/sh
# Template — copy into .engineering/<run>/... before editing; do not run in place.
#
# Human-in-the-loop reproduce/observe cycle, for the class of bug that no script can
# reproduce unattended: a UI interaction, a physical control, a step only a person on
# the other end can perform. Each pass through the loop asks a human to do one thing,
# captures what they observed, and asks whether the failure showed up at that step.
# The loop ends when a pass pins the failure to a specific step, or when the human
# gives up narrowing it further for this session.
#
# This file is a skeleton, not a finished tool. The prompts below are placeholders —
# fill in what "one step" means for the reproduction you're chasing, and what "pinned
# down" means for this failure, once you've copied it somewhere safe to edit.
#
# Usage (after copying):
#   sh hitl-loop.sh
#
# Every pass appends one record to $LOG, so a finished session is a single file you can
# hand to diagnosing-bugs as the evidence a hypothesis is checked against.

set -e

LOG="./hitl-loop.log"
STEP=0

# Append one timestamped record to the log. Called after every prompt so the log is a
# complete transcript even if the human stops the loop early.
log() {
  printf '%s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >>"$LOG"
}

# Print a prompt on stderr (so stdout stays free if a step's own observation is a
# command's output) and return the human's typed reply.
ask() {
  printf '%s ' "$1" >&2
  read -r reply
  printf '%s' "$reply"
}

echo "HITL reproduction loop starting. Log: $LOG" >&2
log "session start"

while :; do
  STEP=$((STEP + 1))
  echo "--- step $STEP ---" >&2

  # 1. Tell the human what to try next. Replace this placeholder with the actual next
  #    step in the sequence you're narrowing — a click, a command, a physical action.
  instruction=$(ask "Step $STEP: what should the human do next? (blank to stop)")
  if [ -z "$instruction" ]; then
    log "session end: stopped by human at step $STEP"
    break
  fi
  log "instruction: $instruction"

  echo "Perform: $instruction" >&2
  echo "Press enter once it's done." >&2
  read -r _unused

  # 2. Capture what the human saw. This is the evidence line — push for something
  #    specific ("dialog read: Connection refused"), not "it broke" or "nothing happened".
  observation=$(ask "What did you observe?")
  log "observation: $observation"

  # 3. Ask whether this step's observation IS the failure, or just a step along the way
  #    to it. Only a "yes" here ends the loop with something pinned down.
  verdict=$(ask "Did the failure show up at this step? (y/n)")
  log "verdict: $verdict"

  case "$verdict" in
    [Yy]*)
      log "PINNED at step $STEP: $instruction -> $observation"
      echo "Failure pinned to step $STEP. Full record: $LOG" >&2
      break
      ;;
    *)
      # Not yet — loop again. The next pass asks for the next step in the narrowing,
      # informed by what this one just ruled out.
      ;;
  esac
done

echo "Done. Full record in $LOG." >&2
