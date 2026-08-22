# Test design

A test is a specification with a pass/fail switch attached. Everything below is about
making that specification say one true thing clearly, because a red-green cycle is only as
meaningful as the test driving it — a vague or tangled test can go from red to green
without anyone learning whether the right behavior now exists.

## One behavior per test

A test should fail for exactly one reason. If a test can fail for three different reasons,
a failure tells you something broke and leaves you to find out which of the three — the
test has stopped being a specification and become a puzzle.

**Before.** One test carrying a whole workflow:

```
def test_checkout():
    cart = Cart()
    cart.add(item, qty=2)
    assert cart.total() == 20.00
    cart.apply_coupon("SAVE10")
    assert cart.total() == 18.00
    order = cart.checkout()
    assert order.status == "confirmed"
    assert order.items[0].qty == 2
```

Four behaviors — pricing, coupon math, checkout, item transfer — share one test. A failure
on line three reads the same as a failure on line six until you open the file and read the
stack trace. Worse, an unrelated change to coupon handling can break this test even when
the thing the test's name promises — checkout — still works fine.

**After.** Each behavior gets its own test, named for what it covers:

```
def test_cart_total_reflects_quantity():
    cart = Cart()
    cart.add(item, qty=2)
    assert cart.total() == 20.00

def test_coupon_reduces_total():
    cart = cart_with_item(qty=2)
    cart.apply_coupon("SAVE10")
    assert cart.total() == 18.00

def test_checkout_confirms_order():
    order = cart_with_item(qty=2).checkout()
    assert order.status == "confirmed"
```

Four tests now exist where one did, and each one's failure names the behavior that broke
without anyone reading past the test's name. This costs more lines. It buys back every
minute you'd otherwise spend figuring out which assertion inside a bundled test actually
failed.

A test with more than one assertion is not automatically wrong — several assertions
checking facets of the *same* behavior (an order's status, its total, and its item count,
all as evidence that "checkout succeeded") are one behavior's worth of proof. The line to
watch is whether the assertions could fail independently for unrelated reasons. If they
can, they're testing different things wearing one test's name.

## Arrange, act, assert

Give every test the same three-part shape, in the same order, and keep the parts visibly
separate: **arrange** the state the behavior needs, **act** by making the one call under
test, **assert** on what that call should have produced or changed. A test that interleaves
these — asserting mid-setup, acting again after the first assertion — is usually two tests
that got written as one, or a test where the actual behavior under test has gotten lost
among the setup.

```
def test_withdrawal_reduces_balance():
    account = Account(balance=100)          # arrange
    account.withdraw(30)                    # act
    assert account.balance == 70            # assert
```

The shape does double duty: it makes a test's intent readable at a glance — arrange is
context, act is the one thing being tested, assert is the claim — and it makes a bloated
test visible from its structure alone. A test whose "arrange" section runs twenty lines
deep, or whose "act" section calls three different methods, is telling you it's arranging
for or exercising more than one behavior before you've read a single assertion.

## Naming

A test's name is the first, and sometimes only, thing anyone reads about it — in a failure
report, in a list of what ran, in a diff that adds one. Name it for the behavior and the
condition that produces it, not for the method it happens to call: `test_withdraw` says
what was invoked; `test_withdrawal_reduces_balance` says what should be true afterward.
When the behavior has a condition attached, put the condition in the name too:
`test_withdrawal_rejected_when_balance_insufficient` tells you, from the failure list
alone, exactly which rule broke — no open file required.

A name that's hard to write is frequently a sign the test covers more than one behavior;
if the honest name would need "and" in it, the test probably needs to split along that
"and."

## Independence

A test should pass or fail the same way regardless of what ran before it, in what order,
or whether it ran alone. Independence isn't a nicety — it's what lets a single failing test
tell you something. A suite where tests depend on each other's leftover state turns every
failure into a question about which test actually caused it, and turns "run just this one
test" from a debugging tool into something that doesn't reliably work.

The usual way independence breaks is shared mutable state that isn't reset between tests:

**Before.** A module-level list every test appends to:

```
users = []

def test_registration_adds_user():
    users.append(make_user("a"))
    assert len(users) == 1

def test_duplicate_registration_rejected():
    users.append(make_user("a"))
    assert register(make_user("a")) is False
```

Run these in this order and the second test's assertion happens to hold — but only because
the first test left a user behind. Run the second one alone, or run them in the other
order, and it fails for a reason that has nothing to do with duplicate registration. The
test isn't verifying the rule; it's verifying an accident of execution order.

**After.** Each test builds its own state and shares nothing:

```
def test_registration_adds_user():
    users = UserStore()
    users.register(make_user("a"))
    assert users.count() == 1

def test_duplicate_registration_rejected():
    users = UserStore()
    users.register(make_user("a"))
    assert users.register(make_user("a")) is False
```

Every test now sets up exactly the state its own behavior needs, and nothing it does
survives to affect the next one. Order stops mattering; running one test in isolation
produces the same verdict as running the whole file. If two tests must reuse the same setup
work, share the arrangement through a helper or a fixture that builds fresh state per test
— never through a value one test mutates and leaves behind for the next one to find.
