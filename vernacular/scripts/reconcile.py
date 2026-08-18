#!/usr/bin/env python3
"""vernacular's reconcile checker.

Proves, from receipts alone, that a run touched only what it said it touched.
Reads <run-dir>/receipts/*.json; prints one line per receipt; mutates nothing.

Restoring a corrupted file and quarantining the evidence is the conductor's
job, not this script's. A checker that also mutates cannot be tested by
running it.

Exit codes:
  0  every receipt passed every proof
  1  at least one proof failed
  2  a receipt or a file it names is malformed, missing, or unreadable
"""
import json
import pathlib
import sys

EXIT_OK, EXIT_PROOF_FAILED, EXIT_MALFORMED = 0, 1, 2


def load_lines(path):
    # newline='' keeps line terminators intact, so a proof compares the bytes
    # that are actually in the file rather than a normalisation of them.
    with open(path, newline='') as fh:
        return fh.readlines()


def after_ranges(edits):
    """Derive after-file ranges by walking edits in ascending start order.

    Every anchor in a receipt is a BEFORE-file line number, and lines_after is
    a count rather than a position. That is what lets the verifier delete a
    reverted edit without renumbering the ones below it: drift is recomputed
    here on every run instead of being stored.

    Yields (before_start, before_end, after_start, after_end) with inclusive,
    1-based bounds. An empty range is represented as end < start.
    """
    drift = 0
    for e in sorted(edits, key=lambda x: x["start"]):
        b_start, b_end = e["start"], e["end_before"]
        a_start = b_start + drift
        a_end = a_start + e["lines_after"] - 1
        yield b_start, b_end, a_start, a_end
        drift += e["lines_after"] - (b_end - b_start + 1)


def strip(lines, ranges):
    """Return lines with every 1-based inclusive range removed."""
    drop = set()
    for start, end in ranges:
        drop.update(range(start, end + 1))
    return [ln for i, ln in enumerate(lines, start=1) if i not in drop]


def check_receipt(path):
    """Return (status, message). status is one of ok / fail / malformed."""
    try:
        receipt = json.loads(pathlib.Path(path).read_text())
        edits = receipt["edits"]
        before_lines = load_lines(receipt["before"])
        after_lines = load_lines(receipt["file"])
        for e in edits:
            for key in ("start", "end_before", "lines_after"):
                if not isinstance(e[key], int):
                    raise TypeError(f"{key} is not an integer")
    except Exception as exc:  # noqa: BLE001 - any failure here is malformed input
        return "malformed", f"{type(exc).__name__}: {exc}"

    spans = list(after_ranges(edits))

    # Overlapping claims would make the arithmetic ambiguous, and a receipt
    # that claims the same line twice is a rewriter bug worth surfacing rather
    # than silently tolerating.
    prev_end = 0
    for b_start, b_end, _, _ in spans:
        if b_start <= prev_end:
            return "malformed", f"overlapping claimed ranges at before-line {b_start}"
        prev_end = max(prev_end, b_end)

    before_rest = strip(before_lines, [(b0, b1) for b0, b1, _, _ in spans])
    after_rest = strip(after_lines, [(a0, a1) for _, _, a0, a1 in spans])

    if before_rest != after_rest:
        return "fail", "proof1 remainder differs outside the claimed ranges"
    return "ok", ""


def main(argv):
    if len(argv) != 2:
        print("usage: reconcile.py <run-dir>", file=sys.stderr)
        return EXIT_MALFORMED

    receipts = sorted((pathlib.Path(argv[1]) / "receipts").glob("*.json"))
    if not receipts:
        print("no receipts found", file=sys.stderr)
        return EXIT_MALFORMED

    exit_code = EXIT_OK
    for r in receipts:
        status, message = check_receipt(r)
        if status == "ok":
            print(f"ok   {r.name}")
        elif status == "fail":
            print(f"FAIL {r.name} {message}")
            exit_code = max(exit_code, EXIT_PROOF_FAILED)
        else:
            print(f"MALFORMED {r.name} {message}")
            exit_code = EXIT_MALFORMED
    return exit_code


if __name__ == "__main__":
    sys.exit(main(sys.argv))
