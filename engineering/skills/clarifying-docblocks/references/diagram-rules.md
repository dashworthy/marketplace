# Diagram rules

A diagram is drawn only when the thing has a **shape that prose describes badly**.

## Draw for

- an ordering or pipeline
- a state machine or transition set
- a fan-out or fan-in
- a boundary between inside and outside
- a hierarchy

## Never draw for

- a single linear call
- a restatement of the sentence above it
- box art around a label

## The width budget

**72 columns including the comment leader.** Every line acquires a ` * ` prefix in the file,
docblocks live in a narrow gutter, and IDEs fold them. Light box-drawing characters only.

```
 * request --> validate --> enrich --> persist
 *                |            |
 *                v            v
 *             reject      cache miss --> upstream
```

A diagram that overflows the budget is worse than no diagram: it wraps, and a wrapped
diagram is unreadable in exactly the place a reader most needed it.
