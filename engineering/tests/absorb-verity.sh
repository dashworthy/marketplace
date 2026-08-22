#!/bin/sh
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
if grep -rn "\.verity" skills; then echo "FAIL: stale .verity path"; fail=1; fi
if grep -rn "verity:" skills; then echo "FAIL: stale verity: namespace"; fail=1; fi
# Verity's session-start reminder must NOT be ported: the only hook is the entrance bootstrap.
if grep -rq "Verity applies once implementation work is finished" hooks/ 2>/dev/null; then
  echo "FAIL: verity session-start reminder was ported"; fail=1; fi
[ -f hooks/session-start.sh ] && grep -q "/triage" hooks/session-start.sh || { echo "FAIL: entrance bootstrap missing"; fail=1; }
[ "$fail" = 0 ] && echo "PASS absorb-verity.sh" || exit 1
