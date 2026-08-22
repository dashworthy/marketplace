#!/bin/sh
# Unit tests for engineering/scripts/reconcile.py.
# Builds each case in a temp run directory from inline heredocs, so the fixtures
# and the assertion about them sit on the same screen.
# Run from anywhere: sh engineering/tests/reconcile.sh

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SCRIPT="$ROOT/engineering/scripts/reconcile.py"
fail=0

ok()  { printf 'ok   - %s\n' "$1"; }
bad() { printf 'FAIL - %s\n' "$1"; fail=1; }

# expect <case-name> <expected-exit> — runs reconcile.py against $RUN and grades the exit code.
expect() {
  out=$(python3 "$SCRIPT" "$RUN" 2>&1); st=$?
  if [ "$st" -eq "$2" ]; then ok "$1"; else bad "$1 (exit $st, expected $2)
$out"; fi
}

# newcase — fresh run directory with before/ and receipts/, and a $WORK tree for after-files.
newcase() {
  RUN=$(mktemp -d); WORK=$(mktemp -d)
  mkdir -p "$RUN/before" "$RUN/receipts"
}

# --- A. clean single edit: 3 lines replaced by 5 ------------------------------

newcase
cat > "$RUN/before/Billing.php" <<'EOF'
<?php
class Billing {
    /**
     * Charges the card.
     */
    public function charge(int $amount): void {
        $this->gateway->charge($amount);
    }
}
EOF
cat > "$WORK/Billing.php" <<'EOF'
<?php
class Billing {
    /**
     * Takes payment for an order that has already been priced.
     * Assumes a card is on file - throws if none is, rather than
     * prompting, because this runs unattended after settlement.
     */
    public function charge(int $amount): void {
        $this->gateway->charge($amount);
    }
}
EOF
cat > "$RUN/receipts/Billing.php.json" <<EOF
{"file": "$WORK/Billing.php",
 "before": "$RUN/before/Billing.php",
 "edits": [{"start": 3, "end_before": 5, "lines_after": 5}],
 "left_alone": 0}
EOF
expect "clean single edit passes proof 1" 0

# --- B. rogue: same receipt, but a line of code also changed ------------------

newcase
cat > "$RUN/before/Billing.php" <<'EOF'
<?php
class Billing {
    /**
     * Charges the card.
     */
    public function charge(int $amount): void {
        $this->gateway->charge($amount);
    }
}
EOF
cat > "$WORK/Billing.php" <<'EOF'
<?php
class Billing {
    /**
     * Takes payment for an order that has already been priced.
     * Assumes a card is on file - throws if none is, rather than
     * prompting, because this runs unattended after settlement.
     */
    public function charge(int $amount): void {
        $this->gateway->charge($amount * 100);
    }
}
EOF
cat > "$RUN/receipts/Billing.php.json" <<EOF
{"file": "$WORK/Billing.php",
 "before": "$RUN/before/Billing.php",
 "edits": [{"start": 3, "end_before": 5, "lines_after": 5}],
 "left_alone": 0}
EOF
expect "code changed outside a claimed range fails proof 1" 1

# --- C. insertion: end_before = start - 1 -------------------------------------

newcase
cat > "$RUN/before/UserSync.php" <<'EOF'
<?php
class UserSync {
    public function reconcile(): void {
    }
}
EOF
cat > "$WORK/UserSync.php" <<'EOF'
<?php
class UserSync {
    /**
     * Brings our copy of a user back in line with the identity
     * provider's. Safe to run repeatedly; it compares before it
     * writes.
     */
    public function reconcile(): void {
    }
}
EOF
cat > "$RUN/receipts/UserSync.php.json" <<EOF
{"file": "$WORK/UserSync.php",
 "before": "$RUN/before/UserSync.php",
 "edits": [{"start": 3, "end_before": 2, "lines_after": 5}],
 "left_alone": 0}
EOF
expect "insertion of a missing docblock passes proof 1" 0

# --- D. two edits: the second one's position depends on the first's drift -----

newcase
cat > "$RUN/before/Two.php" <<'EOF'
<?php
/** One. */
function one() {}
/** Two. */
function two() {}
EOF
cat > "$WORK/Two.php" <<'EOF'
<?php
/**
 * Returns the first configured tenant, or blows up if none is.
 */
function one() {}
/**
 * Returns every tenant after the first, in configuration order.
 */
function two() {}
EOF
cat > "$RUN/receipts/Two.php.json" <<EOF
{"file": "$WORK/Two.php",
 "before": "$RUN/before/Two.php",
 "edits": [{"start": 2, "end_before": 2, "lines_after": 3},
           {"start": 4, "end_before": 4, "lines_after": 3}],
 "left_alone": 0}
