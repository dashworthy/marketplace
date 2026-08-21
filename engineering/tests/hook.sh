#!/bin/sh
# Verifies the entrance-bootstrap hook emits valid JSON that names both entrances
# and points at using-skills. No install required.
ROOT=$(CDPATH= cd "$(dirname "$0")/../.." && pwd)
OUT=$(CLAUDE_PLUGIN_ROOT="$ROOT/engineering" sh "$ROOT/engineering/hooks/session-start.sh") || { echo "FAIL: hook exited non-zero"; exit 1; }
printf '%s' "$OUT" | python3 -c '
import json,sys
d=json.load(sys.stdin)
c=d["hookSpecificOutput"]["additionalContext"]
assert d["hookSpecificOutput"]["hookEventName"]=="SessionStart", d
assert "/signal" in c and "/triage" in c, "must name both entrances"
assert "using-skills" in c, "must point at using-skills"
print("ok")
' || { echo "FAIL: hook output invalid"; exit 1; }
echo "PASS hook.sh"
