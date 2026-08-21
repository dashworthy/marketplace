# Mocking

A mock replaces a real collaborator with a stand-in the test controls. That control is the
entire appeal — a mock can return exactly the value, error, or delay a test wants, on
demand, without needing the real thing to cooperate. It is also the entire risk: a test
built on a mock proves the code behaves correctly against the test's *idea* of the
collaborator, not against the collaborator itself. The gap between those two is invisible
from inside a green suite, and it only shows up later, in production, when the real
collaborator turns out not to agree with the mock. Everything below is about keeping that
gap small and knowing when it's worth opening at all.

## Mock at boundaries you own

Reach for a mock at the edge of your own code — the point where your code hands control to
something you didn't write and can't run cheaply in a test: a network call, a payment
gateway, a third-party API, the system clock. You own the calling contract at that edge
even though you don't own what's on the other side of it, so a mock standing in for it is
mocking a shape you control and can keep accurate.

Do not mock a collaborator that is *also* your own code, one layer down, just because it's
inconvenient to construct. A mock at that seam stops the test from ever exercising the real
interaction between the two pieces — which is frequently where the actual bug lives, because
each piece in isolation was already correct. If constructing the real collaborator is the
obstacle, that's a sign to make it cheaper to construct, not a reason to mock around it.

```
# Mocking a boundary you own the contract for, not the implementation of:
payment_gateway = mock_gateway(charge=lambda amount: Charge(status="success"))
result = checkout.pay(cart, payment_gateway)
assert result.confirmed

# Mocking your own code one layer down — this hides the real interaction:
pricing = mock_pricing_engine(compute=lambda cart: 42.00)
result = checkout.pay(cart, pricing)
assert result.total == 42.00   # proves nothing about whether pricing is ever really called right
```

The second example never learns whether `checkout.pay` calls the pricing engine with the
arguments the engine actually needs, or handles the shape it actually returns — the mock
was configured to hand back a plausible-looking number no matter what was asked of it.

## Prefer a real collaborator

Before reaching for a mock, check whether the real collaborator is already fast,
deterministic, and safe to run inside a test — in-process, no network, no shared state with
other tests. If it is, use it. A real in-memory repository, a real parser, a real
value object all give the test a truer answer than a mock configured to imitate them, and
they cost nothing extra to maintain, because they can't drift out of sync with themselves.

Reach for a mock only once the real collaborator fails one of those checks: it's slow (a
real database round-trip on every test run), nondeterministic (the current time, a random
ID, network latency), external (a third-party service you don't control and shouldn't call
from a test suite), or dangerous to run repeatedly (an email sender, a real payment
charge). Those are the situations a mock earns its keep in — not "the real thing is
somewhat annoying to set up."

A lightweight real implementation built for testing — an in-memory store standing in for a
database, a fake clock you can advance by hand — often serves better than a mock for
exactly these cases: it behaves like the real thing across a whole test, rather than only
answering the one call a mock was told to expect, so it will not go silently along with a
call sequence the real collaborator would have rejected.

## Never mock the thing under test

The collaborator you mock has to be something *other than* the behavior the test exists to
verify. Mocking the unit under test — or a piece of it large enough that the mock does the
actual work the test is supposed to check — turns the test into a check that the mock was
configured the way the test expected, which is always true and therefore proves nothing.

```
# The test claims to verify discount calculation, but mocks discount calculation:
calculator = mock_discount_calculator(compute=lambda cart: 5.00)
assert calculator.compute(cart) == 5.00   # can never fail; it's checking the mock's own config
```

This shows up less obviously when the mocked piece is a step *inside* the function under
test rather than the whole function — mock out the one branch that contains the logic
you're supposed to be testing, and the rest of the test can pass while that logic is wrong,
missing, or deleted entirely. If a test would still pass after the line implementing the
behavior it claims to check is deleted, something in that test is standing in for the
behavior instead of exercising it.

## A mock-heavy test is a design signal, not just a test problem

When a unit needs five mocks to construct in a test, that is rarely a testing inconvenience
to work around — it is usually the same signal `codebase-design` looks for from the other
direction: a unit with too many collaborators, each one a piece of information the caller
(here, the test) has to know how to supply. A test straining under its own mock setup is
often the first place that shows up, before it's obvious anywhere else. When it happens,
treat it as a prompt to look at the unit's interface, not only as a reason to write a
helper that builds the five mocks for you.
