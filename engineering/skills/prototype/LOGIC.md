# Logic prototypes

A logic prototype answers a question about behavior: does this algorithm produce a
correct result at the scale involved, does this library actually do what its docs
claim, does this external service behave the way the design is about to assume it
does. The test is whether running code and reading its output would settle the
argument. If it would, this is the shape to reach for.

## Isolate the one operation

Strip everything around the operation in question. No auth layer, no persistence, no
error handling beyond whatever the question itself depends on. If the question is
"does this pagination cursor survive concurrent writes," the prototype needs a loop
that pages through results while another loop writes — it does not need the real
application's request handling, its logging, or its retry policy. Every piece of
surrounding scaffolding is a piece that isn't under test, and building it anyway is
building the real feature under the name of a spike.

**Example.** The design assumes a vendor's paginated API returns a stable ordering
even when rows are inserted mid-page. Instead of arguing from the API docs, which are
ambiguous about this exact case, run something like:

```
cursor = None
seen = set()
writer_thread.start()   # inserts ten rows at a random pace during the loop below
while True:
    page, cursor = api.list(cursor=cursor, limit=50)
    seen.update(row.id for row in page)
    if cursor is None:
        break
assert len(seen) == original_count + 10, "a row was skipped or duplicated"
```

Twenty lines, no framework, no persistence layer. It either asserts cleanly or it
doesn't, and either outcome is the answer the design needed.

## Fabricate the smallest realistic input

Use real data shapes where the risk lives in the shape of the data, and made-up data
everywhere else. A prototype testing whether a search-ranking change surfaces the right
kind of result needs a handful of realistic documents with realistic field values; it
does not need the production corpus. Scale the input to the risk — a prototype about
throughput at ten thousand rows needs ten thousand rows; a prototype about correctness
needs only enough rows to hit every code path once, which is usually far fewer.

## One question, one measurement

Decide, before writing the harness, what result would count as a pass and what would
count as a fail — a number, a boolean, a specific exception either raised or not. A
harness that produces "well, it sort of worked" hasn't answered anything; it has just
moved the argument into the results of an experiment nobody agreed on the terms of in
advance. If two questions are riding on the same spike, split it into two — a failure
that could belong to either assumption tells you nothing about which one actually
broke.

## Discard it

Once the assertion passes or fails, the harness has done its job. Delete it, or leave
it in a scratch location nothing imports from — but do not merge it into the
application, do not leave its TODOs for later, and do not let "well, it already works"
talk it into becoming the real implementation. The real implementation still needs its
own error handling, its own tests, and its own review; none of that was in scope for
the twenty lines that only had to answer one question.
