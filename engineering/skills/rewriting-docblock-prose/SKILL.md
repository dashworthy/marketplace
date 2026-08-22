---
name: rewriting-docblock-prose
description: "[Docs] Use when dispatched by vernacular's clarifying-docblocks conductor to rewrite one file's docblock prose - applies the comprehension gate, rewrites only descriptions that fail it, writes the file in place, and returns a receipt of the exact line ranges replaced. Never touches a structured annotation or a line of executable code."
---

# Rewriting Docblock Prose

You are dispatched against **one file**. You read it, decide which docblock descriptions fail
the comprehension gate, rewrite only those, write the file, and return a receipt.

## Your payload

```json
{
  "file":         "<absolute path in the working tree>",
  "hunks":        [{"start": 104, "end": 131}],
  "before_path":  "<absolute path to this file's byte copy>",
  "receipt_path": "<absolute path to write the receipt to>",
  "skill_path":   "<absolute path to this document>",
  "gate_path":    "<absolute path to comprehension-gate.md>",
  "diagram_path": "<absolute path to diagram-rules.md>",
  "schema_path":  "<absolute path to receipt-schema.md>"
}
```

`hunks` carries **working-tree line numbers** for the ranges this branch changed. Read
`gate_path`, `diagram_path` and `schema_path` before you start. They are the contract; this
document does not restate them, so that there is one copy to change.

## Scope

Map each hunk to its **enclosing symbol** - the nearest enclosing documentable unit (function,
method, class, interface, trait, module, or property) whose body or signature the hunk falls
inside. Those symbols are your scope.

- A symbol in scope with a docblock: apply the gate to its description.
- A symbol in scope with **no** docblock: write one. Prose only.
- A symbol the hunks do not reach: **out of scope**, even in this same file. Do not touch it,
  however bad its prose is.

## The three prohibitions

1. **Never write, edit, or delete a structured annotation.** `@param`, `@return`, `@throws`,
   `@var`, generics, Psalm/PHPStan annotations, Sphinx field lists. This includes symbols that
   have none: you write prose, never tags. A multi-line annotation - a `@param array{...}`
   spread over several lines, a wrapped `@throws` description - is off-limits in full,
   continuation lines included. Those interior lines do not begin with `@`, so the proof does
   not catch a range that claims them; you are the only guard there. Never claim any line at or
   below a docblock's first tag.
2. **Never claim a range containing an annotation line.** The reconcile check treats this as a
   precondition and halts the whole run on a single violation, so a claimed range that spans a
   tag does not merely lose your edit - it kills every other file's work too.
3. **Never change a line of executable code**, including whitespace on it.

## Whole lines, always

Every edit replaces **whole lines** with whole lines. Never edit part of a line, and never
leave a rewritten description sharing a line with code. A single-line docblock being expanded
into a block comment is a whole-line replacement of one line by several, which is fine; a
description spliced into the middle of an existing line is not representable in a receipt and
will fail reconciliation.

## Writing the receipt

Per `schema_path`. Every anchor is a **before-file** line number and `lines_after` is a count.
Compute anchors against `before_path`, not against the file as you are editing it - your own
earlier edits have already shifted the working tree's numbering, and a receipt anchored to a
moving target is the one bug reconciliation cannot catch for you.

Sort `edits` by `start`. They may not overlap.

`left_alone` counts descriptions you examined and deliberately did not touch. **Count them
honestly.** It is the only evidence anyone has that the gate is still discriminating, and a
guessed number makes a run that rewrote everything indistinguishable from one that judged
carefully.

## Your return value

Exactly one line:

```
wrote <N> edits, left <M> alone, receipt at <receipt_path>
```

You return a receipt path and two counts. You never return prose, and you **never return a
description you wrote**. If you find yourself quoting a docblock back to the conductor, the
context firewall has already failed.

If the file is unreadable, or you cannot map a hunk to any symbol, write a receipt with an
empty `edits` array and return:

```
wrote 0 edits, left 0 alone, receipt at <receipt_path>  BLOCKED: <one-line reason>
```

## Red flags - STOP

- Editing a line outside a docblock, for any reason, including fixing an obvious typo in the
  code next to it.
- Adding a `@param` to a symbol that had none "for completeness."
- Claiming a range that includes a tag line so you can reflow the whole docblock.
- Claiming a range that reaches into a multi-line tag's continuation lines because they don't
  start with `@`.
- Rewriting a symbol the hunks do not reach because its prose is bad.
- Anchoring receipt line numbers to the file as you are editing it rather than to
  `before_path`.
- Returning a rewritten description to the conductor.
- Estimating `left_alone` rather than counting it.
