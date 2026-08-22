---
name: using-git-worktrees
description: "[Foundation] Ensure work happens in an isolated workspace before making changes: detect existing isolation, prefer the harness's native worktree tool, fall back to git worktree, and verify a clean baseline. Use at the start of any implementation task. Model-invoked; no command."
---

# Using Git Worktrees

Say this first, plainly: `Using the using-git-worktrees skill to isolate the workspace.`

## What this guarantees

One thing: before a single file changes, the work is happening in a workspace nothing
else depends on — its own checkout, on its own branch, separate from whatever the
surrounding session or a concurrent one is doing. A workspace that is already isolated
satisfies this exactly as well as one this skill creates from scratch; the guarantee is
about the end state reached, not about which of the two paths got there.

Nothing else is guaranteed. Read `## What this does not do` below before assuming this
skill decides more than where work happens.

## Detect existing isolation first

Creating a new workspace when one already exists wastes the setup work twice and, worse,
can leave two isolated copies of the same task drifting apart from each other. Before
doing anything else, work out whether isolation is already in place.

Two checks, in order:

1. **Ask the harness.** If the current session already shows an active worktree session —
   one this same session entered earlier — isolation is already satisfied. Skip straight
   to project setup below; there is nothing left to create.
2. **Check the checkout itself**, for a worktree nobody in this session created —
   inherited from an earlier session, or handed over by whoever started the task:
   ```
   git rev-parse --is-inside-work-tree
   git rev-parse --git-dir --git-common-dir
   git rev-parse --show-superproject-working-tree
   ```
   Not inside a working tree at all: there is nothing to detect, move on to creating one.
   Inside one: `--git-dir` and `--git-common-dir` printing the same path means this is the
   repository's one shared checkout, not isolated — proceed to creation. The two paths
   differing is the signature of a linked worktree, but check the third line before
   trusting it: a submodule's `.git` is also a file pointing somewhere else, the same
   surface shape as a linked worktree's, and `--show-superproject-working-tree` is what
   tells the two apart. A submodule reports a non-empty superproject path; a linked
   worktree reports nothing. Treat the mismatch as isolation already satisfied only when
   that third line comes back empty — a submodule checkout is usually the one shared copy
   the parent repository depends on, not a disposable branch safe to build a task on, and
   mistaking it for a worktree hands the task a workspace it was never meant to have.

Already isolated, by either check: skip workspace creation and go straight to project
setup below. Not isolated: continue to the next section.

## Prefer the harness's native worktree tool

If the harness exposes a dedicated worktree tool — `EnterWorktree` in this one — use it
ahead of raw `git worktree`. It creates the linked worktree, picks a branch, and switches
the session's working directory in a single step, and it already refuses to run again on
top of a worktree it created earlier in the same session — the harness doing part of the
detect-first check for you. Give it a name that says what the task is, not a timestamp or
a random string; whoever reads `git worktree list` later, or picks the work back up in a
fresh session, should be able to tell what it's for without opening it.

Pass a path into the same tool, instead of a name, when the target is a worktree that
already exists on disk but that this session has not entered yet — the case where the
git-level check in the previous section found one that nobody in this session created.

## Fall back to `git worktree` only if no native tool

No such tool in this harness, or it declines the request (for example, outside a git
repository with no VCS-agnostic hook configured): fall back to raw git.

```
git worktree add -b <branch-name> <path> [<start-point>]
```

Pick a branch name and a path that say what the task is, the same as above — this is a
plain git command standing in for the native tool, not a lesser version of it, so it
deserves the same care. `git worktree add` already refuses to check out a branch that is
checked out somewhere else; treat that refusal as information, not an obstacle to route
around. It means the isolation this skill is trying to build already exists in that other
worktree, and the right move is to use that one rather than force a second checkout of
the same branch. Change into the new path once it is created; nothing past this point
runs from the original directory.

## Run project setup and verify a clean baseline

A freshly isolated directory with nothing installed in it is not yet a workspace anyone
can build on. Run whatever this project uses to go from a bare checkout to something
runnable — dependency installation, a bootstrap script, generated files a build step
expects to find — before touching any part of the actual task.

Once setup finishes, run the project's test suite once, before making any change at all,
and note the result. This is not the task's verification step — that belongs to
`engineering:verification-before-completion`, later, run against the change actually
made. This run answers a narrower question: was the workspace clean before this task ever
touched it? A red baseline discovered now is information handed to whoever does the work
next; the same red baseline discovered after a change looks like something the change
caused, and untangling the two afterward costs far more than running the suite once up
front.

## Report readiness

Before any implementation work starts, say plainly where it is happening and what
condition it started in: the workspace's path and branch, whether it was created fresh or
already existed, and the baseline test result. A task that begins without this on the
record leaves the next reader — human or another skill — to re-derive it later from
whatever state the workspace happens to be in by then, which is strictly harder than
reading one line written down at the start.

## What this does not do

- It does not **keep the workspace isolated forever.** This skill establishes isolation
  once, at the start; nothing here polices later commands run from the wrong directory,
  or stops some other process from writing into the same checkout.
- It does not **decide when the task is done, or verify its result.** That is
  `engineering:verification-before-completion`, run against the change this workspace
  eventually holds — not this skill's baseline check, which runs before any change exists.
- It does not **merge, open a pull request, or clean up the workspace once work
  finishes.** That is `engineering:finishing-a-development-branch`; this skill only ever
  sets a workspace up, never tears one down or integrates it back.
- It does not **fix a red baseline.** If the test suite fails before any change is made,
  this skill reports that fact and stops there — diagnosing or repairing a pre-existing
  failure is separate work, not something isolation setup does on the way past.
- It does not **choose a branching strategy.** Beyond picking a name that describes the
  task and confirming nothing else is already checked out on it, how branches get
  organized, merged, or named across a project is a project decision, not this skill's.
