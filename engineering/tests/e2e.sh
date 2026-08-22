#!/bin/sh
# End-to-end: install engineering at local scope in a scratch repo and prove the command is
# discoverable, and that it refuses to run where it cannot. Posts nothing, rewrites nothing.
#
# Properties that matter beyond "call claude -p and grep the output":
#
# 1. "dashworthy" is THIS REPO'S OWN real marketplace name (.claude-plugin/marketplace.json) and
#    the README tells real users to add it. The registration this script creates lives in
#    ~/.claude/plugins/ (known_marketplaces.json, installed_plugins.json) - a single,
#    user-home-scoped registry, NOT anything confined to $TMP. A test script must never remove -
#    or silently repoint - a marketplace registration it did not itself create in this run. See
#    detect_state and the ownership snapshot below: detection is three-state (absent/present/
#    unknown), not a boolean, because a TRANSIENT FAILURE of the detection command itself must
#    never be treated the same as a confirmed-empty registry - both "present" and "unknown" mean
#    "do not touch," and the whole test is skipped rather than risk it.
# 2. Nothing may bound a `claude -p` call that never returns. A child that traps or ignores
#    SIGTERM (or is itself blocked inside a graceful-shutdown path on the same stuck network call)
#    must still be dead at roughly the limit plus a short grace period, not run to its own natural
#    end - see run_limited's TERM-then-KILL escalation below.
# 3. A transient API failure (429/5xx/529, "please run /login") must never be reported as "the
#    plugin is broken" - see classify_claude_failure.
# 4. Both checks below that depend on single-turn model narration completing within one
#    non-interactive `-p` call (discoverability, and the dirty-file halt) are retried with quorum
#    rather than graded on a single attempt - see run_with_quorum below for why that is safe: a
#    genuine regression fails the same way every time; narration noise does not.
#
# The helpers below (run_limited, classify_claude_failure, run_with_quorum, detect_state, the
# ownership snapshot, and cleanup/trap) are carried over verbatim from guardtower's e2e.sh
# (guardtower/tests/e2e.sh on the guardtower branch), with only the plugin-specific names adapted
# (guardtower -> vernacular -> engineering, .guardtower -> .vernacular -> .engineering). They
# encode hard-won behaviour that is not specific to any one plugin: a portable timeout escalation,
# a classifier that separates a transient API failure from a real regression, and quorum retry for
# single-turn narration flakiness.

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
TMP=$(mktemp -d)
fail=0
inconclusive=0

# Seconds allowed for each `claude -p` call before TERM is sent, and the grace period after TERM
# before escalating to KILL. Overridable (e.g. for a slower machine, or to deliberately shrink
# either while proving the limiter itself works).
CLAUDE_E2E_TIMEOUT=${CLAUDE_E2E_TIMEOUT:-180}
GRACE_KILL_SECS=${GRACE_KILL_SECS:-3}

