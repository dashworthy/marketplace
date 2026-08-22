---
name: research
description: "Gather facts on a question by dispatching background agents and synthesize a cited Markdown findings file that follows the repo's conventions. Use when a decision needs external or codebase-wide information before proceeding. Cross-cutting; invoke from any phase."
---

# Research

Say this first, plainly: `Using the research skill to gather facts before anything gets decided.`

## What this guarantees

One thing: given a question a decision is currently stuck on, this skill produces one
findings file where every claim in it names the source it came from, right next to the
claim. It does not guarantee the question has a clean answer — some questions resolve to
"the codebase doesn't say" or "the two sources disagree," and that outcome is exactly as
valid a finding as a confident yes would have been. It guarantees only that nothing in
the file got there on the strength of sounding right.

Nothing else is guaranteed. Read `## What this does not do` before assuming this skill
picks a side, builds anything, or decides what the facts it gathered should mean for the
decision waiting on them.

## Frame the question

A vague itch — "we should probably check how the other services handle this" — is not yet
something an agent can be dispatched against. Before anything gets dispatched, turn the
itch into one question specific enough that a source could settle it, or a small set of
them, each answerable on its own. A question no source could ever settle isn't ready for
this skill; it's still a discussion, and dispatching agents at it produces motion, not
fact.

Where the need splits into genuinely separate sub-questions — how our own checkout
retries, and separately, how the vendor's API rate-limits — frame each one on its own. A
single agent chasing three unrelated questions at once tends to answer the easy one
thoroughly and wave at the other two; three agents each chasing one question tend to
answer all three.

## Dispatch background agents

Once the question, or its split sub-questions, is framed, dispatch one agent per
question, in the background, in parallel — following `dispatching-parallel-agents` for
how the fan-out and the return are structured. That skill owns the mechanics of splitting
independent work across agents and bringing the results back; this skill supplies the
questions themselves and what each dispatched agent owes on return: not a paragraph of
conclusions, but the specific evidence behind each one — a file and a line, a command and
its output, a URL and the passage it supports.

Each question in the split has to stand on its own — no agent's answer allowed to depend
on another's, because that dependency is exactly what parallel dispatch can't express. A
question that only makes sense once another one resolves gets asked in a second wave,
after the first wave is back, not folded into the first alongside questions it doesn't
depend on.

Wait for the whole wave to finish before writing anything. A findings file assembled from
whichever agents happened to return first is missing whatever the slow ones would have
said, and nothing in a file built that way discloses that it's missing anything.

## Synthesize into one cited file

Once every dispatched agent is back, the job becomes assembly, not further digging: read
what came back, and write one Markdown findings file that answers the framed question, or
says plainly that the returns don't settle it. Every substantive sentence in that file
carries its citation right beside it — not gathered into a bibliography at the bottom,
where a reader has to hunt back and forth to check whether a given line is actually
supported. A claim and its source stay next to each other on the page.

Two agents can come back disagreeing — one source says the retry is exponential, another
says it's fixed-interval. That disagreement is itself a finding, written down as one, with
both sources cited, not quietly resolved by picking whichever answer sounds more
authoritative. Silently picking a winner turns a real gap in the evidence into a false
appearance of consensus, and whoever trusts the file inherits the mistake without ever
knowing a choice got made on their behalf.

## Never assert an uncited claim

This is the rule everything above serves, stated on its own because it's the one a
synthesis pass under time pressure is most tempted to bend: nothing goes into the
findings file that doesn't trace to something a dispatched agent actually returned. Not
background knowledge that seems safe to assume, not a detail that "must be true given the
rest," not a gap papered over with a plausible sentence so the file reads as complete. A
gap in what came back is a line in the file that says so — "no agent found a source for
X" is a legitimate finding — never a sentence dressed up to look like one.

## Where the file lands

The findings file is Tier-2 working material, not a spec — it lands under
`.engineering/<run>/research/`, the same run-scoped scratch space every other phase in
this plugin writes into. Obtain the path by running `sh
"${CLAUDE_PLUGIN_ROOT}/scripts/run-context.sh" research <slug>`, which prints the absolute
directory and creates it if needed. If a run is already active — this skill was invoked
mid-signal, mid-triage, mid-build, wherever the stuck decision happened to be — that same
call joins the active run instead of starting a new one, because the facts this skill
gathers belong to whatever decision called it in, not to a research run of their own. Name
the file for the question it answers, and print its path once written; this skill hands
back a path, not a copy of the file's contents.

## What this does not do

- It does not **decide what the facts mean.** Weighing what the findings imply for a
  design, a fix, or a plan belongs to whichever skill or human dispatched this one; this
  skill hands back evidence, not a recommendation built on top of it.
- It does not **dig alone.** Fact-gathering here always runs through dispatched agents,
  never through this skill reading the codebase or the web directly and writing down what
  it noticed — a claim with no agent behind it is exactly the uncited claim this skill
  exists to refuse.
- It does not **own the mechanics of parallel dispatch.** Splitting independent work
  across agents and bringing the results back is `dispatching-parallel-agents`'s job;
  this skill only supplies the questions and consumes the returns.
- It does not **write a spec.** A findings file is Tier-2 scratch material; turning
  settled facts into part of a Tier-1 document is the job of whichever skill asked this
  one to run, never this skill itself.
- It does not **guess past a gap.** A question the dispatched agents couldn't settle
  stays unsettled in the file, named as a gap — never quietly filled with the answer that
  seemed most likely.
