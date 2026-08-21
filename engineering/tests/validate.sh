#!/bin/sh
# Structural and behavioural validation for the engineering plugin.
# POSIX sh. Uses python3 (stdlib only) for JSON. Never requires jq.
# Run from anywhere: sh engineering/tests/validate.sh

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
PLUGIN="$ROOT/engineering"
fail=0

ok()   { printf 'ok   - %s\n' "$1"; }
bad()  { printf 'FAIL - %s\n' "$1"; fail=1; }
check(){ if [ "$1" -eq 0 ]; then ok "$2"; else bad "$2"; fi }

# Match a prose anchor regardless of how the source is line-wrapped. Prose in these documents is
# wrapped for readability; a check that depends on where the wrap falls breaks on a purely
# cosmetic reflow. `--` before the pattern is load-bearing: without it grep parses an anchor
# beginning with a hyphen as its own options and dies with a usage error instead of searching.
grep_flat() {  # grep_flat <file> <literal phrase>
  tr '\n' ' ' < "$1" | tr -s ' ' | grep -qF -- "$2"
}

# --- manifest ---------------------------------------------------------------

[ -f "$PLUGIN/.claude-plugin/plugin.json" ]; check $? "plugin.json exists"

if [ -f "$PLUGIN/.claude-plugin/plugin.json" ]; then
  python3 - "$PLUGIN/.claude-plugin/plugin.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
required={"name","description","version","author","license"}
missing=required-set(d)
assert not missing, f"plugin.json missing keys: {sorted(missing)}"
assert d["name"]=="engineering", f'name is {d["name"]!r}, expected "engineering"'
assert d["version"]=="0.1.0", f'version is {d["version"]!r}, expected "0.1.0"'
assert d["license"]=="MIT", f'license is {d["license"]!r}, expected "MIT"'
PY
  check $? "plugin.json is well-formed"
fi

# --- marketplace registration ------------------------------------------------

python3 - "$ROOT/.claude-plugin/marketplace.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
names=[p["name"] for p in d["plugins"]]
assert "engineering" in names, f"engineering not registered; found {names}"
e=[p for p in d["plugins"] if p["name"]=="engineering"][0]
assert e["source"]=="./engineering", f'source is {e["source"]!r}'
assert e["version"]=="0.1.0", f'version is {e["version"]!r}'
PY
check $? "engineering is registered in the dashworthy marketplace"

# --- references --------------------------------------------------------------

REF="$PLUGIN/skills/clarifying-docblocks/references"
for f in comprehension-gate.md diagram-rules.md receipt-schema.md; do
  [ -f "$REF/$f" ]; check $? "references/$f exists"
done

if [ -f "$REF/comprehension-gate.md" ]; then
  grep_flat "$REF/comprehension-gate.md" "Restates the signature";       check $? "gate names the restates-the-signature failure"
  grep_flat "$REF/comprehension-gate.md" "Describes mechanism, not purpose"; check $? "gate names the mechanism failure"
  grep_flat "$REF/comprehension-gate.md" "Machine-facing residue";       check $? "gate names the machine-residue failure"
  grep_flat "$REF/comprehension-gate.md" "When in doubt, leave it";      check $? "gate states the leave-it default"
fi

if [ -f "$REF/diagram-rules.md" ]; then
  grep_flat "$REF/diagram-rules.md" "72 columns including the comment leader"; check $? "diagram rules state the width budget"
fi

if [ -f "$REF/receipt-schema.md" ]; then
  grep_flat "$REF/receipt-schema.md" "lines_after";  check $? "receipt schema documents lines_after"
  grep_flat "$REF/receipt-schema.md" "end_before = start - 1"; check $? "receipt schema documents the insertion form"
fi

# No language table may be reintroduced in vernacular's own docs skills — this is
# vernacular's invariant that it never hard-codes a language/stack table. Scoped to just
# those three skill dirs: verity's conducting-test-hardening legitimately ships its own
# detecting-the-stack.md / stack-markers.md references, and those must not trip this check.
if find "$PLUGIN/skills/clarifying-docblocks" "$PLUGIN/skills/rewriting-docblock-prose" "$PLUGIN/skills/verifying-docblock-claims" -type f -exec grep -liE 'detecting-the-stack|stack-marker' {} + 2>/dev/null | grep -q .; then
  bad "no stack-detection artefact exists in the vernacular docs skills"