# Portable timeout with escalation. Prefer timeout(1) or gtimeout(1) when either is on PATH -
# both support -k to escalate to KILL if the command is still alive GRACE_KILL_SECS after the
# initial TERM. Neither ships on stock macOS - there is no timeout(1), and gtimeout exists only
# if coreutils was installed separately, which must not be assumed - so the fallback implements
# the same TERM-then-grace-then-KILL escalation by hand. A single `kill -TERM` with no escalation
# is not sufficient: a child that traps or ignores TERM (proven with a
# `trap '' TERM; sleep 300` fixture) is left running for its full natural duration instead of
# dying at the limit.
#
# The watchdog subshell traps TERM on itself and kills whichever `sleep` it is currently blocked
# in before exiting. This matters on the FAST path too, not just the timeout path: killing only
# the subshell wrapper (as an earlier version of this script did) leaves the `sleep` it forked
# still running - shells do not propagate a signal to a background child just because the parent
# that spawned it died - so that sleep reparents to init and runs out its own remaining duration.
# Verified (see the fix report) that a fast-exiting command left an orphaned `sleep` behind twice
# under the old design; the trap-and-kill-my-current-child pattern here leaves none.
#
# `$@` is launched under `set -m` (restored immediately after) so it becomes its own process
# group leader rather than sharing this script's group - the default for a background job in a
# non-interactive shell, confirmed empirically on this machine. Both TERM and the KILL escalation
# below are sent to `-$cmd_pid` (the whole group), not just $cmd_pid, so a child THAT COMMAND
# ITSELF spawns - vernacular's own `git`/`gh`/`glab` calls, if `claude -p` is what hangs - is
# reached too, not just the top-level process. Proven necessary: killing only $cmd_pid for a
# `sh stubborn.sh` fixture whose last line is `sleep 300` left that `sleep` running as an orphan
# of init after $cmd_pid itself was gone, because SIGKILLing a parent does not cascade to its
# already-forked children.
#
# Always captures the child's combined stdout+stderr to $2 (callers need the text to diagnose a
# failure) and returns the child's real exit status, or 124 - matching GNU timeout's own
# convention - if the watchdog had to intervene at all (whether TERM alone sufficed or KILL was
# needed), so a caller can tell "ran and failed" from "never finished."
run_limited() {
  secs=$1; outfile=$2; shift 2
  if command -v timeout >/dev/null 2>&1; then
    timeout -k "$GRACE_KILL_SECS" "$secs" "$@" >"$outfile" 2>&1
    return $?
  fi
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout -k "$GRACE_KILL_SECS" "$secs" "$@" >"$outfile" 2>&1
    return $?
  fi

  marker="$outfile.timedout"
  rm -f "$marker"

  set -m
  "$@" >"$outfile" 2>&1 &
  cmd_pid=$!
  set +m

  (
    trap 'kill "$child" 2>/dev/null; exit 0' TERM
    sleep "$secs" & child=$!
    wait "$child" 2>/dev/null
    # Reached only if that sleep ran to completion - i.e. the real command did not finish in
    # time. Mark the intervention now, before whatever escalation it takes to actually stop it,
    # so the marker's presence means "we hit the limit," independent of the TERM/KILL race below.
    : > "$marker"
    kill -TERM -- "-$cmd_pid" 2>/dev/null
    sleep "$GRACE_KILL_SECS" & child=$!
    wait "$child" 2>/dev/null
    # Still alive after TERM + grace - it (or a child it spawned) ignored TERM, or is blocked
    # past it. Escalate to the whole group.
    kill -0 "$cmd_pid" 2>/dev/null && kill -KILL -- "-$cmd_pid" 2>/dev/null
  ) &
  watchdog_pid=$!

  wait "$cmd_pid" 2>/dev/null
  status=$?

  kill -TERM "$watchdog_pid" 2>/dev/null
  wait "$watchdog_pid" 2>/dev/null

  if [ -e "$marker" ]; then
    rm -f "$marker"
    status=124
  fi
  return "$status"
}

# Distinguish "the model API failed us" from "the plugin behaved wrongly," so a transient
# 429/5xx/529 is never reported as a behavioral regression. Narrowing the token list to
# Anthropic-only signatures (rate limiting, "overloaded", 429/500/503/529, an expired CLI session)
# turned out not to be enough on its own: 429, "overloaded", and rate-limit language are standard
# GitHub/GitLab CLI vocabulary too - `gh: API rate limit exceeded...`, `glab: 429 Too Many
# Requests`, `gh: You have exceeded a secondary rate limit` all classified `api` under a
# token-list-only test, which hides exactly the regression this check exists to catch: if a
# forge-detection-ordering bug lets the conductor call gh/glab (or a `git` command hits a forge
# host) BEFORE confirming there is no remote, and that real call hits a genuine rate limit or
# 5xx, a token-only classifier grades it inconclusive instead of FAIL.
#
# The property that makes this decidable: this scratch repo has no remote at all - that is the
# whole point of the test case - so vernacular must never reach a forge here, full stop. Any
# output bearing a forge-tool marker is therefore itself evidence of the behavioral regression,
# regardless of which rate-limit/5xx token happens to also appear in the same text - so the marker
# check runs FIRST and wins outright. Only when no forge marker is present do the remaining tokens
# get treated as evidence of a genuine Anthropic-side outage.
#
# The marker set is deliberately narrow: `gh:`, `glab:`, and `fatal: unable to access` are
# CLI-ERROR-SHAPED PREFIXES those specific tools emit when a real call fails - not phrases a model
# narrates. An earlier, broader version of this list also matched `github\.com`, `gitlab\.com`,
# `merge request`, `pull request`, and a bare `\bgit\b` word - and that broke the OTHER direction:
# `commands/review.md` itself says "Review a GitHub pull request or GitLab merge request" and
# embeds literal github.com/gitlab.com example URLs, so a headless session narrating its own
# command definition back (`I will review the pull request now...`, `...merge request...`) hit
# those markers on completely normal, passing turns that merely happened to co-occur with a real
# Anthropic-side 429/529 - misclassifying a transient outage as `behavior`, which under quorum can
# accumulate into a false FAIL. The asymmetry that makes the narrow set safe: a real forge call
# that fails WILL carry a `gh:`/`glab:`/`fatal:` prefix, because that is how those tools report
# errors - narration never does. Proven against both directions in the fix report: the reviewer's
# four real forge-error strings (`gh: ...`, `glab: ...`, `fatal: unable to access ...`) still
# classify `behavior`; narration that merely mentions "pull request"/"merge request"/github.com/
# gitlab.com/git alongside a real outage token now correctly classifies `api`.
#
# A run_limited timeout (124) is always classified as a timeout, independent of any of this - and
# the `[ "$st" -ne 0 ]` guard means a zero-exit (successful) session is never downgraded by either
# list, regardless of what its text happens to mention.
classify_claude_failure() {  # classify_claude_failure <exit_status> <output_text>
  st=$1; txt=$2
  if [ "$st" -eq 124 ]; then
    printf 'timeout\n'
    return
  fi
  if [ "$st" -ne 0 ]; then
    if printf '%s' "$txt" | grep -qiE 'gh:|glab:|fatal: unable to access'; then
      printf 'behavior\n'
      return
    fi
    if printf '%s' "$txt" | grep -qiE '(^|[^0-9])(429|500|503|529)([^0-9]|$)|overloaded|rate.?limit|please run /login'; then
      printf 'api\n'
      return
    fi
  fi
  printf 'behavior\n'
}

