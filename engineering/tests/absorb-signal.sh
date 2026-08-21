#!/bin/sh
# No stale signal: namespaces or .signal/ paths survive absorption; brief is Tier-2;
# spec-writing is delegated to to-spec.
set -e
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT/engineering"
fail=0
if grep -rn "signal:" skills/conducting-discovery skills/interrogating-requirements skills/expanding-scope skills/sequencing-requirements commands/signal.md; then
  echo "FAIL: stale 'signal:' namespace refs"; fail=1; fi
if grep -rn "\.signal/" skills commands/signal.md; then
  echo "FAIL: stale '.signal/' paths"; fail=1; fi
grep -q "engineering:conducting-discovery" commands/signal.md || { echo "FAIL: command must dispatch engineering:conducting-discovery"; fail=1; }
grep -rq "\.engineering/" skills/conducting-discovery/SKILL.md || { echo "FAIL: run dir not redirected to .engineering/"; fail=1; }
grep -rq "to-spec" skills/sequencing-requirements/SKILL.md skills/conducting-discovery/SKILL.md || { echo "FAIL: spec-writing not delegated to to-spec"; fail=1; }
[ "$fail" = 0 ] && echo "PASS absorb-signal.sh" || exit 1
