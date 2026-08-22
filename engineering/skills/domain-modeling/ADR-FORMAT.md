# ADR Format

An ADR — architecture decision record — is a record of one decision, written down once,
at the moment it's made. It is not a retrospective explanation composed later for someone
else's benefit; write it while the reasoning is still live.

## Filename

`docs/adr/NNNN-<kebab-title>.md`

`NNNN` is a four-digit sequential number, starting at `0001`. Find the highest number
already under `docs/adr/` and use the next one — never reuse a number, even for a decision
that later reverses an earlier one. `<kebab-title>` is a short, lowercase, hyphenated
version of the title below it.

## Shape

```markdown
# NNNN. <Title>

## Status

Proposed | Accepted | Superseded by NNNN

## Context

## Decision

## Consequences
```

`Title` names the decision, not the problem — "Use event sourcing for order history," not
"How should we store order history?"

`Status` is one of three values. `Proposed` means the decision is written but not yet
committed to. `Accepted` means it's the decision currently in force. `Superseded by NNNN`
means a later ADR replaced this one — point at that ADR's number, and leave this record in
place rather than deleting it; the history of having decided something, then decided
otherwise, is exactly what an ADR trail is for.

`Context` is the situation that made a decision necessary — the forces pulling against
each other, the constraint that ruled some options out, what would happen if nothing were
decided. Written straight, without yet arguing for the answer that follows.

`Decision` is the answer, stated once, in one or two sentences. Not a comparison of
options — that comparison, if it's worth keeping, belongs in `Context`. This section says
only what was chosen.

`Consequences` is what follows from the decision — the benefit it was chosen for, and the
cost or constraint it introduces going forward. An ADR that lists no downside usually means
the downside wasn't looked for.