# Run up to 3 attempts of a claude -p call, retrying on both a genuine behavioral fail and an
# api/timeout-classified attempt. The skill under test is deterministic - same repo, same
# instructions, same halt condition - so a real regression fails the SAME way on every attempt,
# while a single-turn narration hiccup (observed manually as 1-of-2 live runs: the session stated
# intent - "Let me proceed with Step 1" - and stopped short of actually running the check that
# turn) resolves on retry. That asymmetry is what quorum is for.
#
# Accept the first "ok" and short-circuit immediately, so the common case still costs exactly one
# call. Grade a real FAIL only once 3 attempts have each completed a genuine behavioral verdict
# and NONE of them passed - an attempt that itself comes back api/timeout-classified is not a
# completed behavioral verdict, so a string of outages cannot manufacture a FAIL on its own; it
# manufactures INCONCLUSIVE instead, same as a single-attempt check would.
#
# Checks 3, 4, and 5 below are consequences of the run never reaching its mutating steps; they
# prove nothing about whether the halt happened for the right reason (a run that hung for an
# unrelated reason before ever calling git would also leave no artifacts and an untouched source
# file), so they cannot substitute for actually observing the halt message here.
#
# Sets on return: qr_result to "ok", "fail", or "inconclusive"; qr_text to the last attempt's
# captured output, for the caller to print on anything but "ok".
run_with_quorum() {  # run_with_quorum <ok_grep_pattern> <claude-arg>...
  ok_pattern=$1; shift
  behavioral_fails=0
  attempt=0
  qr_result="inconclusive"
  qr_text=""
  while [ "$attempt" -lt 3 ]; do
    attempt=$((attempt + 1))
    out=$(mktemp)
    run_limited "$CLAUDE_E2E_TIMEOUT" "$out" "$@"
    st=$?
    txt=$(cat "$out"); rm -f "$out"
    qr_text=$txt
    cls=$(classify_claude_failure "$st" "$txt")
    if [ "$cls" = "behavior" ]; then
      if printf '%s' "$txt" | grep -qiE "$ok_pattern"; then
        qr_result="ok"
        return 0
      fi
      behavioral_fails=$((behavioral_fails + 1))
    fi
    # timeout/api: this attempt is inconclusive on its own; loop again, still bounded by the
    # 3-attempt cap above.
  done
  if [ "$behavioral_fails" -ge 3 ]; then
    qr_result="fail"
  else
    qr_result="inconclusive"
  fi
}

cleanup() {
  [ -d "$TMP/proj" ] && cd "$TMP/proj" 2>/dev/null
  # Only remove when the state is "absent" - see the ownership snapshot below. "unknown" (the
  # detection command itself failed) must behave exactly like "present": touch nothing. Never
  # gated on the cd above succeeding: the registry these act on is user-scoped, not path-scoped,
  # so a failed mkdir/cd must not also skip the cleanup that corresponds to whatever this run did
  # add.
  [ "$plugin_state" = "absent" ] && claude plugin uninstall engineering@dashworthy --scope local >/dev/null 2>&1
  [ "$marketplace_state" = "absent" ] && claude plugin marketplace remove dashworthy >/dev/null 2>&1
  cd / && rm -rf "$TMP"
}
trap cleanup EXIT