else
  ok "no stack-detection artefact exists in the vernacular docs skills"
fi

# --- rewriter ----------------------------------------------------------------

REWRITER="$PLUGIN/skills/rewriting-docblock-prose/SKILL.md"
[ -f "$REWRITER" ]; check $? "rewriting-docblock-prose/SKILL.md exists"

if [ -f "$REWRITER" ]; then
  head -1 "$REWRITER" | grep -q '^---$'; check $? "rewriter has frontmatter"
  grep -q '^name: rewriting-docblock-prose$' "$REWRITER"; check $? "rewriter frontmatter names itself"
  grep_flat "$REWRITER" "never return a description you wrote"; check $? "rewriter states the receipt-only return"
  grep_flat "$REWRITER" "Never claim a range containing an annotation line"; check $? "rewriter states the annotation prohibition"
  grep_flat "$REWRITER" "whole lines"; check $? "rewriter states the whole-line replacement rule"
fi

# --- verifier ----------------------------------------------------------------

VERIFIER="$PLUGIN/skills/verifying-docblock-claims/SKILL.md"
[ -f "$VERIFIER" ]; check $? "verifying-docblock-claims/SKILL.md exists"

if [ -f "$VERIFIER" ]; then
  grep -q '^name: verifying-docblock-claims$' "$VERIFIER"; check $? "verifier frontmatter names itself"
  grep_flat "$VERIFIER" "Revert, never repair"; check $? "verifier states revert-never-repair"
  grep_flat "$VERIFIER" "bottom-up"; check $? "verifier states the bottom-up revert order"
  grep_flat "$VERIFIER" "deleted from"; check $? "verifier states that a reverted edit leaves edits[]"
fi

# --- conductor ---------------------------------------------------------------

COND="$PLUGIN/skills/clarifying-docblocks/SKILL.md"
[ -f "$COND" ]; check $? "clarifying-docblocks/SKILL.md exists"

if [ -f "$COND" ]; then
  grep -q '^name: clarifying-docblocks$' "$COND"; check $? "conductor frontmatter names itself"
  grep_flat "$COND" "file modified relative to"; check $? "conductor states the dirty-file halt"
  grep_flat "$COND" "never opens a source file"; check $? "conductor states the context firewall"
  grep_flat "$COND" "restore it from"; check $? "conductor states the quarantine-and-restore path"
  grep_flat "$COND" "Left alone"; check $? "conductor reports the left-alone count"
  grep_flat "$COND" "run-context.sh"; check $? "conductor derives the run directory via run-context.sh"
  # Every dispatch payload must name skill_path - the defect guardtower found live.
  grep -c 'skill_path' "$COND" | awk '$1 >= 2 {exit 0} {exit 1}'
  check $? "conductor names skill_path in both dispatch payloads"
  ! grep_flat "$COND" "so there is none to read"
  check $? "conductor does not claim --unified=0 removes the diff body"
  grep_flat "$COND" "Never run a bare"; check $? "conductor forbids the unfiltered git diff"
fi

# --- command and READMEs ------------------------------------------------------

CMD="$PLUGIN/commands/vernacular.md"
[ -f "$CMD" ]; check $? "commands/vernacular.md exists"
if [ -f "$CMD" ]; then
  grep -q '^description:' "$CMD"; check $? "command has a description"
  grep_flat "$CMD" "clarifying-docblocks"; check $? "command invokes the conductor by name"
fi

[ -f "$PLUGIN/README.md" ]; check $? "engineering/README.md exists"

# The cutover plan is what updates the root README to list engineering; until then this one
# check is expected to fail. See the vernacular-absorption task's report for the note.
grep_flat "$ROOT/README.md" "engineering"; check $? "root README lists engineering"

exit $fail
