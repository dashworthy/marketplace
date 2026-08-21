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
def unquote(s):
    s = s.strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in "\"'":
        s = s[1:-1]
    return s
name_v = unquote(name.group(1)) if name else None
desc_v = unquote(desc.group(1)) if desc else None
assert name and name_v == skill, f"name must equal dir '{skill}'"
assert desc and desc_v, "description required"
if want:
    assert desc_v.startswith(want), f"description must open with {want}"
print("ok",skill)
PY
echo "PASS frontmatter $skill"
