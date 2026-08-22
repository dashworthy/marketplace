---
description: Turn a decision you can't answer into a questionnaire for someone who can, written to a file in the current directory.
argument-hint: the decision you can't answer, and who should answer it
---

# to-signal

Some decisions surface mid-conversation that the person you're talking to simply can't
make — a product call only a stakeholder owns, a fact only one teammate knows, a
tradeoff that needs sign-off from someone who isn't in the room. $ARGUMENTS names the
decision and, where known, who should answer it. When discovery hits a question like
this, this command hands it off instead of stalling the work waiting on it.

## Turn the decision into a questionnaire

Read back over what's blocking and write it as a short set of direct questions, not a
narrative recap. Each question should:

- Stand on its own. The person answering may not have followed the conversation that
  produced it, so give enough context inside the question itself that it can be
  answered without a follow-up.
- Have a concrete shape. Prefer a question with a bounded answer — a choice among named
  options, yes/no, a number, a name — over an open "what do you think"; the reader
  should be able to respond in one pass.
- Say what rides on it. One line under each question is enough: what changes downstream
  depending on how it's answered.

Order the questions by how much they block. Whatever the rest of the work most depends
on comes first; a question nothing else waits on can come last, or be dropped if it
isn't worth a round trip.

## Where it goes

Write the file in the **current working directory** — deliberately not the OS temp dir.
Unlike a handoff document, a `to-signal` questionnaire is meant to be found: committed,
attached to a message, pasted into a review, or left for someone to pick up without
being told a path. Name it `to-signal-<slug>.md`, where `<slug>` is a short kebab
rendering of the decision — `to-signal-pricing-tier-cutoff.md`, say. Once it's written,
tell the user the exact filename.

## Why it's named this way

The questionnaire exists to unblock discovery, not to replace it. Once the questions
come back answered, the answers belong right back in whatever discovery work raised
them — that round trip, out to a person and back into discovery, is the pairing this
command is named for. Say so at the top of the file itself: one line noting that the
answers feed back into the discovery work that produced the questions, rather than
being filed away on their own.

If no argument was given, ask what decision is blocking before writing anything, and
who — by name or by role — is the right person to answer it.