EOF
expect "two edits accumulate drift correctly" 0

# --- E. malformed receipt -----------------------------------------------------

newcase
printf '{"file": "/nonexistent", "edits": [' > "$RUN/receipts/broken.json"
expect "malformed receipt exits 2" 2

# --- F. a claimed range containing @param must be rejected --------------------

newcase
cat > "$RUN/before/Tagged.php" <<'EOF'
<?php
/**
 * Charges the card.
 * @param int $amount
 * @return void
 */
function charge(int $amount): void {}
EOF
cat > "$WORK/Tagged.php" <<'EOF'
<?php
/**
 * Takes payment for an order already priced.
 */
function charge(int $amount): void {}
EOF
cat > "$RUN/receipts/Tagged.php.json" <<EOF
{"file": "$WORK/Tagged.php",
 "before": "$RUN/before/Tagged.php",
 "edits": [{"start": 3, "end_before": 5, "lines_after": 1}],
 "left_alone": 0}
EOF
expect "a claimed range containing @param fails proof 2" 1

# --- G. prose-only range above the tags is legal ------------------------------

newcase
cat > "$RUN/before/Tagged.php" <<'EOF'
<?php
/**
 * Charges the card.
 * @param int $amount
 * @return void
 */
function charge(int $amount): void {}
EOF
cat > "$WORK/Tagged.php" <<'EOF'
<?php
/**
 * Takes payment for an order that has already been priced.
 * Assumes a card is on file.
 * @param int $amount
 * @return void
 */
function charge(int $amount): void {}
EOF
cat > "$RUN/receipts/Tagged.php.json" <<EOF
{"file": "$WORK/Tagged.php",
 "before": "$RUN/before/Tagged.php",
 "edits": [{"start": 3, "end_before": 3, "lines_after": 2}],
 "left_alone": 0}
EOF
expect "a prose-only range above the tags passes both proofs" 0

# --- H. Sphinx field lists count as annotations too ---------------------------

newcase
cat > "$RUN/before/sync.py" <<'EOF'
def reconcile(user_id):
    """Reconciles the user.

    :param user_id: the user
    :returns: nothing
    """
EOF
cat > "$WORK/sync.py" <<'EOF'
def reconcile(user_id):
    """Brings our copy of a user back in line with the provider's."""
EOF
cat > "$RUN/receipts/sync.py.json" <<EOF
{"file": "$WORK/sync.py",
 "before": "$RUN/before/sync.py",
 "edits": [{"start": 2, "end_before": 6, "lines_after": 1}],
 "left_alone": 0}
EOF
expect "a claimed range containing a Sphinx field fails proof 2" 1

# --- I. singular Sphinx forms (:return:, :raise:) are caught too ---------------

newcase
cat > "$RUN/before/sync.py" <<'EOF'
def reconcile(user_id):
    """Reconciles the user.

    :return: the result
    :raise: error
    """
EOF
cat > "$WORK/sync.py" <<'EOF'
def reconcile(user_id):
    """Brings our copy of a user back in line with the provider's."""
EOF
cat > "$RUN/receipts/sync.py.json" <<EOF
{"file": "$WORK/sync.py",
 "before": "$RUN/before/sync.py",
 "edits": [{"start": 2, "end_before": 7, "lines_after": 1}],
 "left_alone": 0}
EOF
expect "a claimed range containing singular Sphinx fields fails proof 2" 1

# --- J. a claimed insertion range containing a NEW @param must be rejected ----
# Nothing in proof 1 forbids writing an annotation into a range that had none
# before the rewrite - the before-scan in proof 2 cannot see it, because there
# was nothing there to see. This is the gap: a rewriter that broke its own
# prose-only rule and inserted a tag on a previously-bare symbol must still
# fail reconcile, or invariant 1 is unenforced for every insertion.

newcase
cat > "$RUN/before/Untagged.php" <<'EOF'
<?php
class Billing {
    public function charge(int $amount): void {
        $this->gateway->charge($amount);
    }
}
EOF
cat > "$WORK/Untagged.php" <<'EOF'
<?php
class Billing {
    /**
     * Takes payment for an order that has already been priced.
     * @param int $amount
     */
    public function charge(int $amount): void {
        $this->gateway->charge($amount);
    }
}
EOF
cat > "$RUN/receipts/Untagged.php.json" <<EOF
{"file": "$WORK/Untagged.php",
 "before": "$RUN/before/Untagged.php",
 "edits": [{"start": 3, "end_before": 2, "lines_after": 4}],
 "left_alone": 0}
EOF
expect "a claimed range with a newly-written @param fails proof 2" 1

exit $fail
