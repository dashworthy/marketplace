# Deepening a shallow module

Four moves turn a shallow interface into a deep one. None of them are about making the
module smaller — some make it bigger. All of them move a cost that the caller was paying
into the module, where it's paid once instead of at every call site.

Use these once `codebase-design`'s depth principle has told you a module is shallow.
Each move below is a shape sketch, not a language-specific pattern — translate the
signatures into whatever the module's actual language looks like.

## 1. Pull complexity down behind the interface

If a caller has to orchestrate several of the module's own concerns from outside — because
the module itself refused to — pull that orchestration inside. The caller should state the
outcome it wants, not the steps that produce it.

**Before.** A cache that only stores bytes, leaving expiration and the fetch-on-miss path
to every caller:

```
raw = cache.get(key)
if raw is None or is_expired(raw, now()):
    cache.delete(key)
    value = fetch_from_source(key)
    cache.set(key, serialize(value), stored_at=now())
else:
    value = deserialize(raw)
```

Every call site repeats this five-line dance, or worse, repeats a slightly different
version of it. The module's job — "give me the value, fresh, however you have to get
it" — was never actually the module's job; it was the caller's, borrowed out to a
storage helper.

**After.** The module owns expiration, serialization, and the miss path:

```
value = cache.get_or_fetch(key, fetch_from_source, ttl=300)
```

One call, one meaning. The cache is no longer a byte store with helpers standing next to
it; it is the thing that answers "what is the current value for this key," which is what
every caller actually wanted.

## 2. Widen responsibility per call

If callers routinely make a fixed sequence of calls to the module in the same order to get
one meaningful outcome, that sequence is a single operation wearing several names. Give it
one name.

**Before.** Intake logic that makes every caller drive three calls in lockstep:

```
validate_schema(payload)
validate_business_rules(payload)
payload = normalize(payload)
```

Every caller has to know the order matters, and a caller who skips a step — or reorders
them — produces a payload that looks normalized but was never validated against the
business rules. The three-call shape is not flexibility; it's an invariant the module
declined to enforce.

**After.** One call owns the sequence and its order:

```
payload = intake(payload)   # raises IntakeError with the specific violation
```

The caller can no longer call the steps out of order because there is only one step to
call. Skipping validation is no longer possible by omission.

## 3. Collapse pass-through layers

If a layer's method does nothing but call the equivalent method on the layer below it —
same name, same arguments, no added decision — it isn't hiding anything; it's a detour.
Collapse it.

**Before.** Three layers to fetch a user, only the bottom one doing real work:

```
UserService.getUser(id)     -> UserRepository.getUser(id)
UserRepository.getUser(id)  -> UserRow.find(id)
```

`UserService` and `UserRepository` both look like modules — separate files, separate
classes — but neither makes a decision or hides anything the layer below doesn't already
hide. A caller reading `UserService.getUser` learns nothing they wouldn't learn by calling
`UserRow.find` directly, except which two extra files to open first.

**After.** One layer, doing what all three used to do between them:

```
Users.get(id)   # owns the query, the row-to-domain-object mapping, and the not-found case
```

Collapsing does not mean every layer boundary is wrong — a layer that translates
representations, enforces a policy, or adds caching is doing something the layer below it
doesn't. The test is whether the layer decides anything. If it only forwards, it isn't a
boundary; it's a name for the same call with extra steps.

## 4. Default the common case

If nearly every call site passes the same values for the same optional parameters, the
module has pushed a decision it could have made itself out to callers who don't actually
have an opinion about it — they're just repeating whatever the last caller copy-pasted.

**Before.** An interface where the 95% case still has to spell out five parameters:

```
send_email(to, subject, body, template=None, retries=3, transport="smtp", tracking=False)
```

Nearly every call site passes `retries=3, transport="smtp", tracking=False` because
that's what everyone copied from the first call site that used this function. The
parameters aren't configuration; they're the module asking every caller to co-sign a
decision it should have made once.

**After.** The ordinary case takes three arguments; the rest live behind a single escape
hatch for the callers that actually need to differ from the default:

```
send_email(to, subject, body)
send_email(to, subject, body, options=EmailOptions(retries=5, tracking=True))
```

The common call site shrinks to what it's actually about — who, what, and what it says.
The rare call site that needs to override something still can, without every other call
site paying rent for an option it never varies.