# Detects whether something is present, three-state: "absent", "present", or "unknown". A prior
# version used a two-state boolean that defaulted to "not present" and only flipped on a
# successful match, so a TRANSIENT FAILURE of the detection command itself (`claude plugin
# marketplace list` / `claude plugin list` exiting non-zero, no usable stdout) silently fell
# through to the same "safe to remove" state as a genuinely empty registry - an empty match from a
# failed command and an empty match from a real empty registry are indistinguishable by grep alone,
# and conflating them is exactly the fail-open bug: given this build's documented API instability,
# a transient failure of a `claude` subcommand is not a hypothetical, and the old code would have
# let cleanup() delete a real, present registration whenever detection itself glitched. Fixed by
# distinguishing on the command's own EXIT STATUS, not on whether its output happened to contain a
# substring: only a command that exits 0 gets to say "absent" or "present" at all; a non-zero exit
# says only "unknown," and unknown is handled identically to present everywhere below.
detect_state() {  # detect_state <grep_pattern> <command> <arg>...
  pattern=$1; shift
  if ds_out=$("$@" 2>/dev/null); then
    if printf '%s' "$ds_out" | grep -q "$pattern"; then
      printf 'present\n'
    else
      printf 'absent\n'
    fi
  else
    printf 'unknown\n'
  fi
}

# Ownership snapshot - taken before this script does ANYTHING else, so "absent" unambiguously
# means "confirmed not here before this run touched the system," not merely "we didn't see it."
# There is no way to distinguish a leak from a previous crashed run of this exact script from a
# real, permanent user registration by inspection alone - both look identical - so the only safe
# rule is: unless BOTH detections positively confirm absence, this run did not create what's (or
# might be) there, and will not remove or repoint it, ever, no matter how the run ends. That does
# mean a genuine leak from an earlier crash does not self-heal; that is the correct trade, since
# the alternative is a test script that can silently delete or overwrite real configuration.
marketplace_state=$(detect_state 'dashworthy' claude plugin marketplace list)
plugin_state=$(detect_state 'engineering@dashworthy' claude plugin list)

if [ "$marketplace_state" != "absent" ] || [ "$plugin_state" != "absent" ]; then
  printf 'NOTE - marketplace "dashworthy" state: %s. plugin engineering@dashworthy state: %s.\n' "$marketplace_state" "$plugin_state"
  printf 'NOTE - "present" and "unknown" (the detection command itself failed - e.g. a transient CLI/API\n'
  printf 'NOTE - error) are both treated as "do not touch": e2e.sh will not add, install, remove, or\n'
  printf 'NOTE - otherwise touch either one. If either state above is "unknown," check by hand:\n'
  printf 'NOTE - `claude plugin marketplace list` and `claude plugin list`.\n'
  printf '\nINCONCLUSIVE - could not safely confirm dashworthy/engineering@dashworthy is clear; this run does not confirm a regression.\n'
  exit 2
fi

mkdir -p "$TMP/proj" && cd "$TMP/proj" && git init -q
git config user.email t@example.com && git config user.name t
mkdir -p src
cat > src/Billing.php <<'EOF'
<?php
class Billing {
    /**
     * Charges the card.
     * @param int $amount
     */
    public function charge(int $amount): void {}
}
EOF
git add src/Billing.php && git commit -qm init

# Installing is infrastructure, not behavior. If either of these fails - a network blip, a changed
# `claude plugin` interface, a malformed marketplace.json - then every check below fails for a
# reason that has nothing to do with the plugin's behavior, and the first one reports as
# "FAIL - command is discoverable after install": an infrastructure error misattributed as a
# behavioral regression, which is the exact confusion the three-state grading everywhere else in
# this script exists to prevent. Their exit status was previously discarded (`>/dev/null 2>&1` with
# no test), so that misattribution was silent. Grade a non-zero exit INCONCLUSIVE (2) instead, and
# print the output rather than swallowing it, so the reason is on the log. `trap cleanup EXIT` is
# already installed above, so exiting here still uninstalls/removes whatever this run did add.
#
# Deliberately AFTER the `cd "$TMP/proj"` above, not before it: `--scope local` keys the
# registration to the working directory at install time (confirmed against a real entry in this
# machine's own ~/.claude/plugins/installed_plugins.json). Installing before the `cd` would attach
# the registration to whatever directory the script was invoked from - the real repo, not the
# ephemeral scratch project - and cleanup() below `cd`s into "$TMP/proj" before uninstalling, so it
# would then look in the wrong place on every normal exit path and leave a permanent leak in the
# user's global registry: exactly the leak the ownership snapshot above exists to prevent.
if ! install_out=$(claude plugin marketplace add "$ROOT" --scope local 2>&1); then
  printf 'NOTE - `claude plugin marketplace add` exited non-zero:\n%s\n' "$install_out"
  printf '\nINCONCLUSIVE - could not add the dashworthy marketplace; no check below can reach a behavioral result, so this run does not confirm a regression.\n'
  exit 2
