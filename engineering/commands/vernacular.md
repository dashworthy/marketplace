---
description: Rewrite this branch's docblock prose into plain language, in place, proving that executable code and structured annotations came out byte-identical
---

Clarify the docblocks changed by `$ARGUMENTS`.

`$ARGUMENTS` is optional. Empty means the current branch against its merge-base with the
default branch. Otherwise it is a branch name, or a PR/MR reference.

Invoke the `clarifying-docblocks` skill with that ref and follow it exactly.

Do not rewrite a docblock on a symbol the diff does not reach. Do not write, edit or delete
`@param`, `@return`, or any other structured annotation - including on a symbol that has none.
Do not proceed past a failing reconcile check.
