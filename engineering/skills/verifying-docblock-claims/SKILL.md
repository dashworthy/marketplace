---
name: verifying-docblock-claims
description: "[Docs] Use when dispatched by vernacular's clarifying-docblocks conductor to check one file's freshly rewritten docblock prose against the code it describes - reverts any description asserting behaviour the code does not support, and amends the receipt. Reverts, never repairs."
---

# Verifying Docblock Claims

You are dispatched against **one file** that a rewriter has just changed. Your job is to catch
prose that is confidently wrong.

**You did not write this prose, and that is the point.** A rewriter grading its own
descriptions agrees with itself. Read what is there as a skeptic reading someone else's work.

## Your payload

```json
{
  "file":         "<absolute path in the working tree>",
  "before_path":  "<absolute path to this file's byte copy>",
  "receipt_path": "<absolute path to the receipt the rewriter wrote>",
  "skill_path":   "<absolute path to this document>",
  "schema_path":  "<absolute path to receipt-schema.md>"
}
```

## What you are testing

For each edit in the receipt, read the new description and the code it documents. Every
assertion it makes must be supported by that code. These fail:

- **Behaviour that is not there.** "Retries three times" in a method with no retry.
- **A precondition the code neither enforces nor relies on.** "Must be called after
  `connect()`" when nothing breaks if it is not.
- **A collaborator that does not exist.** A named class, method, or service the code never
  reaches.
- **An error path that is not raised.** "Throws if the card is missing" when it returns null.
- **A diagram whose arrows do not match the call order.** A diagram is a set of assertions
  drawn instead of written, and it is verified exactly as strictly.

Prose that is vague, or that emphasises the wrong thing, is **not** a failure. You are testing
truth, not quality. Reverting merely-mediocre prose to worse prose helps nobody.

## Revert, never repair

An unsupported claim means the docblock goes back to its **original bytes** from
`before_path`. You do not rewrite it, improve it, or hedge it.

Repairing is a second guess at the thing it just got wrong, by an agent with no more
information than the one that got it wrong. The original prose was at least honest about being
unhelpful; a repaired claim is a fresh assertion nobody checked.

## Amending the receipt

Per `schema_path`:

1. Revert **bottom-up** - highest `start` first. Reverting top-down shifts the working-tree
   position of every edit below the one you just undid, and you will then revert the wrong
   lines.
2. The reverted edit is **deleted from `edits`**, so the receipt always describes the file's
   final state.
3. Append to `reverted`: `{"start": <before-anchor>, "claim": "<the assertion, and what the
   code actually does>"}`.
4. Leave every other edit's `start`, `end_before` and `lines_after` untouched. They are
   before-file anchors and a count; they do not move when a sibling is removed. If you find
   yourself renumbering, re-read the schema - you have misread a count as a position.

## Your return value

Exactly one line:

```
verified <N> edits, reverted <R>, receipt at <receipt_path>
```

Never the prose you read, and never the prose you reverted. The claim text goes in the
receipt, where the conductor reads it as a field.

## Red flags - STOP

- Rewriting an unsupported description instead of reverting it.
- Reverting prose for being vague, clumsy, or not to your taste.
- Reverting top-down.
- Renumbering surviving edits after removing one.
- Editing a line outside the ranges the receipt claims.
- Returning a description to the conductor instead of a count.
- Passing a description you could not verify because the code was hard to follow. If you
  cannot support it, it is not supported.
