---
name: verification-before-completion
description: "[Foundation] Before claiming done, fixed, or passing, run the verification commands and confirm their output — show the proof, do not just assert the result. Use whenever you are about to report success. Complements test-hardening (which hardens the tests themselves). Model-invoked; no command."
---

# Verification Before Completion

Say this first, plainly: `Using the verification-before-completion skill to confirm the check
actually passed.`

## What this guarantees

One thing: no claim that something is done, fixed, or passing leaves this skill's hands without
a verification command having actually been run against the code's current state, and without
that command's output having actually been read — not predicted, not remembered from an earlier
run, not inferred from the diff looking right. Where that evidence does not exist yet, this
skill produces it before a success claim goes out, rather than either blocking the claim forever
or letting it through unverified.

Nothing else is guaranteed. Read `## What this does not do` below before assuming this skill
decides more than that.

## Run the check before saying it passed

The failure mode this closes is specific and common: a change looks obviously correct, so the
report says "done" or "tests pass" before the command that would establish that has been run at
all this session. Fix an off-by-one and the surrounding code can look fine on inspection, but the
only fact that actually proves it is the test suite exiting zero — a fact that does not exist
until it has been asked for. Guessing well is still guessing. Something not run has no output,
and no output is not evidence, however confident the guess behind it feels.

Work out what "the check" is from the task itself — a test suite, a linter, a type check, a
build, a manual reproduction of the bug that motivated the fix — and run whatever combination
actually exercises the change made. A check that only touches unrelated code, or one that passed
before the change and was never re-run after it, proves nothing about the change under review;
rerun it against the code as it stands now, not as it stood at the last green run.

## Read the output, not the exit code alone

An exit code is a summary somebody else already computed; whether it is the summary that belongs
to this run is exactly the question worth checking before leaning on it. Skimmed too fast, "0
failed" can sit atop a suite that silently skipped every test that touched the change, or a build
that emitted a warning about the exact symbol just edited, or a runner that reported success
because it never found any tests to collect in the first place. Read enough of the actual output
to know what ran and what it covered, not only whether the last line claimed success.

## Quote the decisive evidence

Before writing "passes" or "fixed" anywhere — a commit message, a PR description, a reply to the
user — put the specific line of output that supports it next to the claim. Not the whole log, and
not a paraphrase of what the log probably said: the shortest line that, on its own, proves the
claim true. `42 passed, 0 failed` earns the claim sitting next to it; "tests look good" does not,
because it describes a feeling about the output rather than the output itself. If no such line
can be found, that is the signal the check was never actually run, or was run against the wrong
target — go back and run it, rather than writing the claim anyway and hoping the gap goes
unnoticed.

## What this does not do

- It does not **decide what counts as verification** for a project it has never seen before. What
  command to run, and what output from it counts as evidence, is read from how the project
  already verifies itself — its test runner, its CI config, its existing conventions — not
  invented fresh each time this skill runs.
- It does not **write or harden tests.** `engineering:conducting-test-hardening` asks whether the
  test suite itself would catch a regression if one were introduced — a question about the
  tests' quality, asked once, typically near the end of a branch's life. This skill asks a
  narrower and far more frequent question: given the checks that already exist, did the one just
  run actually pass, on this code, just now. A branch can fail this skill's bar — nobody ran the
  suite before claiming done — with excellent tests behind it, and can pass this skill's bar —
  the suite ran and every line of its output was read — while the suite itself is thin and would
  let a real regression through unnoticed. The two failures are independent; this skill stands in
  front of only one of them.
- It does not **fix a failing check.** A red run reported honestly is this skill doing its job;
  working out what caused the failure and repairing it is separate work this skill hands back
  rather than absorbing itself.
- It does not **decide what "done" means for the task.** It only refuses to let a success claim
  about that task travel without the evidence that actually backs it.
