# UI prototypes

A UI prototype answers a question about a person: can they tell what this is asking of
them, do they find the thing they're looking for, does a flow make sense walked
through rather than described. The test is whether putting something in front of
someone and watching them use it would settle the argument. If it would, this is the
shape to reach for.

## Match fidelity to the question, not the audience

Build only as much visual fidelity as the question needs, and resist the pull to add
more. A question about whether people notice a control at all needs gray boxes and one
color reserved for the thing being tested — polishing it further just adds things a
reviewer will comment on instead of the actual question. A question about whether a
paragraph of real copy reads clearly at a given width needs the real copy in a plain
box, not a full visual design built around it. The lowest fidelity that still produces
a real answer is correct; anything past that is spent convincing people the mock is
finished, not on answering the question.

**Example.** The design assumes a five-step signup form should be one long scrolling
page instead of five separate screens people navigate between. Rather than debating
scroll fatigue from opinion, put both in front of five people as flat static
screens — no working inputs, no validation, buttons that are just labeled
rectangles — and time how long it takes each person to find where question three lives
on each version, then ask them to point at "the button that submits this." An
afternoon of gray-box screens answers what a week of mockup polish would only have
delayed.

## Test with someone who isn't you

The point of a UI prototype is catching what the person who built the flow can no
longer see, because they already know where everything is. One teammate who's never
seen the flow, walking through it out loud, surfaces the "wait, how do I get back"
that staring at the mock alone never will. The audience doesn't need to be large or
representative of the eventual user base to be useful — it needs to be a person who
doesn't already have the answer in their head.

## One question, one walkthrough

Decide what the prototype is trying to find out before building it: can people find
X, do people understand what Y means, does the order of these steps make sense. Watch
for that specific thing, not a general "what do you think of this" that turns into
feedback on font choices and color. Feedback outside the one question is worth noting
for later, but it isn't what this prototype was built to answer, and chasing it
mid-walkthrough is how a ten-minute test turns into an hour that still hasn't settled
the original question.

## Discard it

Once the walkthrough answers the question, the mock has done its job. It does not need
to survive as a design file kept "in case," and it especially does not need to become
the actual component through incremental polish — a gray-box prototype that quietly
grows real styling, real state, and real code is a UI built without ever deciding on
its design properly. Screenshots or a short recording of the walkthrough are enough of
a record; the mock itself can go.
