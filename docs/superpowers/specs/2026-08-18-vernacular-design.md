# vernacular — design

**Diff-scoped documentation hardening.** A branch's docblocks are rewritten in place so a
human reading the code understands what the code is for. It rewrites prose and only prose:
executable code and structured annotations come out of a run byte-identical, and both of
those claims are proved mechanically before anything is kept.

Fourth plugin in the dashworthy marketplace, alongside signal, verity and guardtower.

## The problem

Documentation written during implementation — by an agent working a plan, or by a person at
the end of a long day — reliably fails in the same ways. It restates the signature. It
narrates the mechanism the next six lines already show. It carries residue from the process
that produced it (`Implements task 4 of the sync plan`). It uses the team's private
vocabulary as if it were English. None of that is *wrong*, which is why it survives review;
it is merely useless to the next human to open the file.

vernacular finds that prose within a branch's changes and replaces it with an explanation a
person outside the team could follow, drawing a diagram where the thing has a shape prose
describes badly.

## Scope

The conductor resolves the branch or PR diff into changed files and, per file, the **hunk
line ranges**. A rewriter maps those hunks to their enclosing symbols. Those symbols are the
scope:

- A symbol the branch **added or modified**, whether or not it has a docblock.
- Missing docblocks are **written**, not skipped — a new class shipped with no docblock is
  the worst case this tool exists for.
- A symbol the branch did not touch is out of scope even when it sits in a touched file.
  Widening to whole files makes the documentation diff dwarf the code diff and destroys a
  reviewer's ability to tell the branch's work from the sweep.

The conductor never opens a source file. It routes paths and line ranges; every read happens
in a dispatched subagent. This is guardtower's context firewall, and it is here for the same
reason: the conductor's context must not grow with the size of the branch.

## The three invariants

1. **Prose only.** vernacular writes human-readable description text. It never writes, edits
   or deletes a structured annotation — `@param`, `@return`, `@throws`, `@var`, generics,
   Psalm/PHPStan annotations, Sphinx field lists. Static analysis cannot break, because the
   tool cannot reach the lines static analysis reads.
2. **Executable code is byte-identical.** Nothing outside a claimed docblock range moves.
3. **Good prose is untouchable.** A description that already does its job survives a run
   unchanged. This is an invariant, not a preference: without it every run rewrites
   everything, the diff becomes noise, the user stops reading it, and the tool is worthless
   whatever the quality of its prose.

Invariants 1 and 2 are proved by shell arithmetic — see **Reconcile**. Invariant 3 is
enforced by the comprehension gate and measured by the `left_alone` count in every report.

### Language independence

vernacular identifies no language and detects no stack. It has no per-language docblock
syntax table and no skip list.

It does not need one. Recognising a docblock is something a model reading a file does the
way a developer does, and the proof that nothing else moved is **line arithmetic**, which is
identical in every language. A run works on PHP, Go, Ruby, Terraform, or a language written
after this document, with no change and no registration.

Any future editor tempted to add a language table should read this section first: the table
was considered and deliberately not built, because it would convert a tool that works
everywhere into one that works on a list.

## The comprehension gate

A description is rewritten only if it fails on at least one of these. Anything that fails
none of them is left alone.

| Failure | What it looks like |
|---|---|
| **Restates the signature** | `Sets the user id.` on `setUserId(int $id)` |
| **Describes mechanism, not purpose** | `Loops the items, calls process() on each, flushes the buffer.` |
| **Assumes vocabulary it does not supply** | `Reconciles the tender against the drawer.` |
| **Machine-facing residue** | `Implements task 4 of the sync plan. See brief §3.` |
| **Empty of consequence** | Never says what it assumes, what happens if you skip it, or what will bite you |
| **Absent** | Tags only, or no docblock at all |

This passes, and is left exactly as it is:

```php
/**
 * Reconciles what the payment processor thinks we charged against what
 * our own ledger says. Run it after settlement, not before — before
 * settlement the processor's figures are still provisional and every
 * row will look like a mismatch.
 */
```

**When in doubt, leave it.** A gate that rewrites a borderline-adequate description costs
the user a diff hunk they must read and reject. A gate that leaves a borderline-inadequate
one costs nothing they did not already have.

## What a rewrite says

- What the thing is **for**, in a sentence someone outside the team would follow.
- When you would reach for it, and when you would not.
- What it assumes, and what happens when the assumption does not hold.
- Never a restatement of the tags. They are frozen and sitting directly below.

## Diagram rules

A diagram is drawn only when the thing has a **shape that prose describes badly**:

- an ordering or pipeline
- a state machine or transition set
- a fan-out or fan-in
- a boundary between inside and outside
- a hierarchy

It is never drawn for a single linear call, and never to restate the sentence above it.

```
 * request ──▶ validate ──▶ enrich ──▶ persist
 *                │             │
 *                ▼             ▼
 *             reject      cache miss ──▶ upstream
```

**72 columns including the comment leader.** Every line acquires a ` * ` prefix in the file,
docblocks live in a narrow gutter, and IDEs fold them. Light box-drawing characters only.

