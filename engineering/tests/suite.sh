#!/bin/sh
# Foundation suite: every non-live check. (e2e.sh is live/CI-only and excluded here.)
set -e
d=$(CDPATH= cd "$(dirname "$0")" && pwd)
sh "$d/hook.sh"
sh "$d/run-context.sh"
sh "$d/reconcile.sh"
sh "$d/absorb-signal.sh"
sh "$d/absorb-vernacular.sh"
sh "$d/absorb-verity.sh"
for s in to-spec:'[Discovery]' conducting-discovery:'[Discovery]' interrogating-requirements:'[Discovery]' expanding-scope:'[Discovery]' sequencing-requirements:'[Discovery]' clarifying-docblocks:'[Docs]' rewriting-docblock-prose:'[Docs]' verifying-docblock-claims:'[Docs]' conducting-test-hardening:'[Test hardening]' auditing-test-gaps:'[Test hardening]' verifying-test-integrity:'[Test hardening]' writing-tests-from-brief:'[Test hardening]'; do
  name=${s%%:*}; tag=${s#*:}
  sh "$d/frontmatter.sh" "$d/../skills/$name" "$tag"
done
echo "ALL FOUNDATION CHECKS PASS"
