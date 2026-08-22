---
description: Compact this conversation into a handoff document for the next session, written to the OS temp directory.
argument-hint: "What will the next session be used for?"
---

# handoff

Write a handoff document for whoever picks this work up next — a fresh session for you,
or a different person on the team. $ARGUMENTS says what that next session will be used
for; open the document by restating it in your own words, so the reader knows this was
written with that goal in mind.

## Where it goes

Write to a file in the OS temp directory, not the repository. A handoff bridges two
sessions of the same work; it is not a project artifact, and it should never show up in
`git status`, get reviewed, or outlive the session it was written for. Name the file so
it says what it is and when it was made (something like
`handoff-<slug>-<timestamp>.md`), and once it's written, tell the user the exact path —
the file has no other way of being found.

## What to compact

Read back over the conversation and reduce it to what a cold-start reader actually
needs:

- The goal this session was working toward, and how far it got.
- Decisions made along the way, and why — the landing, not the discussion that produced
  it.
- Open threads: what's unresolved, what's blocked, what was deliberately deferred and
  why.
- The concrete next step — the first thing the next session should do, not a survey of
  everything that could be done.

Do not restate material that already lives somewhere durable. If this session touched a
document under `docs/dashworthy/engineering/specs/` or `docs/dashworthy/engineering/plans/`,
point at that path instead of copying its contents. The same goes for `CONTEXT.md` at the
repo root and any record under `docs/adr/` — link to them, don't reproduce them. The
handoff's job is to say what changed and what's left, not to duplicate a document that
already says what's true.

## Redact secrets

Before writing the file, scan everything you are about to include for anything that
looks like a credential, API key, token, password, or a URL carrying embedded auth —
whether it surfaced in code, in command output, or in pasted text during the
conversation. Redact it: swap the value for a placeholder such as `[REDACTED]`, and,
where it helps the reader, note what kind of secret it was so the next session knows
something was removed rather than simply missing. Never write a live secret into a file
in the temp directory — it is not a secure location, and the entire point of this
command is a handoff that's safe to read later without re-exposing anything.

## Suggested skills

Close with a **suggested-skills** section: a short list of `engineering:` skills the
next session will likely need, given where this one left off, each with one line on why.
Name them by their real skill id — for example `engineering:writing-plans` if a spec
exists but no plan has been produced from it yet, `engineering:executing-plans` if a
plan exists and the next step is to run it, or `engineering:conducting-test-hardening`
if the work is implemented but was never hardened. Only suggest a skill that genuinely
fits what this session did; a short, accurate list is more useful than an exhaustive
one.

If no argument was given, ask what the next session will be used for before writing
anything — the handoff reads differently depending on whether the next session
continues this exact work, hands it to someone else, or starts something adjacent to
it.
