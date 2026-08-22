# The comprehension gate

A description is rewritten **only** if it fails on at least one of the six modes below.
Anything that fails none of them is left exactly as it is.

## The untouchable rule

**Prose that already does its job survives a run unchanged.**

This is an invariant, not a preference. Without it every run rewrites everything, the diff
becomes noise, the user stops reading it, and the tool is worthless whatever the quality of
its prose. The report's `left_alone` count is the only evidence the user has that this rule
still holds.

**When in doubt, leave it.** Rewriting a borderline-adequate description costs the user a
diff hunk they must read and reject. Leaving a borderline-inadequate one costs nothing they
did not already have.

## The six failure modes

| Failure | What it looks like |
|---|---|
| **Restates the signature** | `Sets the user id.` on `setUserId(int $id)` |
| **Describes mechanism, not purpose** | `Loops the items, calls process() on each, flushes the buffer.` |
| **Assumes vocabulary it does not supply** | `Reconciles the tender against the drawer.` |
| **Machine-facing residue** | `Implements task 4 of the sync plan. See brief section 3.` |
| **Empty of consequence** | Never says what it assumes, what happens if you skip it, or what will bite you |
| **Absent** | Tags only, or no docblock at all |

## What passes

This is left alone. It says what the thing is for, when to run it, and what will surprise you:

```php
/**
 * Reconciles what the payment processor thinks we charged against what
 * our own ledger says. Run it after settlement, not before - before
 * settlement the processor's figures are still provisional and every
 * row will look like a mismatch.
 */
```

## What a rewrite says

- What the thing is **for**, in a sentence someone outside the team would follow.
- When you would reach for it, and when you would not.
- What it assumes, and what happens when the assumption does not hold.
- **Never a restatement of the tags.** They are frozen and sitting directly below.
