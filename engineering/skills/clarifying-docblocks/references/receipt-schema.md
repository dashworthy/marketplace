# Receipt schema

One receipt per file, written by the rewriter to `receipt_path`, amended by the verifier.

```json
{
  "file": "/abs/path/in/the/working/tree/src/Billing.php",
  "before": "/abs/path/to/.engineering/<run>/vernacular/before/src/Billing.php",
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

## Every anchor is a before-file line number

`start` and `end_before` index the **before** file. `lines_after` is a **count**, not a
position.

This is not cosmetic. If an edit carried its after-file end line, then the verifier reverting
one edit would silently invalidate the recorded position of every edit below it in the file,
and Proof 1 would compare the wrong ranges - failing a clean run, or worse, passing a dirty
one. With before-anchors plus a count, `reconcile.py` derives after-file positions by walking
the edits in ascending `start` and accumulating the drift, so **removing a reverted edit
requires no renumbering at all.**

## Insertions

`end_before = start - 1` is an insertion - a zero-length before-range. Writing a docblock
where none existed needs no special case; the same arithmetic covers it.

## Constraints

- Edits are sorted by `start` and **may not overlap**. `reconcile.py` exits 2 on an overlap.
- `left_alone` counts descriptions the gate examined and deliberately did not touch. It is
  reported on every run and must not be omitted or estimated.
- `reverted` is written by the verifier. Each entry names the claim the code did not support,
  and the corresponding edit is **deleted from `edits`** so the receipt always describes the
  file's final state.
