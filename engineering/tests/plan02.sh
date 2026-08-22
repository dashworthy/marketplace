#!/bin/sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/frontmatter.sh" "$d/../skills/codebase-design" "[Design]"
sh "$d/frontmatter.sh" "$d/../skills/domain-modeling" "[Discovery]"
sh "$d/frontmatter.sh" "$d/../skills/tdd" "[Build]"
sh "$d/frontmatter.sh" "$d/../skills/diagnosing-bugs" "[Build]"
sh "$d/frontmatter.sh" "$d/../skills/code-review" "[Build]"
sh "$d/frontmatter.sh" "$d/../skills/improve-codebase-architecture" "[Design]"
# No NOTICE / attribution introduced by this plan.
if grep -rIl "NOTICE\|Matt Pocock\|superpowers by" "$d/../skills/codebase-design" "$d/../skills/domain-modeling" "$d/../skills/tdd" "$d/../skills/diagnosing-bugs" "$d/../skills/code-review" "$d/../skills/improve-codebase-architecture" 2>/dev/null; then
  echo "FAIL: attribution/NOTICE leak"; exit 1; fi
echo "ALL PLAN-02 CHECKS PASS"
