#!/bin/sh
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/frontmatter.sh" "$d/../skills/writing-plans" "[Planning]"
sh "$d/frontmatter.sh" "$d/../skills/executing-plans" "[Planning]"
sh "$d/frontmatter.sh" "$d/../skills/brainstorming" "[Design]"
sh "$d/frontmatter.sh" "$d/../skills/prototype" "[Design]"
sh "$d/frontmatter.sh" "$d/../skills/research"
sh "$d/frontmatter.sh" "$d/../skills/resolving-merge-conflicts"
sh "$d/frontmatter.sh" "$d/../skills/wizard"
sh "$d/frontmatter.sh" "$d/../skills/triage" "[Triage]"
sh "$d/triage.sh"
# cross-cutting skills must NOT open with a [Group] tag
for s in research resolving-merge-conflicts wizard; do
  python3 -c "import re,sys;d=open(sys.argv[1]).read();m=re.search(r'^description:\s*\"?(.)',d,re.M);assert m and m.group(1)!='[', sys.argv[1]" "$d/../skills/$s/SKILL.md"
done
echo "ALL PLAN-03 CHECKS PASS"
