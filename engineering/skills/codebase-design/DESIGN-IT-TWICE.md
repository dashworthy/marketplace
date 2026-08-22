# Design it twice

The first interface shape you sketch is not a design decision. It's whatever fell out of
the implementation you had half-formed in your head when you started sketching. You can't
judge it, because judging requires a comparison, and there's nothing yet to compare it to.
The fix is mechanical: sketch a second shape, deliberately different, before you write
either one for real.

## Getting a genuinely different second design

A second draft that only renames parameters or reorders arguments isn't a second design —
it's the same design with a different accent. A real second design changes **who decides
what**: move a decision that the first design left to the caller into the module, or move
one the first design made internally out to the caller. Some places to look for that
second shape:

- If the first design takes a bag of options, ask what it would look like as two or three
  narrower calls instead — one per situation, each with no options at all.
- If the first design is one call that returns one thing, ask what it would look like
  split into a query and a command, or combined from two calls into one.
- If the first design reports failure through an error value, sketch what it looks like
  reporting failure through a distinct return type instead — and the reverse if it started
  the other way.
- If the first design hands the caller an object to keep calling methods on, sketch a
  version that takes everything up front and returns a finished result instead.

The goal isn't to generate a bad design to make the good one look better by contrast. Both
sketches should be shapes you could actually ship. If the second one is obviously worse,
you didn't move far enough from the first — try again from a different one of the angles
above.

## Choosing between them

Once two real shapes exist, judge them against three things, in this order:

1. **Call-site simplicity.** Write out what a typical caller has to know and pass, not how
   many characters it takes to type. Count concepts: how many arguments does the caller
   have to reason about, and how many of those does the caller actually have an opinion
   on? A design where the caller supplies values it doesn't care about is not simpler for
   being one line.
2. **Hidden complexity.** Of everything the module actually has to do internally, how much
   of it never has to reach the interface at all? A design that hides more of its own
   machinery — without lying about what it does — wins over one that hides less, even if
   the two interfaces look similarly sized on the page.
3. **Misuse resistance.** Can a caller hold this interface wrong and get something that
   compiles, runs, and looks plausible, but is broken? Prefer the shape where a caller who
   gets it wrong fails immediately and obviously, over the shape where they'd only find
   out in production.

## Worked example: a permission check

A module needs to answer two related questions for a UI: is this action allowed, and if
not, what do we tell the user. Two designs:

**Design A — two calls.**

```
has_permission(user, resource, action) -> bool
explain_denial(user, resource, action) -> str
```

**Design B — one call, one result.**

```
check(user, resource, action) -> Decision
# Decision.allowed: bool
# Decision.reason: str | None   — populated only when allowed is False
```

Call-site simplicity: Design A's typical caller — the one that just needs to gate a
button — calls `has_permission` and never touches `explain_denial`, so for that caller
Design A is one call too, same as B. But the caller building an error message has to call
*both*, in the right order, to get bool and reason together. Design B gives every caller
one call regardless of which parts they need.

Hidden complexity: `has_permission` and `explain_denial` most likely each walk the same
rule set independently — two separate evaluations of a policy tree, from two call sites
that don't know about each other. Design A doesn't hide that duplication; it invites it,
silently, from outside. Design B's single `check` walks the rules once and hands back
both facts from that one pass, so the caller never has to know the evaluation was
expensive or repeatable at all.

Misuse resistance: nothing stops a caller from calling `explain_denial` for an action that
`has_permission` just said was allowed — Design A will happily hand back an empty or
nonsensical "reason" for an allowed action, because the two calls have no relationship the
type system enforces. Design B makes that contradiction unrepresentable: `reason` is only
ever populated on a `Decision` where `allowed` is `False`, because both came from the same
evaluation. A caller can't ask for a denial reason on an allowed action, because there's no
call that lets them ask for a reason in isolation.

Design B wins on all three counts, and the reason is the same reason in each case: it
does not let a decision the module made internally — one evaluation, one policy walk — leak
back out as two separate things a caller has to keep in sync by hand.
