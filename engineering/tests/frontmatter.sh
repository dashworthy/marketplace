#!/bin/sh
# Validate a skill's YAML frontmatter: `name` present and matches its dir; `description`
# present; and, if a [Group] tag is required, the description opens with one.
# Usage: frontmatter.sh <skill-dir> [required-group-tag]
set -e
dir=$1; want_tag=$2
skill=$(basename "$dir")
f="$dir/SKILL.md"
[ -f "$f" ] || { echo "FAIL: no SKILL.md in $dir"; exit 1; }
python3 - "$f" "$skill" "$want_tag" <<'PY'
import sys,re
f,skill,want=sys.argv[1],sys.argv[2],sys.argv[3]
t=open(f,encoding="utf-8").read()
m=re.match(r'^---\n(.*?)\n---\n', t, re.S)
assert m, "no frontmatter block"
fm=m.group(1)
name=re.search(r'^name:\s*(.+)$', fm, re.M)
desc=re.search(r'^description:\s*(.+)$', fm, re.M)
assert name and name.group(1).strip()==skill, f"name must equal dir '{skill}'"
assert desc and desc.group(1).strip(), "description required"
if want:
    assert desc.group(1).strip().startswith(want), f"description must open with {want}"
print("ok",skill)
PY
echo "PASS frontmatter $skill"