## Architecture

```
preflight ─▶ snapshot ─▶ rewrite (per file) ─▶ verify (per file) ─▶ reconcile ─▶ report
                            └──── pipelined, no barrier ────┘        barrier
```

Each file rewrites and then verifies independently; file B does not wait on file A. The only
barrier is reconcile, which needs every receipt.

Three skills:

| Skill | Role |
|---|---|
| `clarifying-docblocks` | Conductor. Resolves scope, dispatches, reconciles, reports. Reads no source. |
| `rewriting-docblock-prose` | Per file. Applies the gate, rewrites, writes the file, returns a receipt. |
| `verifying-docblock-claims` | Per file. Tests every new assertion against the code. Reverts what the code does not support. |

The verifier is a **different agent** from the rewriter. A rewriter grading its own prose
agrees with itself. This mirrors verity's `verifying-test-integrity` and guardtower's
`arbitrating-findings`: in all three, the check is worth what its independence is worth.

### Rewriter dispatch payload

```json
{
  "file":          "<absolute path in the working tree>",
  "hunks":         [{"start": 104, "end": 131}],
  "before_path":   "<absolute path to .vernacular/<run>/before/<path>>",
  "receipt_path":  "<absolute path to .vernacular/<run>/receipts/<slug>.json>",
  "skill_path":    "<absolute path to the SKILL.md this dispatch names>",
  "gate_path":     "<absolute path to comprehension-gate.md>",
  "diagram_path":  "<absolute path to diagram-rules.md>",
  "schema_path":   "<absolute path to receipt-schema.md>"
}
```

`hunks` carries **working-tree line numbers** — the after side of `git diff --unified=0`,
computed by the conductor from the diff alone without opening the file. `receipt_path` slugs
the repository-relative path by replacing `/` with `-`, so two files of the same basename in
different directories cannot collide.

Every path is named. A subagent cannot resolve a relative citation from a directory it was
never told it is standing in — the defect guardtower found on its first live run, where an
analyst was told to write "the shape `finding-schema.md` defines" and never told where that
document was.

### Verifier dispatch payload

```json
{
  "file":         "<absolute path in the working tree>",
  "before_path":  "<absolute path to the before copy>",
  "receipt_path": "<the receipt the rewriter wrote>",
  "skill_path":   "<absolute path to the SKILL.md this dispatch names>"
}
```

The verifier reverts in place and **amends the receipt** to drop the reverted edits, so the
receipt the conductor reconciles against always describes the file's final state.

### Receipt schema

```json
{
  "file": "src/Billing.php",
  "edits": [
    {"start": 108, "end_before": 110, "lines_after": 9},
    {"start": 240, "end_before": 239, "lines_after": 7}
  ],
  "left_alone": 4,
  "reverted": [
    {"start": 302, "claim": "states it retries three times; no retry exists in the method"}
  ]
}
```

`end_before = start - 1` is an **insertion** — a zero-length before-range. Writing a
docblock where none existed needs no special case; the arithmetic below covers it unchanged.

**Every anchor is a before-file line number, and `lines_after` is a count, not a position.**
This is not cosmetic. If an edit carried its after-file end line, then the verifier reverting
one edit would silently invalidate the recorded position of every edit below it in the file,
and Proof 1 would compare the wrong ranges — failing a clean run, or worse, passing a dirty
one. With before-anchors plus a count, reconcile derives after-file positions by walking the
edits in ascending `start` and accumulating the drift, and **removing a reverted edit
requires no renumbering at all.**

Edits are sorted by `start` and may not overlap. The verifier reverts bottom-up and deletes
the edit from `edits`, recording it under `reverted`.

A rewriter returns the receipt path and a one-line count. It never returns prose, and never
returns a description it wrote. If the conductor finds itself reading a docblock, the
firewall has already failed.

## Reconcile

Two proofs, both shell, both total. The conductor runs them and reads exit codes and
offending paths — never file content.

**Proof 1 — nothing outside the claimed ranges moved.** Delete every claimed range from the
`before/` copy and from the working-tree file. The remainders must be byte-identical.

**Proof 2 — no structured annotation was inside a claimed range.** Scan the **before** file's
claimed ranges for annotation lines. One hit halts the run.

An **annotation line** is one whose first non-whitespace content, after an optional comment
leader (`*`, `#`, `//`, `///`, `--`), begins with `@`, or matches a Sphinx field
(`:param`, `:type`, `:returns`, `:rtype`, `:raises`). This is a pattern, not a language
table — it needs no knowledge of the file it is applied to.

It is deliberately over-inclusive, and the asymmetry is the reason: a false positive costs
one docblock left un-rewritten, which the report names under **Skipped**. A false negative
costs a mangled annotation in the user's source. Widen this pattern freely; never narrow it
to catch a few more docblocks.

Proof 2 is checked against the before file deliberately. That makes it a **precondition on
the ranges** rather than a comparison of two states: the rewriter cannot have altered a tag,
because a range containing one was never legal to claim. There is no window in which a tag
is edited and then detected.

