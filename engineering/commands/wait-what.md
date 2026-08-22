---
description: Re-pitch a message that didn't land, rewritten in plain and unambiguous language a specific reader can't misread.
argument-hint: the message that didn't land, and who it was for
---

# wait-what

"Wait, what?" is the reaction a message gets when it doesn't land — confusion, a
follow-up question that shouldn't have been needed, silence where there should have
been action. $ARGUMENTS is the message that missed and, where known, who it was meant
for. This command doesn't diagnose why the first attempt failed in the abstract; it
produces a second attempt the reader can't misread.

## Read for background, don't demand it

Before rewriting, check the repo root for `CONTEXT.md` and `CONTEXT-MAP.md`. If either
exists, read it: `CONTEXT.md` is the project's domain glossary, and it tells you which
words the reader already has a fixed meaning for, so the rewrite can reuse those words
instead of introducing synonyms that read as new concepts. Neither file is required —
if they're absent, work from the conversation and $ARGUMENTS alone, and don't ask the
user to create them first.

## Re-pitch the message

Rewrite the message using Simplified Technical English conventions (ASD-STE100): the
discipline of writing so a message can be read only one way.

- **One idea per sentence.** If the original packs a decision, its justification, and a
  caveat into one sentence, split it into three.
- **Short sentences, plain words.** Prefer the concrete verb over the abstract noun
  built from it — "we decided" over "a decision was made," "we changed" over "a change
  was made."
- **Name who does what.** Active voice, a named actor, a named action. A passive
  sentence hides the actor exactly where the reader needs to see one.
- **One word per meaning.** If earlier drafts or the conversation used two different
  words for the same thing, pick one and use it throughout the rewrite — that alone
  removes a whole class of "is this the same thing or not?" confusion. Reuse whatever
  term `CONTEXT.md` already fixed for that concept, when it exists.
- **State the ask plainly.** If the message wants the reader to do something, decide
  something, or approve something, say so in a sentence a skimming reader cannot miss —
  don't bury the ask inside context.
- **Separate background from the ask.** Explaining why you believe something is not the
  same as telling the reader what you need from them; keep the two visibly apart, or
  drop the former if it isn't load-bearing.

## What this does not do

This command writes nothing to disk. Its entire output is the rewritten message, shown
in the conversation, ready to paste wherever the original went — chat, email, a review
comment, a ticket. It keeps no record of the miscommunication and produces no artifact;
there is nothing here to commit.

If no argument was given, ask for the message that didn't land, and who it was for,
before rewriting anything.