fi
if ! install_out=$(claude plugin install engineering@dashworthy --scope local 2>&1); then
  printf 'NOTE - `claude plugin install engineering@dashworthy` exited non-zero:\n%s\n' "$install_out"
  printf '\nINCONCLUSIVE - could not install engineering@dashworthy; no check below can reach a behavioral result, so this run does not confirm a regression.\n'
  exit 2
fi

# 1. The command must be discoverable. The prompt deliberately does NOT name the plugin
#    ("engineering") or the command ("vernacular") - a prompt supplying either would let a
#    coherent non-answer ("I don't see any commands from that plugin") satisfy the 'vernacular'
#    pattern below by echoing the question back, not by actually finding the command. Ask about
#    installed-plugin commands generally instead, so a match is real evidence the command was
#    discovered. Do not put the plugin name back in this prompt.
run_with_quorum 'vernacular' \
  claude -p "List the slash commands available from your installed plugins. Names only." \
  --model claude-haiku-4-5-20251001
case "$qr_result" in
  ok)   printf 'ok   - command is discoverable after install\n' ;;
  fail) printf 'FAIL - command is discoverable after install\n%s\n' "$qr_text"; fail=1 ;;
  *)    printf 'INCONCLUSIVE - command is discoverable after install\n%s\n' "$qr_text"; inconclusive=1 ;;
esac

# 2. With a dirty in-scope file, preflight must halt before any dispatch.
echo '// scratch' >> src/Billing.php
run_with_quorum 'uncommitted|dirty|commit or stash|modified relative to HEAD' \
  claude -p "/vernacular" --model claude-haiku-4-5-20251001
case "$qr_result" in
  ok)   printf 'ok   - halts on a dirty in-scope file\n' ;;
  fail) printf 'FAIL - halts on a dirty in-scope file\n%s\n' "$qr_text"; fail=1 ;;
  *)    printf 'INCONCLUSIVE - halts on a dirty in-scope file\n%s\n' "$qr_text"; inconclusive=1 ;;
esac

# 3. A halted run must leave no artifacts. Vernacular's run scratch now lives under the shared
#    .engineering/<run>/vernacular/ tree rather than a plugin-private .vernacular/, so the absence
#    check looks for any "vernacular" phase directory anywhere under .engineering/ instead of a
#    single top-level path.
find "$TMP/proj/.engineering" -type d -name vernacular 2>/dev/null | grep -q . \
  && { printf 'FAIL - no artifacts written on a halted run\n'; fail=1; } \
  || printf 'ok   - no artifacts written on a halted run\n'

# 4. And must not have touched the source it refused to process.
grep -q 'Charges the card.' "$TMP/proj/src/Billing.php" \
  && printf 'ok   - source untouched on a halted run\n' \
  || { printf 'FAIL - source untouched on a halted run\n'; fail=1; }

# 5. The annotation must survive any run, and this one never started.
grep -q '@param int \$amount' "$TMP/proj/src/Billing.php" \
  && printf 'ok   - the @param annotation is intact\n' \
  || { printf 'FAIL - the @param annotation is intact\n'; fail=1; }

# A real behavioral failure (fail=1) always wins the exit code, even if some other check was also
# inconclusive - a definite failure is a stronger signal than "could not tell." Inconclusive alone
# (no real failure observed) exits 2, distinct from both a clean pass (0) and a real failure (1),
# so a caller - and a human reading the log - never mistakes "the API didn't answer" for "the
# plugin is broken."
if [ "$fail" -ne 0 ]; then
  exit 1
elif [ "$inconclusive" -ne 0 ]; then
  printf '\nINCONCLUSIVE - one or more checks could not reach a behavioral result (API error or timeout); this run does not confirm a regression.\n'
  exit 2
fi
exit 0
