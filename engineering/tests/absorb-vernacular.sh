#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
if grep -rn "\.vernacular" skills commands/vernacular.md; then echo "FAIL: stale .vernacular path"; fail=1; fi
grep -rq "\.engineering/" skills/clarifying-docblocks/SKILL.md || { echo "FAIL: run dir not redirected"; fail=1; }
[ "$fail" = 0 ] && echo "PASS absorb-vernacular.sh" || exit 1
