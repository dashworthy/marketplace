---
name: resolving-merge-conflicts
description: "Reconcile a git merge or rebase conflict deliberately: understand both sides' intent, resolve to preserve both behaviors, and verify with tests before continuing. Use when git reports conflicts. Git-only; cross-cutting."
---

# Resolving Merge Conflicts

Say this first, plainly: `Using the resolving-merge-conflicts skill to reconcile this deliberately, not fast.`

## What this guarantees

One thing: given a git merge or rebase stopped on a conflict, this skill produces a
resolution where both sides' changes are understood before either one is kept, changed, or
dropped — and a test run confirming the resolved state before the operation is allowed to
continue. It does not guarantee the conflict is quick, or that the two sides turn out to be
compatible after all. It guarantees the resolution reflects what both branches were actually
trying to do, not just whichever branch's text was easier to keep.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill picks
which commit was "right," runs the merge for you, or replaces review of the result.

## Read both sides' intent before editing

Git hands you marker text — `<<<<<<<`, `=======`, `>>>>>>>` — and marker text describes only
where two changes collided, not why either one was made. Editing straight from the markers
answers a different, easier question than the one actually in front of you: which lines look
less wrong, rather than what each side was for. Before touching a single line inside a
conflict, find out what each side was doing — the commit(s) that touched this hunk on both
branches, their messages, the diff around them, not just the few lines git chose to fence off.
A conflict is two changes that happened to land on the same lines; on its own it says nothing
about whether those two changes actually contradict each other.

## Resolve to keep both behaviors

Once both sides' intent is understood, the resolution that keeps both is the default, not the
exception. Two changes usually address different concerns that happened to share a location —
one fixed a bug in this function, the other renamed a parameter it uses — and a resolution
that quietly drops one of them to make the markers go away is a regression wearing a
successful merge's clothes. Never blind-accept a side, and know what each command actually touches before reaching for
it. `git checkout --ours` / `--theirs -- <path>` resolves the *whole file* to one side —
every conflicting hunk in it, including any you haven't read yet, not just the hunk in front
of you — so it is safe only once every conflicting hunk in that file has been read and
confirmed redundant, never as a shortcut for a single hunk you've vetted. `git merge -X ours`
/ `-X theirs` is the one that acts per hunk, biasing automerge hunk by hunk during the merge
itself, but the same rule still holds at that finer grain: a hunk only gets resolved this way
once it's already been read and confirmed redundant. Neither command is a way to skip reading
a hunk; both are a closing move for reading already done, never a substitute for it.
If, having read both sides, one truly does supersede the other — same intent, a later and
better attempt — write that down as the reason for the resolution; it is a conclusion you
reached, not a default you reached for.

## Run the tests before `--continue`

A resolution that only "looks right" once you stop staring at it is a claim, not a result.
Before `git merge --continue`, `git rebase --continue`, or committing a resolved merge, run
the project's tests against the resolved working tree. `--continue` moves the operation past
this conflict — to the next one, or to done — and once it has moved past, the state you
resolved stops being the thing in front of you; whatever was wrong with it now travels forward
as someone else's problem, at a point where it's harder to tell which of the last several
hunks introduced it. A passing suite doesn't prove the resolution is correct, but a failing
one proves it isn't, and that proof is cheapest to get right now, before you continue, while
the conflicted hunk is still open in front of you and easy to fix.

## Git-only; no tracker

Everything this skill touches lives inside git's own conflict-resolution state — the working
tree, the index, `MERGE_HEAD` or `REBASE_HEAD` — and nowhere else. There is no ticket to file,
no run-scoped scratch file to write, no separate record to keep in sync with what actually
happened. The resolved diff and the commit it lands in are the record, exactly as they would
be for any other change; if the resolution needs revisiting later, git's own history —
`git log`, the reflog — is what it's read back from.

## What this does not do

- It does not **decide which side wins.** Reading both sides' intent is this skill's job;
  weighing which behavior a project actually wants going forward, when the two truly cannot
  coexist, is a judgment call for whoever owns that code, made with the evidence this skill
  gathered, not by this skill on its own.
- It does not **start or drive the merge or rebase.** This skill begins once git has already
  stopped on a conflict. Choosing to merge, choosing to rebase, and choosing when either
  happens are decisions made before this skill's first line runs.
- It does not **keep any record outside git.** No ticket, no tracker, no scratch file — see
  `## Git-only; no tracker` above.
- It does not **substitute for code review.** A test suite passing after `--continue` shows
  the resolved state behaves as tested, not that it was the best possible resolution; review
  of the merge commit still happens the way it would for any other change.
