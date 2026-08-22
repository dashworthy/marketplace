---
name: finishing-a-development-branch
description: "[Foundation] When work is complete and green, present structured options for integrating the branch (merge / PR / cleanup) and carry out the choice. Use at the end of a piece of work. Safety net: if the branch was never test-hardened, prompt to run conducting-test-hardening before finishing. Model-invoked; no command."
---

# Finishing A Development Branch

Say this first, plainly: `Using the finishing-a-development-branch skill to decide how this
branch gets integrated.`

## What this guarantees

One thing: this skill will not offer a single integration option — merge, PR, or cleanup —
until the branch in front of it is green, its verification is backed by command output rather
than a claim, and there is actual evidence the branch was test-hardened. Where any of those
three is missing, this skill stops and closes the gap first: it runs verification itself, or it
surfaces the hardening gap and prompts for it, before the options list ever appears. Nothing
past that point is guaranteed — how the chosen option gets carried out is judgment applied to
whatever this project's own remote, review process, and branch model happen to require.

## Require green and verified before anything else

A branch that "should be done" is not the same claim as a branch that has just been checked.
Compose with `engineering:verification-before-completion`: before this skill even considers
which integration option to offer, confirm verification has run against the branch's current
state — not a state it was in three commits ago — and that its output, not a summary of it, is
what's being relied on. If verification hasn't run yet, or the branch has moved since it last
did, run it now rather than trusting a stale green.

If verification comes back red, stop there. Report exactly what failed and hand the decision —
fix now, or fix before returning to this skill — back to the user. A red branch has nothing to
integrate; do not fall through to the hardening check or the options list on the theory that the
failure is probably unrelated.

## The verity safety net (D15)

Most branches get hardened without this skill doing anything: `writing-plans` puts a closing
test-hardening task on every plan it writes, and `executing-plans` reaches that task and runs
`engineering:conducting-test-hardening` in the ordinary course of working the plan. That
pipeline is not this skill's concern — until the branch reaching this skill is one it can't
vouch for, which is more often than it sounds. Work done outside `writing-plans` entirely never
had a hardening task to begin with. A plan-driven branch can still reach here with that task
sitting unchecked, because a task got skipped, a plan was abandoned partway through and resumed
differently, or the box was hand-edited without the run behind it. Nothing upstream of this
skill enforces that the task actually ran — only that it exists on the plan.

So treat "was this branch hardened" as a question with evidence, not an assumption carried over
from earlier in the session:

- **Was there a plan behind this branch at all?** If one is known — via the active run pointer
  or a plan file under `docs/dashworthy/engineering/plans/` that matches this work — find its
  closing Phase 3.5 task and check whether its box is actually checked. A plan with no such task
  checked off has not been hardened, whatever the rest of its boxes say.
- **Did a hardening run actually leave a trace?** A checked box is a claim; verity's own run
  directory, `.engineering/<run>/verity/`, with at least one brief in it, is the record that a
  hardening pass actually happened rather than being ticked off by hand. Prefer the trace over
  the checkbox when the two disagree.
- **No plan at all** is the same case as a plan whose task was skipped, not a lesser one — the
  absence of a pipeline that would have hardened the branch leaves it exactly as unhardened as a
  pipeline that ran and skipped the step.

When any of that comes back short, do not fold it silently into "done." Say plainly that this
branch has no evidence of being test-hardened, and prompt to run
`engineering:conducting-test-hardening` now, before any integration option is presented — this
is where verity's coverage lives now that it no longer rides a session-start hook. This is a
prompt, not a lock: if the user wants to proceed without it, that is theirs to decide explicitly.
What this skill does not do is let the gap pass unnamed, or decide on the user's behalf that
skipping it is fine.

## Present the integration options

Once the branch is green, verified, and either hardened or knowingly waved through, lay out how
it can re-enter the rest of the repository:

- **Merge directly** — the branch talks straight to its target with no review gate expected or
  required.
- **Open a pull request** — the default wherever the project expects review, or the remote's
  permission model requires one; check whether a PR already exists for this branch before
  offering to open a second one.
- **Clean up only** — the branch turned out unneeded, its content already landed another way, or
  it was superseded, and the right move is to discard it rather than integrate it at all.

Which of these are actually live options depends on the project, not on this skill's own
preference — read the remote configuration, any branch protection, and the branch's existing
state before offering them, rather than presenting all three uncritically every time. Then ask
which one the user wants. Picking on the user's behalf turns a process decision that belongs to
the project into a default this skill invented.

## Carry out the choice

- **Merge.** Perform the merge (or the native equivalent), and once the branch's work is folded
  into its target, clean up after it — delete the branch and remove any worktree
  `engineering:using-git-worktrees` set up for it. A merged branch left standing is a place
  someone could mistakenly resume work next to the copy that already landed.
- **Pull request.** Open it, hand back its link, and stop there. This skill does not chase the
  PR through review or merge it once it exists — a PR that later lands is a fresh invocation of
  this same skill, not a loop this one keeps running in the background.
- **Cleanup only.** Discarding a branch is destructive in a way the other two options are not,
  so get the user's explicit confirmation on this path specifically before removing anything —
  do not treat silence, or the fact that cleanup was the option picked, as confirmation enough on
  its own.

## What this does not do

- It does not **run the project's tests itself** in place of its own suite or
  `engineering:verification-before-completion` — it relies on that skill's evidence rather than
  reimplementing it.
- It does not **run the hardening pass on its own initiative.** It prompts for
  `engineering:conducting-test-hardening`; whether that dispatch actually happens is the user's
  call, and if it does happen, verity's own loop owns it end to end — this skill does not
  shortcut or re-implement any part of that loop.
- It does not **review the code on the branch.** Whatever judgment belongs to
  `engineering:code-review` already happened earlier in the branch's life; by the time this
  skill runs, the content is the content that's shipping, and the only open question is how it
  re-enters the rest of the repository.
- It does not **pick the project's integration policy for it.** Merge, PR, and cleanup are
  offered as options every time, decided by the user every time — never hard-coded to whichever
  one this skill used last.