Together the two proofs discharge invariants 1 and 2 without the tool knowing what language
it is looking at.

### On failure

Restore the file from `before/`, move the corrupted version to `quarantine/<path>`, and halt
the run. The user's tree is safe and the evidence survives.

guardtower's **never auto-revert** rule does not transfer here, and the difference is worth
naming so nobody re-imports it. There, a violation is an unexpected write into a tree the
tool promised never to touch, and reverting would destroy the evidence of a bug worth
diagnosing. Here, the tool writes to source files by design, and a proof failure means it has
demonstrably corrupted one. Leaving a corrupted source file in place is the worse outcome;
quarantining preserves everything a diagnosis needs.

## Preflight

1. **Not a git repository** → stop.
2. **Resolve the ref.** No argument means the current branch against its merge-base with the
   default branch. An argument may be a branch, or a PR/MR reference.
3. **Any in-scope file modified relative to `HEAD`** → **halt**, name the files, say commit
   or stash. The comparison is against `HEAD`, not against the merge-base: every in-scope
   file differs from the merge-base by definition — that is what put it in scope — and the
   thing at risk is work the branch has not committed yet.

   This is load-bearing and non-obvious. The whole delivery model is "the rewrites land in
   your working tree, `git diff` is the review, `git checkout` is the undo." That undo is
   only safe if there is nothing else in the file to lose. A run over a dirty file offers an
   undo that destroys the user's uncommitted work.
4. **No changed files** → say so plainly and stop.
5. **Snapshot** every in-scope file to `before/<path>` with `cp`. A copy is a shell
   operation, not a read; the bytes never enter the conductor's context, and they are the
   left-hand side of Proof 1.

## Run directory

`.vernacular/<YYYY-MM-DD>-<ref>-<suffix>/` at the repository root, where `suffix` is six
lowercase alphanumerics from the system entropy source, never from the model:

```sh
LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 6
```

```
before/<path>          byte copies — Proof 1's left-hand side
receipts/<slug>.json   claimed ranges, per file
quarantine/<path>      only on a proof failure
report.md              the run's account of itself
```

A random suffix means a run never enumerates prior runs to pick a name, so "a run never reads
a previous run's artifacts" holds with no carve-out. If the directory somehow exists,
regenerate rather than reuse.

## The report

Every run names four things:

- **Rewritten**, per file.
- **Left alone**, with a count.
- **Reverted by the verifier**, each with the claim the code did not support.
- **Skipped**, with the reason.

The left-alone count is not decoration. It is the only evidence the user has that the gate is
still discriminating rather than rubber-stamping, and a report that omits it makes a run that
rewrote everything indistinguishable from one that judged carefully.

Both proofs are reported explicitly, pass or fail. An unavailable check that goes unmentioned
reads exactly like a check that passed.

## Invocation

`/vernacular [ref]`.

**No hook.** verity may fire on a session hook because it only ever adds test files. This
writes to source, so it is asked for. A documentation pass that starts on its own and edits
code the user did not ask it to touch is a worse tool than one that has to be invoked.

## Plugin layout

```
vernacular/
├── .claude-plugin/plugin.json
├── README.md
├── commands/vernacular.md
├── skills/
│   ├── clarifying-docblocks/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── comprehension-gate.md
│   │       ├── diagram-rules.md
│   │       └── receipt-schema.md
│   ├── rewriting-docblock-prose/SKILL.md
│   └── verifying-docblock-claims/SKILL.md
└── tests/
    ├── validate.sh
    └── e2e.sh
```

Plus an entry in `.claude-plugin/marketplace.json` and a row in the root `README.md` table.

## Testing

| Test | Asserts |
|---|---|
| Fixtures in several languages with known-bad docblocks | The gate fires without language detection |
| Rogue receipt — claims a range it did not touch | Proof 1 halts |
| Rogue receipt — range contains `@param` | Proof 2 halts |
| Missing-docblock fixture | Insertion arithmetic (`end_before = start - 1`) holds |
| Fixture whose prose already passes the gate | Survives a run byte-identical |
| Dirty in-scope file | Preflight halts before any dispatch |
| Verifier fixture with an unsupported claim | Reverted, receipt amended, revert named in the report |

The good-prose fixture matters most. Invariant 3 is the one that rots silently — a gate that
drifts toward rewriting everything still produces plausible output on every other test.

## What vernacular does not guarantee

- **That the new prose is right.** The verifier tests assertions against the code and reverts
  what it cannot support. It cannot detect prose that is true, comprehensible, and misses the
  point.
- **That your documentation is now complete.** Scope is the diff. Symbols the branch did not
  touch keep whatever prose they had.
- **Type coverage.** It writes no annotations, including on symbols that have none. That is a
  static analysis concern and this tool is deliberately incapable of touching it.
- **That a diagram is the best diagram.** It draws when there is a shape and stays quiet
  otherwise; it does not iterate toward the clearest possible rendering.
