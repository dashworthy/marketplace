# vernacular

**Diff-scoped documentation hardening.** It rewrites the docblock prose your branch touched so
a human reading the code can tell what it is for - and proves it changed nothing else.

## Two properties it serves

**Prose only.** vernacular writes human-readable descriptions. It never writes, edits or
deletes a structured annotation - `@param`, `@return`, `@throws`, `@var`, generics,
Psalm/PHPStan annotations, Sphinx field lists - including on symbols that have none. Static
analysis cannot break, because the tool cannot reach the lines static analysis reads.

**Provably nothing else moved.** Every rewriter reports the exact line ranges it replaced.
Delete those ranges from the before-file and the after-file, and the remainders must be
byte-identical. Separately, a range containing an annotation was never legal to claim. Either
proof failing halts the run, restores your files, and quarantines the evidence.

## It identifies no language

There is no stack detection, no per-language docblock syntax table, and no skip list.
Recognising a docblock is something a model reading a file does the way you do, and the proof
that nothing else moved is line arithmetic, which is identical in every language. It works on
PHP, Go, Ruby, Terraform, or a language written after this README.

## How a run flows

```
preflight --> snapshot --> rewrite (per file) --> verify (per file) --> reconcile --> report
                              |____ pipelined, no barrier ____|          barrier
```

The conductor never opens a source file. Per changed file it dispatches a rewriter, which
applies the comprehension gate and returns a receipt of line ranges; then an **independent**
verifier, which tests every new assertion against the code and reverts what the code does not
support. A rewriter grading its own prose agrees with itself, which is why those are two
agents.

## Installation

```
/plugin marketplace add https://github.com/dashworthy/development-skills
/plugin install vernacular@dashworthy
```

## How to run it

```
/vernacular            the current branch against its merge-base
/vernacular <branch>   a named branch
/vernacular 482        a PR or MR
```

Rewrites land unstaged in your working tree. `git diff` is the review; `git checkout -- .` is
the undo.

## Before it will start

It halts if any file in scope has uncommitted changes relative to `HEAD`. The undo it promises
you is only safe when there is nothing else in the file to lose.

## What vernacular does not guarantee

- **That the new prose is right.** The verifier tests assertions against the code and reverts
  what it cannot support. It cannot detect prose that is true, comprehensible, and misses the
  point.
- **That your documentation is now complete.** Scope is the diff. Symbols your branch did not
  touch keep whatever prose they had.
- **Type coverage.** It writes no annotations, including on symbols that have none. That is a
  static analysis concern, and this tool is deliberately incapable of touching it.
- **That a diagram is the best diagram.** It draws when there is a shape and stays quiet
  otherwise; it does not iterate toward the clearest possible rendering.
