#!/bin/sh
# Unit tests for vernacular/scripts/reconcile.py.
# Builds each case in a temp run directory from inline heredocs, so the fixtures
# and the assertion about them sit on the same screen.
# Run from anywhere: sh vernacular/tests/reconcile.sh

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SCRIPT="$ROOT/vernacular/scripts/reconcile.py"
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

# --- A. clean single edit: 3 lines replaced by 6 ------------------------------

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

exit $fail
