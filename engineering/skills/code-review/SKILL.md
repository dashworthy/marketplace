---
name: code-review
description: "[Build] Review a change on two axes — Standards (does the code meet engineering norms) and Spec (does it do what was asked) — dispatching parallel sub-reviewers. Use before merging or when asked to review a diff/branch/PR. Finds the Spec axis in docs/dashworthy/engineering/specs/ or a user-supplied path. Reads CONTEXT.md/docs/adr when present."
---

# Code Review

Say this first, plainly: `Using the code-review skill to review this change.`

## What this guarantees

One thing: given a change — a diff, a branch, a PR, whatever the caller points at — this
skill reviews it on two separate axes and returns findings organized by which axis raised
each one, produced by independent sub-reviewers dispatched in parallel and reconciled back
into a single report. It does not guarantee the change gets approved, and it does not
guarantee a spec exists to check it against. It guarantees that when a spec does exist, the
change gets checked against it, and when it doesn't, that gap is stated rather than quietly
skipped.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
fixes anything it finds, or stands in for a human's final call.

## The two axes

**Standards** asks whether the code is good on its own terms, spec or no spec: is it
correct, is it clear to the next person who opens the file, does it carry tests that would
actually catch a regression, does it avoid the security mistakes that show up over and over
(unvalidated input, secrets in the wrong place, an authorization check that's assumed rather
than enforced), and does it follow the conventions already established around it rather than
inventing a local dialect. A change can be Standards-clean and still be the wrong change —
that's what the second axis is for.

**Spec** asks a narrower, sharper question: does this change do what was actually asked,
against the approved spec if one exists, or against the request as the person making it
actually stated it when none does. A Spec finding is never "this could be written better" —
that's a Standards finding wearing a disguise. A Spec finding is "the spec says X and the
change does Y," or "nothing on record says this scope was in bounds."

Keep the two separate in the report. A caller reading only the Standards findings should be
able to trust that nothing about scope or intent is hiding in them, and the reverse.

## Where the Spec axis looks

The Spec axis needs something concrete to check the change against, not a recollection of
what the conversation probably meant. It looks in one place first: `docs/dashworthy/engineering/specs/`,
for whichever document plausibly governs the change under review — matched by feature area
and, when more than one candidate fits, by recency. When the caller already knows which
document applies, or the change touches ground no spec in that directory covers on its own,
a path handed to this skill directly overrides the directory search outright; a
caller-supplied path is never second-guessed against what the directory scan would have
picked instead.

When neither turns anything up — the directory has nothing that fits, or the caller supplied
no path and none exists yet — the Spec axis does not have a document to check the change
against, and this skill does not go looking for one anywhere else to make up the gap. It
reviews Standards-only and says so plainly in the report, as a normal, complete outcome, not
an apology or a stall. There is no step here that goes hunting through a project's backlog
for what the change was supposed to be, and no pause to get a document written first — a
change with nothing filed for it gets the full Standards review it's owed, clearly labeled
as missing the second axis, and that review stands on its own.

## Dispatching the sub-reviewers

The two axes are looked at by two different reviewers, not one reviewer switching hats
partway through — a single pass that tries to hold "is this good code" and "is this the
right code" in mind at once tends to let the louder question crowd out the quieter one.
Dispatch at least one sub-reviewer per axis, in parallel, following `dispatching-parallel-agents`
for how the fan-out and the return are structured — that skill owns the mechanics of
splitting independent work and bringing it back; this skill supplies the split itself, plus
what each sub-reviewer needs to do its job: the diff, the matched spec document (or the
plain statement that none was found), and whatever substrate applies.

Each sub-reviewer returns findings scoped to its own axis and nothing else — a Standards
reviewer that notices a scope problem hands it back as a Spec-shaped observation rather than
folding it into its own findings, and vice versa. Reconciling the two returns into one
report — no duplicate findings, no axis silently dropped because its sub-reviewer came back
empty — is this skill's job, not something pushed further downstream. A caller asking for a
review wants one coherent answer, not a pair of transcripts to reconcile themselves.

## Reading the substrate

`CONTEXT.md`, at the project root, and `docs/adr/`, when present, sharpen the Standards
axis in particular: a convention already named, a boundary already drawn, a tradeoff already
argued and settled that the change under review should either respect or explain why it
doesn't. Read them when they exist; treat what they say as something the change is
accountable to, not background color.

Neither file is required, and their absence is not a degraded review. Most changes get
reviewed with no `CONTEXT.md` in sight and no ADR on point — that's the ordinary case, and
this skill proceeds on the diff and the matched spec alone when that's all there is.

## If another `code-review` is already installed

The name `code-review` is not this skill's to reserve. A separately installed plugin can
register its own skill under the same name, for its own review process, with its own idea of
what a review checks. Two skills sharing a name is not a naming collision to fix — Claude
Code resolves it by which plugin a caller means, same as any other namespaced pair, and a
caller who wants this skill specifically gets it by asking for it specifically. Nothing about
this skill's behavior changes because another `code-review` exists somewhere else on the
same machine.

## What this does not do

- It does not **fix what it finds.** A finding on either axis is a statement of what's wrong
  and why, handed back to whoever asked for the review. Applying the fix, deciding whether
  to apply it at all, and deciding whether a finding is worth blocking on belong to the
  caller, not to this skill.
- It does not **write the spec it's missing.** When the Spec axis comes up empty, that's the
  end of this skill's involvement with the gap — it reports Standards-only and stops. Getting
  a spec written, if one is warranted, is a separate decision made by someone else, on their
  own schedule, not a step this skill takes on the review's behalf.
- It does not **decide when a review happens.** Something else — a person, or whatever is
  driving a larger piece of work — decides a change is ready to be looked at and calls this
  skill at that moment. This skill starts once called; it does not watch for changes on its
  own or insist on being run.
- It does not **stand in for sign-off.** A clean report on both axes is information a human
  or a downstream process uses to decide whether to proceed, not a merge switch this skill
  throws itself.
