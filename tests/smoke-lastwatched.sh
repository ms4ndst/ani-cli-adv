#!/usr/bin/env sh
set -eu

# Smoke test for last-watched persistence format.

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

last_state_file="$tmpdir/last"
: >"$last_state_file"

update_last_state() {
  # Mimics ani-cli's last-watched write format (now appends instead of overwriting)
  # Remove existing entry if present
  if [ -f "$last_state_file" ] && grep -q "^${id}	" "$last_state_file" 2>/dev/null; then
    sed "/^${id}	/d" "$last_state_file" >"${last_state_file}.new" && mv "${last_state_file}.new" "$last_state_file"
  fi
  # Append the new entry (using literal tab character)
  printf "%s	%s	%s\n" "$id" "$title" "$ep_no" >>"$last_state_file"
}

fail() { echo "FAIL: $*" >&2; exit 1; }

# Write first state
id="xyz"; title="Sample Show (24 episodes)"; ep_no="7"
update_last_state

[ -s "$last_state_file" ] || fail "last state file not written"

rid=$(grep "^xyz	" "$last_state_file" | cut -f1)
rtitle=$(grep "^xyz	" "$last_state_file" | cut -f2)
rep=$(grep "^xyz	" "$last_state_file" | cut -f3)

[ "$rid" = "xyz" ] || fail "id mismatch: $rid"
[ "$rtitle" = "Sample Show (24 episodes)" ] || fail "title mismatch: $rtitle"
[ "$rep" = "7" ] || fail "episode mismatch: $rep"

# Write second state (different series)
id="abc"; title="Another Show (12 episodes)"; ep_no="3"
update_last_state

lines=$(wc -l < "$last_state_file" | tr -d ' ')
[ "$lines" = "2" ] || fail "expected 2 lines, got $lines"

# Update first series with new episode
id="xyz"; title="Sample Show (24 episodes)"; ep_no="8"
update_last_state

lines=$(wc -l < "$last_state_file" | tr -d ' ')
[ "$lines" = "2" ] || fail "expected 2 lines after update, got $lines"

rep=$(grep "^xyz	" "$last_state_file" | cut -f3)
[ "$rep" = "8" ] || fail "episode not updated, expected 8, got $rep"

echo "OK: smoke-lastwatched passed"
