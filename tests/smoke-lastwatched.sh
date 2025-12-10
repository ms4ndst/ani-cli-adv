#!/usr/bin/env sh
set -eu

# Smoke test for last-watched persistence format.

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

last_state_file="$tmpdir/last"
: >"$last_state_file"

update_last_state() {
  # Mimics ani-cli's last-watched write format
  printf "%s\t%s\t%s\n" "$id" "$title" "$ep_no" >"$last_state_file"
}

fail() { echo "FAIL: $*" >&2; exit 1; }

# Write one state
id="xyz"; title="Sample Show (24 episodes)"; ep_no="7"
update_last_state

[ -s "$last_state_file" ] || fail "last state file not written"

rid=$(cut -f1 "$last_state_file")
rtitle=$(cut -f2 "$last_state_file")
rep=$(cut -f3 "$last_state_file")

[ "$rid" = "xyz" ] || fail "id mismatch: $rid"
[ "$rtitle" = "Sample Show (24 episodes)" ] || fail "title mismatch: $rtitle"
[ "$rep" = "7" ] || fail "episode mismatch: $rep"

echo "OK: smoke-lastwatched passed"
