#!/bin/sh
# Two invocations in one session must resolve to the SAME <run> (G7).
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
SCRIPT="$ROOT/engineering/scripts/run-context.sh"
TMP=$(mktemp -d)
cd "$TMP"
A=$(sh "$SCRIPT" signal my-feature)
B=$(sh "$SCRIPT" vernacular)          # no slug: must join the run A created
runA=$(basename "$(dirname "$A")")
runB=$(basename "$(dirname "$B")")
[ "$runA" = "$runB" ] || { echo "FAIL: runs differ ($runA vs $runB)"; exit 1; }
[ -f "$TMP/.engineering/.current-run" ] || { echo "FAIL: pointer not written"; exit 1; }
[ -d "$A" ] && [ -d "$B" ] || { echo "FAIL: scratch dirs not created"; exit 1; }
case "$runA" in [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*) : ;; *) echo "FAIL: run id malformed: $runA"; exit 1;; esac
echo "PASS run-context.sh (run=$runA)"
